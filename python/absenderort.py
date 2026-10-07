#!/usr/bin/env python3
"""
Absenderort-Tool (Variante von stempel_abgleich.py).

Lokaler Web-Server zum Eintragen des Absenderorts in
correspAction[@type='sent']/placeName in editions/*.xml. Läuft über alle
Dateien, deren erster witness keinen objectType/@ana mit "postkarte" hat
(also ohne Postkarten und Bildpostkarten).

Pro Brief wird der aktuell eingetragene Ort angezeigt; per Dropdown lässt
sich ein anderer wählen:
  - Orte aus tei:back/tei:listPlace/tei:place (die im Brieftext
    vorkommenden zuerst),
  - Wohnadressen der beteiligten Personen zum Datum des Briefs,
  - Orte aus anderen correspAction desselben Jahres.
In der correspAction, in der pmb2121 vorkommt, werden stattdessen nur
Schnitzlers Wohnadressen und seine Aufenthaltsorte am Datum des Briefs
angeboten.
Auch der Empfangsort (correspAction[@type='received']) lässt sich setzen; Aufenthalte
Schnitzlers werden nur für den Absenderort angeboten, und nur, wenn er dort steht.
Zusätzlich gibt es eine Liste der Orte, an denen die Person(en) laut anderen
correspAction desselben Jahres verzeichnet sind (meta/orte_aus_correspaction.json,
neu erstellen per Knopf im Tool oder mit --rebuild-index).
Im Brieftext sind alle vorkommenden Orte (placeName, rs[@type='place'])
rot hinterlegt.

Baut auf stempel_abgleich.py auf (Lesen/Schreiben, Wohnadressen).

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 python/absenderort.py [--port 8878] [--no-open]
"""

import argparse
import json
import re
import sys
import threading
import webbrowser
from datetime import date as _date
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
from urllib.error import URLError
from urllib.parse import urlparse
from urllib.request import urlopen

sys.path.insert(0, str(Path(__file__).resolve().parent))
import stempel_abgleich as sa  # noqa: E402

q, norm_text = sa.q, sa.norm_text
STATIC_DIR = sa.REPO / "absenderort_static"
INDEX_PATH = sa.REPO / "meta" / "orte_aus_correspaction.json"

WITNESS_RE = re.compile(r'<witness\b.*?</witness>', re.S)
OBJECT_TYPE_RE = re.compile(r'<objectType\b[^>]*>')
ANA_RE = re.compile(r'\bana="([^"]*)"')
CHANGE_ABSENDERORT_TEXT = "Absenderort überprüft"
REVIEWED_MARKER_RE = re.compile(re.escape(f">{CHANGE_ABSENDERORT_TEXT}</change>"))
PLACENAME_IN_ACTION_RE = re.compile(r'<placeName\b[^>]*>(.*?)</placeName>', re.S)


def is_postkarte(text):
    """Entspricht dem XPath witness[1]/objectType/@ana[not(contains(., 'postkarte'))]
    (Bildpostkarten enthalten 'postkarte' und fallen damit ebenfalls raus)."""
    w = WITNESS_RE.search(text)
    if not w:
        return False
    for ot in OBJECT_TYPE_RE.finditer(w.group(0)):
        m = ANA_RE.search(ot.group(0))
        if m and "postkarte" in m.group(1):
            return True
    return False


def sent_block(text):
    for m in sa.CORRESP_ACTION_RE.finditer(text):
        t = sa.TYPE_ATTR_RE.search(m.group(0))
        if t and t.group(1) == "sent":
            return m
    return None


def sent_index(text):
    return action_index(text, "sent")


# ---------------------------------------------------------------------------
# Kandidatenliste
# ---------------------------------------------------------------------------
_list_cache = None


def _row(fid, text):
    m = sent_block(text)
    place = None
    if m:
        pm = PLACENAME_IN_ACTION_RE.search(m.group(0))
        if pm:
            place = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", pm.group(1))).strip() or None
    return {"id": fid, "place": place, "reviewed": bool(REVIEWED_MARKER_RE.search(text))}


def get_candidates():
    global _list_cache
    if _list_cache is None:
        _list_cache = []
        for path in sorted(sa.EDITIONS.glob("*.xml")):
            text = path.read_text(encoding="utf-8")
            if is_postkarte(text) or not sent_block(text):
                continue
            _list_cache.append(_row(path.stem, text))
    return _list_cache


def refresh_candidate(fid):
    if _list_cache is None:
        return
    row = _row(fid, sa.load_text(fid))
    for i, r in enumerate(_list_cache):
        if r["id"] == fid:
            _list_cache[i] = row


# ---------------------------------------------------------------------------
# Orte-Liste aus allen correspAction (Person -> Jahr -> Ort)
# ---------------------------------------------------------------------------
_corresp_index = None
_YEAR_RE = re.compile(r"^(\d{4})")


def _first_date(date_el):
    if date_el is None:
        return None
    for attr in ("when", "notBefore", "notAfter"):
        v = date_el.get(attr)
        if v and _YEAR_RE.match(v):
            return v
    return None


def build_corresp_index():
    """Geht alle editions/*.xml durch und sammelt aus jeder correspAction mit
    placeName/@ref, persName/@ref und datierbarem date: welche Person wann
    (Jahr) wo war. Schreibt das Ergebnis nach meta/orte_aus_correspaction.json
    (Person -> Jahr -> Ort -> Belege [Brief, Datum]) und ersetzt den Cache.
    Aufruf per Knopf im Tool oder mit --rebuild-index."""
    index = {}
    n_files = n_entries = 0
    for path in sorted(sa.EDITIONS.glob("*.xml")):
        text = path.read_text(encoding="utf-8")
        m = sa.CORRESP_DESC_RE.search(text)
        if not m:
            continue
        try:
            desc = sa.etree.fromstring(m.group(0).encode("utf-8"))
        except sa.etree.ParseError:
            print(f"Übersprungen (nicht parsbar): {path.name}", file=sys.stderr)
            continue
        n_files += 1
        for action in desc.iter():
            if not isinstance(action.tag, str) or sa.local_name(action.tag) != "correspAction":
                continue
            kids = [(sa.local_name(c.tag), c) for c in action if isinstance(c.tag, str)]
            dates = [c for n, c in kids if n == "date"]
            places = [c for n, c in kids if n == "placeName"]
            persons = [c.get("ref") for n, c in kids if n == "persName" and c.get("ref")]
            d = _first_date(dates[0]) if dates else None
            if not (d and places and persons and places[0].get("ref")):
                continue
            place_ref, place_text = places[0].get("ref"), norm_text(places[0])
            for pref in persons:
                entry = (index.setdefault(d[:4], {}).setdefault(pref, {})
                         .setdefault(place_ref, {"text": place_text, "entries": []}))
                entry["entries"].append([path.stem, d])
                n_entries += 1
    INDEX_PATH.write_text(json.dumps(index, ensure_ascii=False, indent=1), encoding="utf-8")
    global _corresp_index
    _corresp_index = index
    return {"files": n_files, "entries": n_entries, "years": len(index)}


def load_corresp_index():
    global _corresp_index
    if _corresp_index is None:
        if not INDEX_PATH.exists():
            build_corresp_index()
        else:
            _corresp_index = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    return _corresp_index


def _day_distance(a, b):
    try:
        return abs((_date.fromisoformat(a) - _date.fromisoformat(b)).days)
    except ValueError:
        return 9999


def corresp_options(action, fid):
    """Orte, an denen die Person(en) der Aktion laut anderen Briefen desselben
    Jahres (correspAction mit persName+date+placeName) verzeichnet sind - der
    aktuelle Brief zählt nicht mit. Sortiert nach Abstand des nächstgelegenen
    Belegs zum Briefdatum, dann nach Häufigkeit."""
    date = action["date"] or {}
    ref_date = _first_date_from_dict(date)
    if not ref_date:
        return []
    year_data = load_corresp_index().get(ref_date[:4], {})
    found = {}
    for p in action["persons"]:
        for place_ref, info in year_data.get(p.get("ref") or "", {}).items():
            others = [e for e in info["entries"] if e[0] != fid]
            if not others:
                continue
            f = found.setdefault(place_ref, {"text": info["text"], "entries": []})
            f["entries"].extend(others)
    options = []
    for place_ref, f in found.items():
        nearest = min(f["entries"], key=lambda e: _day_distance(e[1], ref_date))
        options.append((_day_distance(nearest[1], ref_date), -len(f["entries"]), {
            "ref": place_ref, "text": f["text"], "kind": "korrespondenz",
            "label": f'{f["text"]} ({len(f["entries"])}×, nächster: {nearest[1]} in {nearest[0]})'}))
    options.sort(key=lambda t: t[:2])
    return [o for _, _, o in options]


def _first_date_from_dict(date):
    for k in ("when", "notBefore", "notAfter"):
        if date.get(k) and _YEAR_RE.match(date[k]):
            return date[k]
    return None


# ---------------------------------------------------------------------------
# Payload
# ---------------------------------------------------------------------------
def _ref_key(ref):
    return (ref or "").lstrip("#")


def body_place_refs(root):
    body = root.find(f".//{q('body')}")
    refs = set()
    if body is None:
        return refs
    for el in body.iter():
        if not isinstance(el.tag, str):
            continue
        name = sa.local_name(el.tag)
        if name == "placeName" or (name == "rs" and el.get("type") == "place"):
            for r in (el.get("ref") or "").split():
                refs.add(_ref_key(r))
    return refs


def list_place_options(root, in_body):
    options = []
    for p in root.findall(f".//{q('back')}//{q('listPlace')}/{q('place')}"):
        xml_id = p.get("{http://www.w3.org/XML/1998/namespace}id")
        name_el = p.find(q("placeName"))
        if not xml_id or name_el is None:
            continue
        options.append({
            "ref": "#" + xml_id, "text": norm_text(name_el),
            "kind": "brief", "inBody": xml_id in in_body})
    options.sort(key=lambda o: not o["inBody"])  # stabil: Reihenfolge sonst erhalten
    return options


def action_index(text, action_type):
    for i, m in enumerate(sa.CORRESP_ACTION_RE.finditer(text)):
        t = sa.TYPE_ATTR_RE.search(m.group(0))
        if t and t.group(1) == action_type:
            return i
    return None


def has_schnitzler(action):
    return any(p.get("ref") == sa.ARTHUR_SCHNITZLER_REF for p in action["persons"])


def person_options(root, action, sent_action):
    """Wohnadressen der Personen zum Datum der Aktion (bei fehlendem Datum:
    Datum der sent-Aktion). Steht Schnitzler in der Aktion, nur seine
    Wohnadressen (plus seine Aufenthalte, s. u.); sonst die Wohnadressen aller
    in correspDesc genannten Personen. Aufenthalte Schnitzlers nur für die
    sent-Aktion und nur, wenn er dort selbst steht."""
    persons = []
    if has_schnitzler(action):
        persons = [{"text": p.get("text"), "ref": p.get("ref")} for p in action["persons"]
                   if p.get("ref") == sa.ARTHUR_SCHNITZLER_REF]
    else:
        for a in root.iter(q("correspAction")):
            persons.extend({"text": norm_text(p), "ref": p.get("ref")} for p in a.findall(q("persName")))
    date = action["date"] if (action["date"] or {}).get("when") or (action["date"] or {}).get("notBefore") \
        or (action["date"] or {}).get("notAfter") else sent_action["date"]
    opts = sa.residence_options_for_action(persons, date)
    if action is not sent_action or not has_schnitzler(action):
        opts = [o for o in opts if o["kind"] != "aufenthalt"]
    return opts


def options_for(root, action, sent_action, in_body, fid):
    if has_schnitzler(action):
        # Schnitzlers Aktion: nur seine Wohnadressen und Aufenthaltsorte am Tag
        return [{**o, "inBody": _ref_key(o["ref"]) in in_body}
                for o in person_options(root, action, sent_action)]
    options = list_place_options(root, in_body)
    seen = {o["ref"] for o in options}
    for o in person_options(root, action, sent_action):
        if o["ref"] not in seen:
            seen.add(o["ref"])
            options.append({**o, "inBody": _ref_key(o["ref"]) in in_body})
    for o in corresp_options(action, fid):
        options.append({**o, "inBody": _ref_key(o["ref"]) in in_body})
    return options


def build_payload(fid):
    text = sa.load_text(fid)
    root = sa.parse_root(text)
    actions = sa.extract_corresp_actions(root)
    idx = action_index(text, "sent")
    if idx is None:
        raise ValueError("keine correspAction[@type='sent'] vorhanden")
    sent = actions[idx]
    in_body = body_place_refs(root)
    out = {
        "id": fid,
        "htmlUrl": sa.HTML_BASE.format(fid=fid),
        "title": sa.extract_title(root),
        "bodyHtml": sa.render_body_html(root),
    }
    for key, atype in (("sent", "sent"), ("received", "received")):
        i = action_index(text, atype)
        if i is None:
            out[key] = None
            continue
        act = actions[i]
        out[key] = {"persons": act["persons"], "date": act["date"], "place": act["place"],
                    "options": options_for(root, act, sent, in_body, fid)}
    return out


# Orte im Brieftext rot markieren: sa.render_body_elem wird zur Laufzeit von
# render_body_inner nachgeschlagen, das Ersetzen greift also auch rekursiv.
_orig_render_body_elem = sa.render_body_elem


def _render_with_places(elem):
    html = _orig_render_body_elem(elem)
    if isinstance(elem.tag, str):
        name = sa.local_name(elem.tag)
        if name == "placeName" or (name == "rs" and elem.get("type") == "place"):
            ref = sa.escape_attr(elem.get("ref") or "")
            return f'<mark class="body-place" data-ref="{ref}">{html}</mark>'
    return html


sa.render_body_elem = _render_with_places


# ---------------------------------------------------------------------------
# Schreiben
# ---------------------------------------------------------------------------
def resolve_pmb_place(fid, number, root=None):
    """Name zu einer PMB-Ortsnummer: erst aus back/listPlace der Datei, sonst
    aus der PMB-API (TEI ohne Namespace, daher Abgleich über lokale
    Elementnamen)."""
    m = re.fullmatch(r"\s*#?(?:pmb)?(\d+)\s*", number or "")
    if not m:
        raise ValueError("PMB-Nummer nicht lesbar (erwartet z. B. 50 oder pmb50)")
    num = m.group(1)
    root = root if root is not None else sa.parse_root(sa.load_text(fid))
    for o in list_place_options(root, set()):
        if o["ref"] == f"#pmb{num}":
            return f"#pmb{num}", o["text"]
    try:
        with urlopen(f"https://pmb.acdh.oeaw.ac.at/apis/tei/place/{num}", timeout=15) as r:
            api_root = sa.etree.fromstring(r.read())
    except (URLError, OSError, sa.etree.ParseError) as e:
        raise ValueError(f"PMB-Ort {num} nicht abrufbar ({e}) - bitte Namen selbst eintragen")
    for el in api_root.iter():
        if isinstance(el.tag, str) and sa.local_name(el.tag) == "placeName" and norm_text(el):
            return f"#pmb{num}", norm_text(el)
    raise ValueError(f"PMB-Ort {num} hat keinen Namen - bitte Namen selbst eintragen")


def set_action_place_by_type(fid, action_type, ref, name, pmb=None):
    if action_type not in ("sent", "received"):
        raise ValueError(f"unbekannter Typ: {action_type}")
    if pmb:
        ref, resolved = resolve_pmb_place(fid, pmb)
        name = (name or "").strip() or resolved
    name = (name or "").strip()
    if not name:
        raise ValueError("Ortsname fehlt")
    text = sa.load_text(fid)
    block = next((m for m in sa.CORRESP_ACTION_RE.finditer(text)
                  if (sa.TYPE_ATTR_RE.search(m.group(0)) or [None, None])[1] == action_type), None)
    if not block:
        raise ValueError(f"correspAction[@type='{action_type}'] nicht gefunden")
    block_text = block.group(0)
    indent = sa.indent_of(text, block.start())
    child_m = re.search(r'\n([ \t]+)<\w', block_text)
    child_indent = child_m.group(1) if child_m else indent + "   "
    place_elem = sa.build_place_elem({"text": name, "ref": ref or None})
    new_block = sa.apply_place_to_block(block_text, child_indent, place_elem)
    new_text = text[:block.start()] + new_block + text[block.end():]
    sa.validate_and_save(fid, text, new_text)
    refresh_candidate(fid)
    return build_payload(fid)


def add_revision_change(fid, who):
    """Trägt in revisionDesc einen change "Absenderort überprüft" ein (wie
    stempel_abgleich.py); ein bereits vorhandener Eintrag desselben
    Bearbeiters wird nicht doppelt gesetzt."""
    if who not in sa.EDITORS:
        raise ValueError(f"unbekannter Bearbeiter: {who}")
    text = sa.load_text(fid)
    already = re.search(
        r'<change\b(?=[^>]*\bwho="%s")[^>]*>%s</change>' % (re.escape(who), re.escape(CHANGE_ABSENDERORT_TEXT)),
        text)
    if not already:
        sa.append_revision_change(fid, who, CHANGE_ABSENDERORT_TEXT)
    refresh_candidate(fid)
    return {"ok": True, "added": not already}


# ---------------------------------------------------------------------------
# HTTP-Server
# ---------------------------------------------------------------------------
class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write(f"{self.address_string()} - {fmt % args}\n")

    def _send(self, body, ctype, status=200):
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _json(self, obj, status=200):
        self._send(json.dumps(obj, ensure_ascii=False).encode("utf-8"),
                   "application/json; charset=utf-8", status)

    def do_GET(self):
        path = urlparse(self.path).path
        try:
            if path in ("/", "/index.html"):
                self._send((STATIC_DIR / "index.html").read_bytes(), "text/html; charset=utf-8")
            elif path == "/api/list":
                self._json({"files": get_candidates()})
            elif path.startswith("/api/file/"):
                self._json(build_payload(path[len("/api/file/"):]))
            elif path.startswith("/api/open-oxygen/"):
                xml_path = sa.EDITIONS / f"{path[len('/api/open-oxygen/'):]}.xml"
                if not xml_path.exists():
                    self._json({"error": "Datei nicht gefunden"}, 404)
                else:
                    subprocess.run(["open", "-a", sa.OXYGEN_APP, str(xml_path)], check=False)
                    self._json({"ok": True})
            elif path == "/api/shutdown":
                self._json({"ok": True})
                threading.Thread(target=self.server.shutdown, daemon=True).start()
            else:
                self.send_error(404)
        except FileNotFoundError as e:
            self._json({"error": str(e)}, 404)
        except Exception as e:  # noqa: BLE001
            self._json({"error": str(e)}, 500)

    def do_POST(self):
        path = urlparse(self.path).path
        length = int(self.headers.get("Content-Length", 0))
        try:
            payload = json.loads(self.rfile.read(length).decode("utf-8")) if length else {}
            if path == "/api/rebuild-index":
                self._json(build_corresp_index())
                return
            m = re.match(r"^/api/file/([^/]+)/revision-change$", path)
            if m:
                self._json(add_revision_change(m.group(1), payload["who"]))
                return
            m = re.match(r"^/api/file/([^/]+)/set-place$", path)
            if not m:
                self.send_error(404)
                return
            self._json(set_action_place_by_type(
                m.group(1), payload.get("type", "sent"), payload.get("ref"), payload.get("text"),
                pmb=payload.get("pmb")))
        except (KeyError, ValueError, TypeError, json.JSONDecodeError) as e:
            self._json({"error": str(e)}, 400)
        except FileNotFoundError as e:
            self._json({"error": str(e)}, 404)
        except Exception as e:  # noqa: BLE001
            self._json({"error": str(e)}, 500)


def main():
    ap = argparse.ArgumentParser(description="Absenderort-Tool")
    ap.add_argument("--port", type=int, default=8878)
    ap.add_argument("--no-open", action="store_true", help="Browser nicht automatisch öffnen")
    ap.add_argument("--rebuild-index", action="store_true",
                    help="meta/orte_aus_correspaction.json neu erstellen und beenden")
    args = ap.parse_args()
    if not sa.EDITIONS.is_dir():
        sys.exit(f"editions/ nicht gefunden unter {sa.REPO}")
    if args.rebuild_index:
        print(build_corresp_index())
        return

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    url = f"http://127.0.0.1:{args.port}/"
    print(f"Absenderort-Tool läuft auf {url}  (Strg-C oder 'Beenden' zum Beenden)")
    if not args.no_open:
        webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()


if __name__ == "__main__":
    main()
