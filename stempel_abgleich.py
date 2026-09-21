#!/usr/bin/env python3
"""
Stempel-Abgleich-Tool.

Lokaler Web-Server mit einer Zwei-Spalten-Oberfläche zum Abgleich von
Poststempeln (physDesc//additions/incident[@type='postal']/desc/stamp) mit
den correspAction-Einträgen (correspDesc/correspAction) in editions/*.xml.

Links werden alle Stempel eines Briefs angezeigt, rechts alle correspAction.
Für jeden Stempel wird der passende correspAction-Typ vorgeschlagen
(transmission→transmitted, delivery→delivered, redirection→redirected,
arrival→arrived, transit→in_transit). Man kann daraus entweder eine neue correspAction
einfügen oder Datum/Ort einer bestehenden correspAction aus dem Stempel
übernehmen ("matchen"). Ein Button öffnet die Datei zusätzlich auf
schnitzler-briefe.acdh.oeaw.ac.at.

Jede Schreiboperation prüft danach, ob das Ergebnis noch wohlgeformtes XML
ist (siehe validate_and_save) - eine echte Prüfung gegen das TEI-Schema
(meta/schnitzler-briefe-schema.xsd) findet nicht statt, weil es an einer
Stelle maxOccurs>1 innerhalb von xs:all nutzt, ein XSD-1.1-Feature, das die
hier verwendete Standardbibliothek nicht kennt.

Braucht außer Python 3 (Standardbibliothek, kein pip install nötig) nur
Java + saxon/saxon-he-9.9.1-7.jar, und auch das nur für den Button
"Datum unsicher (±1 Tag)".

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
import tempfile
import webbrowser
from datetime import date
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

import xml.etree.ElementTree as etree

# ---------------------------------------------------------------------------
# Konfiguration
# ---------------------------------------------------------------------------
REPO = Path(__file__).resolve().parent
EDITIONS = REPO / "editions"
SCHEMA_PATH = REPO / "meta" / "schnitzler-briefe-schema.xsd"
STATIC_DIR = REPO / "stempel_abgleich_static"
HTML_BASE = "https://schnitzler-briefe.acdh.oeaw.ac.at/{fid}.html"
OXYGEN_APP = "/Applications/Oxygen XML Editor/Oxygen XML Editor.app"
SAXON_JAR = REPO / "saxon" / "saxon-he-9.9.1-7.jar"
XSLT_DATE_UNCERTAIN = REPO / "xslts" / "brief_normalisierungen" / "brief_normalisierung_datum-plusminus-1-tag.xsl"
WOHNADRESSEN_PATH = REPO / "meta" / "wohnadressen.json"
AUFENTHALTE_PATH = REPO / "meta" / "aufenthalte.json"
ARTHUR_SCHNITZLER_REF = "#pmb2121"

TEI_NS = "http://www.tei-c.org/ns/1.0"
NS = {"tei": TEI_NS}

STAMP_TO_ACTION = {
    "transmission": "transmitted",
    "delivery": "delivered",
    "redirection": "redirected",
    "arrival": "arrived",
    "transit": "in_transit",
}
STAMP_TYPES = ("non-postal", "arrival", "transmission", "redirection", "delivery", "transit", "other")
ACTION_TYPE_ORDER = ["sent", "transmitted", "redirected", "in_transit", "arrived", "delivered", "received"]
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
TITLE_A_RE = re.compile(r'<title level="a">.*?</title>', re.S)
REVISION_DESC_RE = re.compile(r'<revisionDesc\b[^>]*>.*?</revisionDesc>', re.S)
CHANGE_RE = re.compile(r'<change\b[^>]*(?:/>|>.*?</change>)', re.S)
EDITORS = ("SJ", "MAM")
CHANGE_DATIERUNG_STEMPEL_TEXT = "Datierung und Stempel überprüft"
REVIEWED_MARKER_RE = re.compile(re.escape(f">{CHANGE_DATIERUNG_STEMPEL_TEXT}</change>"))
PERSNAME_RE = re.compile(r'<persName\b[^>]*>.*?</persName>', re.S)

_schema_warned = False


def get_schema():
    """Liefert immer None: die Python-Standardbibliothek (xml.etree, ohne
    lxml-Abhängigkeit, damit das Tool ohne Installation läuft) kann keine
    XSD-Schemata validieren. Schreibaktionen prüfen dadurch nur noch auf
    Wohlgeformtheit (siehe validate_and_save) - das Projektschema nutzte
    ohnehin schon vorher maxOccurs>1 innerhalb von xs:all, ein
    XSD-1.1-Feature, das auch lxml/libxml2 (nur XSD 1.0) nicht validieren
    konnte, echte Schema-Validierung fand also auch damit nie statt."""
    global _schema_warned
    if not _schema_warned:
        _schema_warned = True
        print("Hinweis: Schema-Validierung ist ohne lxml nicht verfügbar; "
              "es wird nur auf Wohlgeformtheit geprüft.", file=sys.stderr)
    return None


# ---------------------------------------------------------------------------
# Lesen / Extrahieren (xml.etree, namespace-bewusst)
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
        date_el = s.find(q("date"))
        date_dict = extract_date(date_el)
        has_gap, has_supplied, _ = stamp_date_field_flags(date_el)
        stamps.append({
            "index": i,
            "n": s.get("n"),
            "type": s.get("type"),
            "attrs": dict(s.attrib),
            "place": extract_place(s.find(q("placeName"))),
            "date": date_dict,
            "time": norm_text(s.find(q("time"))) or None,
            "suggestedType": STAMP_TO_ACTION.get(s.get("type")),
            "dateHasGap": has_gap,
            "dateHasSupplied": has_supplied,
            "dateNormalizedPreview": format_normalized_stamp_date(date_dict, date_el),
        })
    return stamps


def extract_corresp_actions(root):
    actions = []
    for i, a in enumerate(root.iter(q("correspAction"))):
        persons = [{"text": norm_text(p), "ref": p.get("ref")} for p in a.findall(q("persName"))]
        date_dict = extract_date(a.find(q("date")))
        action_type = a.get("type")
        actions.append({
            "index": i,
            "type": action_type,
            "attrs": dict(a.attrib),
            "persons": persons,
            "date": date_dict,
            "place": extract_place(a.find(q("placeName"))),
            "residenceOptions": (
                residence_options_for_action(persons, date_dict) if action_type == "sent" else []),
        })
    return actions


_wohnadressen = None  # personRef -> Liste von {placeRef, placeName, start, end}, lazy geladen


def load_wohnadressen():
    """Kurzfassung der "wohnhaft in"-Relationen aus relations.csv (siehe
    meta/wohnadressen_aus_relations.py) - liegt als kleine, committete
    JSON-Datei vor, weil relations.csv selbst (52 MB, PMB-Export) nicht im
    Repo ist. Fehlt die Datei, wird einfach nichts vorgeschlagen."""
    global _wohnadressen
    if _wohnadressen is None:
        _wohnadressen = {}
        try:
            with WOHNADRESSEN_PATH.open(encoding="utf-8") as f:
                entries = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            entries = []
        for e in entries:
            _wohnadressen.setdefault(e["personRef"], []).append(e)
    return _wohnadressen


_aufenthalte = None


def load_aufenthalte():
    """Tage, an denen Arthur Schnitzler laut dem Wiener-Schnitzler-Projekt
    nicht (nur) in Wien war, mit den dafür verzeichneten Orten (siehe
    meta/aufenthalte_aus_wienerschnitzler.py) - ergänzt die Wohnadressen um
    die Reisetage. Fehlt die Datei, wird einfach nichts vorgeschlagen."""
    global _aufenthalte
    if _aufenthalte is None:
        try:
            with AUFENTHALTE_PATH.open(encoding="utf-8") as f:
                _aufenthalte = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            _aufenthalte = {}
    return _aufenthalte


def _best_date_for_filter(date_dict):
    if not date_dict:
        return None
    return date_dict.get("when") or date_dict.get("notBefore") or date_dict.get("notAfter")


def residence_options_for_action(persons, date_dict):
    """Wohnadressen der genannten Personen (persName/@ref), deren Zeitraum
    das Datum der correspAction plausibel einschließt - "nur
    berücksichtigen, wenn der Brief tatsächlich aus dem Ort versandt wurde"
    (siehe meta/wohnadressen_aus_relations.py). Ist Arthur Schnitzler unter
    den genannten Personen und gibt es ein exaktes @when, kommen zusätzlich
    (zuerst, weil genauer) seine an diesem Tag verzeichneten Aufenthalte
    außerhalb Wiens dazu (siehe meta/aufenthalte_aus_wienerschnitzler.py).
    Ohne brauchbares Datum oder ohne genannte Person(en) wird nichts
    vorgeschlagen; fehlender Beginn/Ende einer Wohnadresse in den Daten
    gilt als offene Grenze."""
    when = _best_date_for_filter(date_dict)
    if not when or not persons:
        return []
    seen = set()
    options = []

    exact_when = (date_dict or {}).get("when")
    if exact_when and any(p.get("ref") == ARTHUR_SCHNITZLER_REF for p in persons):
        for entry in load_aufenthalte().get(exact_when, []):
            key = entry["ref"]
            if key in seen:
                continue
            seen.add(key)
            options.append({"ref": entry["ref"], "text": entry["text"], "kind": "aufenthalt"})

    addresses = load_wohnadressen()
    for p in persons:
        ref = p.get("ref")
        if not ref:
            continue
        for entry in addresses.get(ref, []):
            if entry["start"] and when < entry["start"]:
                continue
            if entry["end"] and when > entry["end"]:
                continue
            key = entry["placeRef"]
            if key in seen:
                continue
            seen.add(key)
            options.append({"ref": entry["placeRef"], "text": entry["placeName"], "kind": "wohnadresse"})
    return options


def attach_raw(items, text, tag):
    raws = [m.group(0) for m in RAW_BLOCK_RE[tag].finditer(text)]
    if len(raws) != len(items):
        raise ValueError(
            f"Interner Zählfehler bei <{tag}>: {len(items)} über Baum-Suche, "
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


def extract_title(root):
    title = root.find(f".//{q('titleStmt')}/{q('title')}[@level='a']")
    return norm_text(title) if title is not None else None


def _walk_place_candidate_nodes(elem, in_address, in_postal, in_addrline, in_opener, out):
    """Rekursiver Baum-Durchlauf in Dokumentreihenfolge (Ersatz für die
    lxml-XPath-Vereinigung ".//div[@type=address]//placeName |
    .//incident[@type=postal]//placeName |
    .//div[@type=address]/address/addrLine/descendant::rs[@type=place] |
    .//opener/descendant::rs[@type=place]" -
    xml.etree kennt keine XPath-Vereinigung, dafür läuft es ohne separat
    zu installierendes lxml)."""
    name = local_name(elem.tag)
    in_address = in_address or (name == "div" and elem.get("type") == "address")
    in_postal = in_postal or (name == "incident" and elem.get("type") == "postal")
    in_addrline = in_addrline or (in_address and name == "addrLine")
    in_opener = in_opener or (name == "opener")

    if name == "placeName" and (in_address or in_postal):
        out.append(elem)
    elif name == "rs" and (in_addrline or in_opener) and elem.get("type") == "place":
        out.append(elem)

    for child in elem:
        _walk_place_candidate_nodes(child, in_address, in_postal, in_addrline, in_opener, out)


def extract_place_candidates(root):
    """Alle placeName aus der Adresse (div[@type='address']) und den
    Poststempeln (incident[@type='postal']), dazu die rs[@type='place'] in
    den addrLine der Adresse und im opener (dort werden Orte oft so statt
    als placeName ausgezeichnet) - als Auswahlliste, aus der Orte für
    correspAction übernommen werden können. Dedupliziert nach @ref (bzw.
    nach Text, wenn kein ref vorhanden ist), erster Fund zählt."""
    nodes = []
    _walk_place_candidate_nodes(root, False, False, False, False, nodes)
    seen = set()
    options = []
    for el in nodes:
        ref = el.get("ref")
        text = norm_text(el)
        key = ref or text
        if not key or key in seen:
            continue
        seen.add(key)
        options.append({"ref": ref, "text": text})
    return options


def build_file_payload(fid):
    text = load_text(fid)
    root = parse_root(text)
    stamps = attach_raw(extract_stamps(root), text, "stamp")
    actions = attach_raw(extract_corresp_actions(root), text, "correspAction")
    return {
        "id": fid,
        "htmlUrl": HTML_BASE.format(fid=fid),
        "title": extract_title(root),
        "stamps": stamps,
        "correspActions": actions,
        "placeOptions": extract_place_candidates(root),
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
        "reviewed": bool(REVIEWED_MARKER_RE.search(text)),
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
# bleibt unangetastet; xml.etree wird nur zur Wohlgeformtheitsprüfung benutzt)
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
        etree.fromstring(new_text.encode("utf-8"))
    except etree.ParseError as e:
        raise ValueError(f"Ergebnis ist kein wohlgeformtes XML: {e}")

    get_schema()  # nur für den einmaligen Hinweis, dass keine Schema-Validierung stattfindet

    path = EDITIONS / f"{fid}.xml"
    with path.open("w", encoding="utf-8", newline="") as f:
        f.write(new_text)
    refresh_candidate(fid)


_INDENT_WS_RE = re.compile(r"\s*\n\s*")


def _strip_pretty_print_ws(s):
    """Entfernt reinen Pretty-Print-Zeilenumbruch samt Einrückung (immer
    an einem \\n erkennbar), belässt aber echte, inline getippte
    Trennzeichen wie ein einzelnes Leerzeichen zwischen Tag und Monat."""
    return _INDENT_WS_RE.sub("", s)


def _collect_chars_with_supplied_flag(el, supplied):
    """Flache Liste aus (Zeichen, ist_innerhalb_von_supplied) für den
    gesamten Text-Inhalt von el (rekursiv, inkl. tail-Text von Kindern,
    dem jeweils der supplied-Status des Elternelements zugeordnet wird,
    da tail-Text außerhalb des Kindelements liegt). Pretty-Print-Umbrüche
    zwischen z. B. <unclear> und <supplied> werden herausgefiltert, damit
    sie nicht fälschlich als Tag/Monat/Jahr-Trenner gezählt werden."""
    chars = []
    is_supplied_here = supplied or local_name(el.tag) == "supplied"
    if el.text:
        chars.extend((c, is_supplied_here) for c in _strip_pretty_print_ws(el.text))
    for child in el:
        chars.extend(_collect_chars_with_supplied_flag(child, is_supplied_here))
        if child.tail:
            chars.extend((c, is_supplied_here) for c in _strip_pretty_print_ws(child.tail))
    return chars


MONTH_NAME_TOKENS = {
    1: ("jan",), 2: ("feb",), 3: ("mär", "mar", "mrz"), 4: ("apr",),
    5: ("mai", "may"), 6: ("jun",), 7: ("jul",), 8: ("aug",),
    9: ("sep",), 10: ("okt", "oct"), 11: ("nov",), 12: ("dez", "dec"),
}


def stamp_date_field_flags(date_el, day=None, month=None, year=None):
    """Ermittelt für ein stamp/date-Element:
    - hasGap: enthält irgendwo ein <gap>
    - hasSupplied: enthält irgendwo ein <supplied>
    - field_supplied: je ein bool für Tag/Monat/Jahr - True, wenn die im
      Text stehende Ziffernfolge für genau diesen (aus @when bekannten)
      Wert mindestens teilweise innerhalb eines <supplied> liegt. Nur
      gesetzt, wenn day/month/year übergeben werden.

      Gesucht wird gezielt nach dem jeweils erwarteten Wert (arabisch,
      mit und ohne führende Null; beim Jahr zusätzlich als zweistelliges
      Fragment) in der Ziffern-Teilfolge des Texts, von links nach
      rechts, je Feld ab der Fundstelle des vorherigen Felds weitersuchend.
      Das bleibt auch robust, wenn eine Stelle im Text gar keine Ziffern
      hat (<gap>, römische Monatszahl) - dann wird für dieses Feld
      einfach nichts markiert, statt eine andere Stelle fälschlich als
      "das ist der supplied-Teil" zu deuten."""
    if date_el is None:
        return False, False, [False, False, False]

    has_gap = date_el.find(f".//{q('gap')}") is not None
    chars = _collect_chars_with_supplied_flag(date_el, False)
    has_supplied = any(s for _, s in chars)

    field_supplied = [False, False, False]
    if day is not None and month is not None and year is not None:
        digit_chars = [(c, s) for c, s in chars if c.isdigit()]
        digits_str = "".join(c for c, _ in digit_chars)
        candidates_per_field = [
            [str(day), f"{day:02d}"],
            [str(month), f"{month:02d}"],
            [str(year), f"{year % 100:02d}"],
        ]
        cursor = 0
        month_found = False
        for i, candidates in enumerate(candidates_per_field):
            for cand in dict.fromkeys(candidates):  # dedupe, Reihenfolge erhalten
                pos = digits_str.find(cand, cursor)
                if pos != -1:
                    field_supplied[i] = any(s for _, s in digit_chars[pos:pos + len(cand)])
                    cursor = pos + len(cand)
                    if i == 1:
                        month_found = True
                    break

        # Fallback für als Monatsnamen geschriebene Monate (z. B. "Nov",
        # "Sep") - da nicht als Ziffer im Text, verpasst die Digit-Suche
        # oben das grundsätzlich; hier nur EIN Name-Token gesucht (nicht
        # cursor-geführt wie bei den Ziffern, da Name und Ziffern in
        # unterschiedlichen Projektionen des Texts gesucht werden).
        if not month_found:
            text_lower = "".join(c for c, _ in chars).lower()
            for token in MONTH_NAME_TOKENS.get(month, ()):
                pos = text_lower.find(token)
                if pos != -1:
                    field_supplied[1] = any(s for _, s in chars[pos:pos + len(token)])
                    break

    return has_gap, has_supplied, field_supplied


def format_normalized_stamp_date(date, date_el):
    """(D)D.&#160;(M)M.&#160;JJJJ aus @when, ohne führende Nullen bei Tag/
    Monat - das in diesem Projekt übliche Muster für normierte
    Datumsangaben (vgl. z. B. editions/L00015.xml). Nur der Teil (Tag,
    Monat und/oder Jahr), der im stamp/date auf einem <supplied> beruht,
    bekommt eckige Klammern - nicht die ganze Wiedergabe. Sind mehrere
    Felder in Folge supplied (z. B. Tag+Monat gemeinsam in einem
    <supplied>), bekommen sie EINE gemeinsame Klammer statt je einer
    eigenen (["15.&#160;8"] statt [15].&#160;[8]) - nicht zusammenhängend
    supplied-e Felder (z. B. Tag+Jahr ohne Monat) bekommen weiterhin
    getrennte Klammern. <gap> fließt hier nicht mehr ein (siehe
    stamp_date_field_flags/dateHasGap: das steuert stattdessen eine
    Rückfrage im Frontend)."""
    when = (date or {}).get("when")
    if not when:
        return None
    m = re.match(r"^(\d{4})-(\d{2})-(\d{2})$", when)
    if not m:
        return None
    year, month, day = int(m.group(1)), int(m.group(2)), int(m.group(3))
    _, _, field_supplied = stamp_date_field_flags(date_el, day, month, year)
    values = [str(day), str(month), str(year)]
    sep = ".&#160;"

    parts = []
    i = 0
    while i < 3:
        if field_supplied[i]:
            j = i
            while j + 1 < 3 and field_supplied[j + 1]:
                j += 1
            parts.append("[" + sep.join(values[i:j + 1]) + "]")
            i = j + 1
        else:
            parts.append(values[i])
            i += 1
    return sep.join(parts)


def build_date_elem(date, date_el=None, normalize=False):
    if not date or not (date.get("text") or date.get("when")):
        return None
    attrs = ""
    if date.get("when"):
        attrs += f' when="{escape_attr(date["when"])}"'
    if date.get("notBefore"):
        attrs += f' notBefore="{escape_attr(date["notBefore"])}"'
    if date.get("notAfter"):
        attrs += f' notAfter="{escape_attr(date["notAfter"])}"'
    if normalize:
        normalized = format_normalized_stamp_date(date, date_el)
        if normalized is not None:
            return f'<date{attrs}>{normalized}</date>'
    text = date.get("text") or ""
    if not text:
        return f'<date{attrs}/>'
    return f'<date{attrs}>{escape_text(text)}</date>'


def build_place_elem(place):
    if not place or not place.get("text"):
        return None
    ref_attr = f' ref="{escape_attr(place["ref"])}"' if place.get("ref") else ""
    return f'<placeName{ref_attr}>{escape_text(place["text"])}</placeName>'


_AUTO_DATE = object()  # Sentinel: automatische Normierung (Default)


def insert_corresp_action(fid, stamp_index, target_type, date_override=_AUTO_DATE):
    """date_override steuert, was als <date> in die neue correspAction
    kommt:
    - _AUTO_DATE (Default): automatisch normierte Wiedergabe aus dem
      Stempel (siehe format_normalized_stamp_date).
    - None: kein <date>-Element (z. B. wenn der Stempel eine Lücke/gap
      hat und im Frontend "kein Datum" gewählt wurde).
    - ein String: dieser Text wird wörtlich übernommen (freie Eingabe im
      Frontend-Popup), @when/@notBefore/@notAfter bleiben trotzdem vom
      Stempel erhalten, sofern vorhanden."""
    if target_type not in ACTION_RANK:
        raise ValueError(f"unbekannter correspAction-Typ: {target_type}")
    text = load_text(fid)
    root = parse_root(text)
    stamps = extract_stamps(root)
    if not (0 <= stamp_index < len(stamps)):
        raise ValueError("ungültiger Stempel-Index")
    stamp = stamps[stamp_index]
    stamp_els = list(root.iter(q("stamp")))
    stamp_date_el = stamp_els[stamp_index].find(q("date")) if stamp_index < len(stamp_els) else None

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
    if date_override is _AUTO_DATE:
        date_elem = build_date_elem(stamp.get("date"), date_el=stamp_date_el, normalize=True)
    elif date_override is None or not str(date_override).strip():
        date_elem = None
    else:
        override_date = dict(stamp.get("date") or {})
        override_date["text"] = str(date_override).strip()
        date_elem = build_date_elem(override_date)
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
        new_block_text = apply_place_to_block(new_block_text, child_indent, new_place_elem)

    new_text = text[:block.start()] + new_block_text + text[block.end():]
    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


def _place_insert_pos(block_text):
    date_matches = list(DATE_CHILD_RE.finditer(block_text))
    if date_matches:
        return date_matches[-1].end()
    pers_matches = list(PERSNAME_RE.finditer(block_text))
    if pers_matches:
        return pers_matches[-1].end()
    open_line = re.match(r'[^\n]*\n', block_text)
    return open_line.end() if open_line else 0


def apply_place_to_block(block_text, child_indent, new_place_elem):
    """Ersetzt die placeName eines correspAction-Blocks (Textform) durch
    new_place_elem, oder fügt sie an der schema-korrekten Stelle ein
    (nach persName/date, vor dem schließenden Tag), falls noch keine da ist."""
    if PLACE_CHILD_RE.search(block_text):
        return PLACE_CHILD_RE.sub(lambda m: new_place_elem, block_text, count=1)
    pos = _place_insert_pos(block_text)
    return block_text[:pos] + f'\n{child_indent}{new_place_elem}' + block_text[pos:]


def set_action_place(fid, action_index, place_index, source="candidate"):
    """Übernimmt einen Ort als placeName einer bestehenden correspAction.
    source="candidate" (Default): aus extract_place_candidates (Adresse/
    Poststempel). source="residence": aus den Wohnadressen der genannten
    Personen zum Datum der correspAction (siehe residence_options_for_action)
    - für correspAction[@type='sent'] gedacht. Beide Kandidatenlisten
    werden hier frisch aus der Datei neu berechnet, nicht vom Client
    übernommen."""
    text = load_text(fid)
    root = parse_root(text)
    actions = extract_corresp_actions(root)
    if not (0 <= action_index < len(actions)):
        raise ValueError("ungültiger correspAction-Index")

    if source == "residence":
        action = actions[action_index]
        candidates = residence_options_for_action(action["persons"], action["date"])
    elif source == "candidate":
        candidates = extract_place_candidates(root)
    else:
        raise ValueError(f"unbekannte Orts-Quelle: {source}")
    if not (0 <= place_index < len(candidates)):
        raise ValueError("ungültiger Orts-Index")

    blocks = list(CORRESP_ACTION_RE.finditer(text))
    if action_index >= len(blocks):
        raise ValueError("correspAction nicht gefunden")
    block = blocks[action_index]
    block_text = block.group(0)

    indent = indent_of(text, block.start())
    child_m = re.search(r'\n([ \t]+)<\w', block_text)
    child_indent = child_m.group(1) if child_m else indent + "   "

    new_place_elem = build_place_elem(candidates[place_index])
    if not new_place_elem:
        raise ValueError("gewählter Ort hat keinen Text")
    new_block_text = apply_place_to_block(block_text, child_indent, new_place_elem)

    new_text = text[:block.start()] + new_block_text + text[block.end():]
    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


STAMP_OPEN_TAG_RE = re.compile(r'<stamp\b([^>]*)>')
STAMP_TYPE_ATTR_RE = re.compile(r'\btype="[^"]*"')
STAMP_N_ATTR_RE = re.compile(r'\bn="[^"]*"')


def set_stamp_type(fid, stamp_index, new_type):
    """Setzt (bzw. ergänzt, falls noch nicht vorhanden) das @type eines
    Stempels - für Stempel, die noch gar kein @type haben, gibt es sonst
    keine Möglichkeit, das über die Oberfläche statt per Hand im
    XML zu setzen."""
    if new_type not in STAMP_TYPES:
        raise ValueError(f"unbekannter Stempeltyp: {new_type}")

    text = load_text(fid)
    blocks = list(STAMP_RE.finditer(text))
    if not (0 <= stamp_index < len(blocks)):
        raise ValueError("ungültiger Stempel-Index")
    block = blocks[stamp_index]
    block_text = block.group(0)

    open_m = STAMP_OPEN_TAG_RE.match(block_text)
    if not open_m:
        raise ValueError("stamp-Starttag nicht gefunden")
    attrs = open_m.group(1)

    if STAMP_TYPE_ATTR_RE.search(attrs):
        new_attrs = STAMP_TYPE_ATTR_RE.sub(f'type="{escape_attr(new_type)}"', attrs, count=1)
    else:
        n_m = STAMP_N_ATTR_RE.search(attrs)
        insert_pos = n_m.end() if n_m else len(attrs)
        new_attrs = f'{attrs[:insert_pos]} type="{escape_attr(new_type)}"{attrs[insert_pos:]}'

    new_block_text = f'<stamp{new_attrs}>' + block_text[open_m.end():]
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
    except etree.ParseError as e:
        raise ValueError(f"XML-Fragment ist nicht wohlgeformt: {e}")

    text = load_text(fid)
    blocks = list(RAW_BLOCK_RE[tag].finditer(text))
    if not (0 <= index < len(blocks)):
        raise ValueError(f"ungültiger Index für {kind}")
    block = blocks[index]

    new_text = text[:block.start()] + new_xml + text[block.end():]
    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


def _run_saxon(input_path, xslt_path):
    if not SAXON_JAR.exists():
        raise ValueError(f"Saxon-JAR nicht gefunden unter {SAXON_JAR}")
    if not xslt_path.exists():
        raise ValueError(f"XSLT nicht gefunden unter {xslt_path}")
    with tempfile.TemporaryDirectory() as tmp_dir:
        out_path = Path(tmp_dir) / "out.xml"
        cmd = ["java", "-jar", str(SAXON_JAR), f"-s:{input_path}", f"-xsl:{xslt_path}", f"-o:{out_path}"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            msg = (result.stderr or result.stdout or "unbekannter Fehler").strip()
            raise ValueError(f"XSLT-Transformation fehlgeschlagen: {msg}")
        return out_path.read_text(encoding="utf-8")


def _xml_text_with_nbsp_entity(raw_text):
    """Wie escape_text, aber ein echtes NBSP-Zeichen (von Saxon aus '&#160;'
    im XSLT aufgelöst) wird für die Ablage zurück in die Entity-Schreibweise
    &#160; übersetzt - Editionskonvention, siehe z. B. editions/L00015.xml."""
    return escape_text(raw_text).replace(" ", "&#160;")


def apply_date_uncertain(fid):
    """Wendet xslts/brief_normalisierungen/brief_normalisierung_datum-plusminus-1-tag.xsl
    per Saxon an (Datum "±1 Tag unsicher": Titel und
    correspAction[@type='sent']/date bekommen die "[Vortag oder Tag]"-
    Notation, @when wird durch @notBefore/@notAfter ersetzt). Nur die
    dadurch tatsächlich geänderten Stellen werden chirurgisch in den
    Originaltext übernommen, damit der Rest der Datei (z. B. handformatierte
    mehrzeilige Start-Tags) nicht durch Saxons Serialisierung verändert wird."""
    text = load_text(fid)
    path = EDITIONS / f"{fid}.xml"
    if not path.exists():
        raise FileNotFoundError(f"{fid}.xml nicht gefunden")

    out_text = _run_saxon(path, XSLT_DATE_UNCERTAIN)
    out_root = etree.fromstring(out_text.encode("utf-8"))

    new_text = text

    new_title_el = out_root.find(f".//{q('titleStmt')}/{q('title')}[@level='a']")
    if new_title_el is not None:
        title_m = TITLE_A_RE.search(new_text)
        if title_m:
            new_title_block = f'<title level="a">{_xml_text_with_nbsp_entity(new_title_el.text or "")}</title>'
            new_text = new_text[:title_m.start()] + new_title_block + new_text[title_m.end():]

    new_date_el = out_root.find(
        f".//{q('correspDesc')}/{q('correspAction')}[@type='sent']/{q('date')}")
    if new_date_el is not None:
        blocks = list(CORRESP_ACTION_RE.finditer(new_text))
        sent_block = next(
            (b for b in blocks if TYPE_ATTR_RE.search(b.group(0)).group(1) == "sent"), None)
        if sent_block is not None:
            block_text = sent_block.group(0)
            date_m = DATE_CHILD_RE.search(block_text)
            if date_m:
                attrs_str = "".join(
                    f' {k}="{escape_attr(v)}"' for k, v in new_date_el.attrib.items())
                new_date_block = (
                    f'<date{attrs_str}>{_xml_text_with_nbsp_entity(new_date_el.text or "")}</date>')
                new_block_text = block_text[:date_m.start()] + new_date_block + block_text[date_m.end():]
                new_text = new_text[:sent_block.start()] + new_block_text + new_text[sent_block.end():]

    validate_and_save(fid, text, new_text)
    return build_file_payload(fid)


def add_revision_change(fid, who, change_text=CHANGE_DATIERUNG_STEMPEL_TEXT):
    """Ergänzt teiHeader/revisionDesc um einen neuen change-Eintrag, ans
    Ende der bestehenden change-Liste angehängt (chronologisch, wie in der
    Edition üblich)."""
    if who not in EDITORS:
        raise ValueError(f"unbekannter Bearbeiter: {who}")

    text = load_text(fid)
    rd_m = REVISION_DESC_RE.search(text)
    if not rd_m:
        raise ValueError("revisionDesc nicht gefunden")
    block = rd_m.group(0)

    new_change = f'<change who="{escape_attr(who)}" when="{date.today().isoformat()}">{escape_text(change_text)}</change>'

    changes = list(CHANGE_RE.finditer(block))
    if changes:
        last = changes[-1]
        indent = indent_of(block, last.start())
        insert_at = last.end()
        if block[insert_at:insert_at + 1] == "\n":
            insert_at += 1
        new_block = block[:insert_at] + f'{indent}{new_change}\n' + block[insert_at:]
    else:
        rd_indent = indent_of(text, rd_m.start())
        child_indent = rd_indent + "   "
        open_tag_end = block.index(">") + 1
        new_block = block[:open_tag_end] + f'\n{child_indent}{new_change}' + block[open_tag_end:]

    new_text = text[:rd_m.start()] + new_block + text[rd_m.end():]
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
            m = re.match(
                r"^/api/file/([^/]+)/"
                r"(insert|update|raw|set-place|set-stamp-type|date-uncertain|revision-change)$", path)
            if not m:
                self.send_error(404)
                return
            fid, action = m.group(1), m.group(2)
            if action == "insert":
                kwargs = {}
                if "dateOverride" in payload:
                    kwargs["date_override"] = payload["dateOverride"]
                result = insert_corresp_action(
                    fid, int(payload["stampIndex"]), payload["targetType"], **kwargs)
            elif action == "update":
                result = update_corresp_action(
                    fid, int(payload["stampIndex"]), int(payload["actionIndex"]))
            elif action == "set-place":
                result = set_action_place(
                    fid, int(payload["actionIndex"]), int(payload["placeIndex"]),
                    source=payload.get("source", "candidate"))
            elif action == "set-stamp-type":
                result = set_stamp_type(fid, int(payload["stampIndex"]), payload["type"])
            elif action == "date-uncertain":
                result = apply_date_uncertain(fid)
            elif action == "revision-change":
                result = add_revision_change(fid, payload["who"])
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
