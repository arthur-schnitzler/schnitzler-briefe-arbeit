#!/usr/bin/env python3
"""
Stempel-Abgleich-Tool.

Lokaler Web-Server mit einer Zwei-Spalten-Oberfläche zum Abgleich von
Poststempeln (physDesc//additions/incident[@type='postal']/desc/stamp) mit
den correspAction-Einträgen (correspDesc/correspAction) in editions/*.xml.

Links werden alle Stempel eines Briefs angezeigt, rechts alle correspAction.
Für jeden Stempel wird der passende correspAction-Typ vorgeschlagen
(transmission→transmitted, delivery→delivered, redirection→redirected,
arrival→arrived). Man kann daraus entweder eine neue correspAction
einfügen oder Datum/Ort einer bestehenden correspAction aus dem Stempel
übernehmen ("matchen"). Ein Button öffnet die Datei zusätzlich auf
schnitzler-briefe.acdh.oeaw.ac.at.

Jede Schreiboperation prüft vorher/nachher gegen das TEI-Schema
(meta/schnitzler-briefe-schema.xsd): war die Datei vorher schemagültig, wird
eine Änderung, die das verletzt, abgelehnt.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 stempel_abgleich.py                # Server starten, Browser öffnet sich
    python3 stempel_abgleich.py --port 8899
    python3 stempel_abgleich.py --no-open       # Browser nicht automatisch öffnen
"""

import argparse
import json
import re
import subprocess
import sys
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from lxml import etree

# ---------------------------------------------------------------------------
# Konfiguration
# ---------------------------------------------------------------------------
REPO = Path(__file__).resolve().parent
EDITIONS = REPO / "editions"
SCHEMA_PATH = REPO / "meta" / "schnitzler-briefe-schema.xsd"
STATIC_DIR = REPO / "stempel_abgleich_static"
HTML_BASE = "https://schnitzler-briefe.acdh.oeaw.ac.at/{fid}.html"
OXYGEN_APP = "/Applications/Oxygen XML Editor/Oxygen XML Editor.app"

TEI_NS = "http://www.tei-c.org/ns/1.0"
NS = {"tei": TEI_NS}

STAMP_TO_ACTION = {
    "transmission": "transmitted",
    "delivery": "delivered",
    "redirection": "redirected",
    "arrival": "arrived",
}
# "forwarded" hat seit der Vokabular-Vereinheitlichung kein stamp-Pendant
# mehr (das frühere "forwarding" wurde aus der stamp-Enumeration entfernt);
# es bleibt wie sent/received ein rein correspAction-seitiger Typ.
ACTION_TYPE_ORDER = ["sent", "transmitted", "redirected", "forwarded", "arrived", "delivered", "received"]
ACTION_RANK = {t: i for i, t in enumerate(ACTION_TYPE_ORDER)}
MAPPED_STAMP_TYPES = tuple(STAMP_TO_ACTION.keys())
MAPPED_ACTION_TYPES = tuple(STAMP_TO_ACTION.values())

STAMP_RE = re.compile(r'<stamp\b[^>]*>.*?</stamp>', re.S)
CORRESP_ACTION_RE = re.compile(r'<correspAction\b[^>]*>.*?</correspAction>', re.S)
CORRESP_DESC_RE = re.compile(r'<correspDesc\b[^>]*>.*?</correspDesc>', re.S)
RAW_BLOCK_RE = {"stamp": STAMP_RE, "correspAction": CORRESP_ACTION_RE}
TYPE_ATTR_RE = re.compile(r'\btype="([^"]*)"')
DATE_CHILD_RE = re.compile(r'<date\b[^>]*(?:/>|>.*?</date>)', re.S)
PLACE_CHILD_RE = re.compile(r'<placeName\b[^>]*(?:/>|>.*?</placeName>)', re.S)
PERSNAME_RE = re.compile(r'<persName\b[^>]*>.*?</persName>', re.S)

_schema = "unloaded"
_schema_warned = False


def get_schema():
    """Lädt das TEI-Schema, falls möglich. Das Projektschema nutzt an einer
    Stelle maxOccurs>1 innerhalb von xs:all (correspAction in correspDesc) -
    ein XSD-1.1-Feature, das libxml2/lxml (nur XSD 1.0) nicht validieren
    kann. In dem Fall wird nur noch auf Wohlgeformtheit geprüft."""
    global _schema, _schema_warned
    if _schema == "unloaded":
        try:
            _schema = etree.XMLSchema(etree.parse(str(SCHEMA_PATH)))
        except etree.XMLSchemaParseError as e:
            _schema = None
            if not _schema_warned:
                _schema_warned = True
                print(f"Hinweis: Schema kann von lxml nicht geladen werden ({e}); "
                      f"es wird nur auf Wohlgeformtheit geprüft.", file=sys.stderr)
    return _schema


# ---------------------------------------------------------------------------
# Lesen / Extrahieren (lxml, namespace-bewusst)
# ---------------------------------------------------------------------------
def q(tag):
    return f"{{{TEI_NS}}}{tag}"


def norm_text(elem):
    if elem is None:
        return ""
    return re.sub(r"\s+", " ", "".join(elem.itertext())).strip()


def extract_date(elem):
    if elem is None:
        return None
    return {
        "text": norm_text(elem),
        "when": elem.get("when"),
        "notBefore": elem.get("notBefore"),
        "notAfter": elem.get("notAfter"),
    }


def extract_place(elem):
    if elem is None:
        return None
    return {"text": norm_text(elem), "ref": elem.get("ref")}


def extract_stamps(root):
    stamps = []
    for i, s in enumerate(root.iter(q("stamp"))):
        stamps.append({
            "index": i,
            "n": s.get("n"),
            "type": s.get("type"),
            "attrs": dict(s.attrib),
            "place": extract_place(s.find(q("placeName"))),
            "date": extract_date(s.find(q("date"))),
            "time": norm_text(s.find(q("time"))) or None,
            "suggestedType": STAMP_TO_ACTION.get(s.get("type")),
        })
    return stamps


def extract_corresp_actions(root):
    actions = []
    for i, a in enumerate(root.iter(q("correspAction"))):
        persons = [{"text": norm_text(p), "ref": p.get("ref")} for p in a.findall(q("persName"))]
        actions.append({
            "index": i,
            "type": a.get("type"),
            "attrs": dict(a.attrib),
            "persons": persons,
            "date": extract_date(a.find(q("date"))),
            "place": extract_place(a.find(q("placeName"))),
        })
    return actions


def attach_raw(items, text, tag):
    raws = [m.group(0) for m in RAW_BLOCK_RE[tag].finditer(text)]
    if len(raws) != len(items):
        raise ValueError(
            f"Interner Zählfehler bei <{tag}>: {len(items)} über lxml, "
            f"{len(raws)} über Text-Suche - Datei bitte manuell prüfen.")
    for item, raw in zip(items, raws):
        item["raw"] = raw
    return items


def load_text(fid):
    path = EDITIONS / f"{fid}.xml"
    if not path.exists():
        raise FileNotFoundError(f"{fid}.xml nicht gefunden")
    with path.open("r", encoding="utf-8", newline="") as f:
        return f.read()


def parse_root(text):
    return etree.fromstring(text.encode("utf-8"))


def local_name(tag):
    return tag.split("}", 1)[1] if "}" in tag else tag


BODY_BLOCK_TAGS = {"closer", "opener", "address", "postscript"}


def render_body_inner(elem):
    """Rendert den Inhalt eines Elements aus //body als HTML. <date> wird
    rot markiert; ein paar weitere gängige TEI-Elemente (lb, pb, hi, del,
    add, note, unclear, supplied, space, gap) bekommen eine sinnvolle
    Darstellung, alles andere fällt generisch auf einen <span> zurück."""
    parts = []
    if elem.text:
        parts.append(escape_text(elem.text))
    for child in elem:
        parts.append(render_body_elem(child))
        if child.tail:
            parts.append(escape_text(child.tail))
    return "".join(parts)


def render_body_elem(elem):
    if not isinstance(elem.tag, str):  # Kommentare/PIs im Baum überspringen
        return escape_text(elem.tail or "")
    name = local_name(elem.tag)
    inner = render_body_inner(elem)

    if name == "date":
        return f'<mark class="body-date">{inner}</mark>'
    if name == "lb":
        return "<br>"
    if name == "pb":
        return '<span class="body-pb" title="Seitenwechsel"></span>'
    if name == "space":
        try:
            n = max(1, int(elem.get("quantity") or 1))
        except ValueError:
            n = 1
        return "&#32;" * n
    if name == "gap":
        return '<span class="body-gap">[…]</span>'
    if name == "del":
        return f'<del class="body-del">{inner}</del>'
    if name == "add":
        return f'<ins class="body-add">{inner}</ins>'
    if name == "note":
        return f'<span class="body-note" title="Kommentar">{inner}</span>'
    if name == "unclear":
        return f'<span class="body-unclear" title="unsicher gelesen">{inner}</span>'
    if name == "supplied":
        return f'<span class="body-supplied">{inner}</span>'
    if name == "hi":
        rend_cls = " ".join(f"rend-{r}" for r in (elem.get("rend") or "").split())
        cls = ("body-hi " + rend_cls).strip()
        return f'<span class="{escape_attr(cls)}">{inner}</span>'
    if name == "p":
        return f'<p class="body-p">{inner}</p>'
    if name == "div":
        t = elem.get("type") or ""
        cls = ("body-div " + (f"body-div-{t}" if t else "")).strip()
        return f'<div class="{escape_attr(cls)}">{inner}</div>'
    if name in BODY_BLOCK_TAGS:
        return f'<div class="body-{escape_attr(name)}">{inner}</div>'
    return f'<span class="body-{escape_attr(name)}">{inner}</span>'


def render_body_html(root):
    body = root.find(f".//{q('body')}")
    return render_body_inner(body) if body is not None else ""


def extract_dateline_date(root):
    """//descendant::dateline[1]/date[1]: das erste date-Element in der
    ersten dateline im Dokument (typischerweise die vom Absender selbst
    geschriebene Datumszeile im Brieftext) - zum Abgleich mit
    correspAction[@type='sent'] neben der Poststempel-Spalte."""
    dateline = root.find(f".//{q('dateline')}")
    if dateline is None:
        return None
    date = dateline.find(q("date"))
    return extract_date(date) if date is not None else None


def build_file_payload(fid):
    text = load_text(fid)
    root = parse_root(text)
    stamps = attach_raw(extract_stamps(root), text, "stamp")
    actions = attach_raw(extract_corresp_actions(root), text, "correspAction")
    return {
        "id": fid,
        "htmlUrl": HTML_BASE.format(fid=fid),
        "stamps": stamps,
        "correspActions": actions,
        "bodyHtml": render_body_html(root),
        "datelineDate": extract_dateline_date(root),
    }


# ---------------------------------------------------------------------------
# Kandidatenliste (für Navigation / Filter)
# ---------------------------------------------------------------------------
_list_cache = None


def scan_candidates():
    result = []
    for path in sorted(EDITIONS.glob("*.xml")):
        text = path.read_text(encoding="utf-8")
        stamp_count = len(re.findall(r"<stamp\b", text))
        if stamp_count == 0:
            continue
        result.append(_candidate_row(path.stem, text, stamp_count))
    return result


def _candidate_row(fid, text, stamp_count=None):
    if stamp_count is None:
        stamp_count = len(re.findall(r"<stamp\b", text))
    mapped_stamps = len(re.findall(
        r'<stamp\b[^>]*\btype="(?:%s)"' % "|".join(MAPPED_STAMP_TYPES), text))
    mapped_actions = len(re.findall(
        r'<correspAction\b[^>]*\btype="(?:%s)"' % "|".join(MAPPED_ACTION_TYPES), text))
    return {
        "id": fid,
        "stampCount": stamp_count,
        "correspCount": len(re.findall(r"<correspAction\b", text)),
        "mismatch": mapped_stamps > mapped_actions,
    }


def get_candidates():
    global _list_cache
    if _list_cache is None:
        _list_cache = scan_candidates()
    return _list_cache


def refresh_candidate(fid):
    global _list_cache
    if _list_cache is None:
        return
    path = EDITIONS / f"{fid}.xml"
    text = path.read_text(encoding="utf-8")
    stamp_count = len(re.findall(r"<stamp\b", text))
    row = _candidate_row(fid, text, stamp_count) if stamp_count else None
    _list_cache[:] = [r for r in _list_cache if r["id"] != fid]
    if row:
        _list_cache.append(row)
        _list_cache.sort(key=lambda r: r["id"])


# ---------------------------------------------------------------------------
# Schreiben (gezielte Textchirurgie, Formatierung des restlichen Dokuments
# bleibt unangetastet; lxml wird nur zur Validierung benutzt)
# ---------------------------------------------------------------------------
def escape_attr(s):
    return (s or "").replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;")


def escape_text(s):
    return (s or "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def line_start(text, offset):
    return text.rfind("\n", 0, offset) + 1


def indent_of(text, offset):
    ls = line_start(text, offset)
    return text[ls:offset]


def validate_and_save(fid, old_text, new_text):
    try:
        new_root = etree.fromstring(new_text.encode("utf-8"))
    except etree.XMLSyntaxError as e:
        raise ValueError(f"Ergebnis ist kein wohlgeformtes XML: {e}")

    schema = get_schema()
    if schema is not None:
        try:
            old_root = etree.fromstring(old_text.encode("utf-8"))
            was_valid = schema.validate(old_root)
        except etree.XMLSyntaxError:
            was_valid = False

        is_valid = schema.validate(new_root)
        if was_valid and not is_valid:
            msg = "; ".join(str(e) for e in schema.error_log)
            raise ValueError(f"Änderung verletzt das TEI-Schema: {msg}")

    path = EDITIONS / f"{fid}.xml"
    path.write_text(new_text, encoding="utf-8", newline="")
    refresh_candidate(fid)


def build_date_elem(date):
    if not date or not (date.get("text") or date.get("when")):
        return None
    attrs = ""
    if date.get("when"):
        attrs += f' when="{escape_attr(date["when"])}"'
    if date.get("notBefore"):
        attrs += f' notBefore="{escape_attr(date["notBefore"])}"'
    if date.get("notAfter"):
        attrs += f' notAfter="{escape_attr(date["notAfter"])}"'
    text = date.get("text") or ""
    if not text:
        return f'<date{attrs}/>'
    return f'<date{attrs}>{escape_text(text)}</date>'


def build_place_elem(place):
    if not place or not place.get("text"):
        return None
    ref_attr = f' ref="{escape_attr(place["ref"])}"' if place.get("ref") else ""
    return f'<placeName{ref_attr}>{escape_text(place["text"])}</placeName>'


def insert_corresp_action(fid, stamp_index, target_type):
    if target_type not in ACTION_RANK:
        raise ValueError(f"unbekannter correspAction-Typ: {target_type}")
    text = load_text(fid)
    root = parse_root(text)
    stamps = extract_stamps(root)
    if not (0 <= stamp_index < len(stamps)):
        raise ValueError("ungültiger Stempel-Index")
    stamp = stamps[stamp_index]

    desc_m = CORRESP_DESC_RE.search(text)
    if not desc_m:
        raise ValueError("correspDesc nicht gefunden")
    desc_text = desc_m.group(0)
    desc_offset = desc_m.start()

    blocks = list(CORRESP_ACTION_RE.finditer(desc_text))
    if not blocks:
        raise ValueError("correspAction nicht gefunden")

    new_rank = ACTION_RANK[target_type]
    insert_at = None
    ref_block = None
    for b in blocks:
        t = TYPE_ATTR_RE.search(b.group(0)).group(1)
        if ACTION_RANK.get(t, 99) > new_rank:
            insert_at = line_start(desc_text, b.start())
            ref_block = b
            break
    if insert_at is None:
        ref_block = blocks[-1]
        insert_at = ref_block.end()
        if desc_text[insert_at:insert_at + 1] == "\n":
            insert_at += 1

    indent = indent_of(desc_text, ref_block.start())
    child_m = re.search(r'\n([ \t]+)<\w', ref_block.group(0))
    child_indent = child_m.group(1) if child_m else indent + "   "

    lines = [f'{indent}<correspAction type="{escape_attr(target_type)}">']
    date_elem = build_date_elem(stamp.get("date"))
    if date_elem:
        lines.append(f'{child_indent}{date_elem}')
    place_elem = build_place_elem(stamp.get("place"))
    if place_elem:
        lines.append(f'{child_indent}{place_elem}')
    lines.append(f'{indent}</correspAction>')
    new_block = "\n".join(lines) + "\n"

    new_desc_text = desc_text[:insert_at] + new_block + desc_text[insert_at:]
    new_text = text[:desc_offset] + new_desc_text + text[desc_offset + len(desc_text):]

    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


def update_corresp_action(fid, stamp_index, action_index):
    text = load_text(fid)
    root = parse_root(text)
    stamps = extract_stamps(root)
    actions = extract_corresp_actions(root)
    if not (0 <= stamp_index < len(stamps)):
        raise ValueError("ungültiger Stempel-Index")
    if not (0 <= action_index < len(actions)):
        raise ValueError("ungültiger correspAction-Index")
    stamp = stamps[stamp_index]

    blocks = list(CORRESP_ACTION_RE.finditer(text))
    if action_index >= len(blocks):
        raise ValueError("correspAction nicht gefunden")
    block = blocks[action_index]
    block_text = block.group(0)

    indent = indent_of(text, block.start())
    child_m = re.search(r'\n([ \t]+)<\w', block_text)
    child_indent = child_m.group(1) if child_m else indent + "   "

    new_block_text = block_text

    new_date_elem = build_date_elem(stamp.get("date"))
    if new_date_elem:
        if DATE_CHILD_RE.search(new_block_text):
            new_block_text = DATE_CHILD_RE.sub(lambda m: new_date_elem, new_block_text, count=1)
        else:
            pers_matches = list(PERSNAME_RE.finditer(new_block_text))
            if pers_matches:
                pos = pers_matches[-1].end()
            else:
                open_line = re.match(r'[^\n]*\n', new_block_text)
                pos = open_line.end() if open_line else 0
            new_block_text = new_block_text[:pos] + f'\n{child_indent}{new_date_elem}' + new_block_text[pos:]

    new_place_elem = build_place_elem(stamp.get("place"))
    if new_place_elem:
        if PLACE_CHILD_RE.search(new_block_text):
            new_block_text = PLACE_CHILD_RE.sub(lambda m: new_place_elem, new_block_text, count=1)
        else:
            date_matches = list(DATE_CHILD_RE.finditer(new_block_text))
            if date_matches:
                pos = date_matches[-1].end()
            else:
                pers_matches = list(PERSNAME_RE.finditer(new_block_text))
                if pers_matches:
                    pos = pers_matches[-1].end()
                else:
                    open_line = re.match(r'[^\n]*\n', new_block_text)
                    pos = open_line.end() if open_line else 0
            new_block_text = new_block_text[:pos] + f'\n{child_indent}{new_place_elem}' + new_block_text[pos:]

    new_text = text[:block.start()] + new_block_text + text[block.end():]
    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


def replace_raw_block(fid, kind, index, new_xml):
    """Ersetzt den n-ten <stamp>- bzw. <correspAction>-Block im Dokument
    (in Dokumentreihenfolge) 1:1 durch den vom Nutzer bearbeiteten
    XML-Text. Damit lassen sich beliebige Attribute und Kindelemente frei
    editieren, nicht nur die von insert/update abgedeckten Felder."""
    if kind not in RAW_BLOCK_RE:
        raise ValueError(f"unbekannte Art: {kind}")
    tag = kind
    new_xml = (new_xml or "").strip()
    if not new_xml:
        raise ValueError("XML darf nicht leer sein")
    if not re.match(rf'^<{tag}\b', new_xml):
        raise ValueError(f"Element muss mit <{tag} beginnen")
    if not new_xml.endswith(f'</{tag}>'):
        raise ValueError(f"Element muss mit </{tag}> enden")
    try:
        etree.fromstring(new_xml.encode("utf-8"))
    except etree.XMLSyntaxError as e:
        raise ValueError(f"XML-Fragment ist nicht wohlgeformt: {e}")

    text = load_text(fid)
    blocks = list(RAW_BLOCK_RE[tag].finditer(text))
    if not (0 <= index < len(blocks)):
        raise ValueError(f"ungültiger Index für {kind}")
    block = blocks[index]

    new_text = text[:block.start()] + new_xml + text[block.end():]
    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


# ---------------------------------------------------------------------------
# HTTP-Server
# ---------------------------------------------------------------------------
CONTENT_TYPES = {
    ".html": "text/html; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write(f"{self.address_string()} - {fmt % args}\n")

    def _send_json(self, obj, status=200):
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_static(self, rel_path):
        path = (STATIC_DIR / rel_path).resolve()
        if STATIC_DIR.resolve() not in path.parents and path != STATIC_DIR.resolve():
            self.send_error(403)
            return
        if not path.exists():
            self.send_error(404)
            return
        body = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", CONTENT_TYPES.get(path.suffix, "application/octet-stream"))
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        try:
            if path == "/" or path == "/index.html":
                self._send_static("index.html")
            elif path in ("/app.js", "/style.css"):
                self._send_static(path.lstrip("/"))
            elif path == "/api/list":
                self._send_json({"files": get_candidates()})
            elif path.startswith("/api/file/"):
                fid = path[len("/api/file/"):]
                self._send_json(build_file_payload(fid))
            elif path.startswith("/api/open-oxygen/"):
                fid = path[len("/api/open-oxygen/"):]
                xml_path = EDITIONS / f"{fid}.xml"
                if xml_path.exists():
                    subprocess.run(["open", "-a", OXYGEN_APP, str(xml_path)], check=False)
                    self._send_json({"ok": True})
                else:
                    self._send_json({"ok": False, "error": "Datei nicht gefunden"}, 404)
            else:
                self.send_error(404)
        except FileNotFoundError as e:
            self._send_json({"error": str(e)}, 404)
        except Exception as e:  # noqa: BLE001
            self._send_json({"error": str(e)}, 500)

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            payload = json.loads(raw.decode("utf-8")) if raw else {}
        except json.JSONDecodeError:
            self._send_json({"error": "ungültiges JSON"}, 400)
            return

        try:
            m = re.match(r"^/api/file/([^/]+)/(insert|update|raw)$", path)
            if not m:
                self.send_error(404)
                return
            fid, action = m.group(1), m.group(2)
            if action == "insert":
                result = insert_corresp_action(
                    fid, int(payload["stampIndex"]), payload["targetType"])
            elif action == "update":
                result = update_corresp_action(
                    fid, int(payload["stampIndex"]), int(payload["actionIndex"]))
            else:
                result = replace_raw_block(
                    fid, payload["kind"], int(payload["index"]), payload["xml"])
            self._send_json(result)
        except (KeyError, ValueError, TypeError) as e:
            self._send_json({"error": str(e)}, 400)
        except FileNotFoundError as e:
            self._send_json({"error": str(e)}, 404)
        except Exception as e:  # noqa: BLE001
            self._send_json({"error": str(e)}, 500)


def main():
    ap = argparse.ArgumentParser(description="Stempel-Abgleich-Tool")
    ap.add_argument("--port", type=int, default=8877)
    ap.add_argument("--no-open", action="store_true", help="Browser nicht automatisch öffnen")
    args = ap.parse_args()

    if not EDITIONS.is_dir():
        sys.exit(f"editions/ nicht gefunden unter {REPO}")
    if not SCHEMA_PATH.exists():
        sys.exit(f"Schema nicht gefunden unter {SCHEMA_PATH}")

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    url = f"http://127.0.0.1:{args.port}/"
    print(f"Stempel-Abgleich läuft auf {url}  (Strg-C zum Beenden)")
    if not args.no_open:
        webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nBeendet.")


if __name__ == "__main__":
    main()
