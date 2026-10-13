#!/usr/bin/env python3
"""
Ort-Abgleich: war Arthur Schnitzler an dem Tag überhaupt dort?

Läuft (nur lesend) über editions/L*.xml und prüft jedes correspAction, in dem
Schnitzler (#pmb2121 bzw. GND 118609807) steht, auf seine placeName/@ref:
Ist der Ort laut dem Wiener Schnitzler (verschachtelte Fassung, mit allen
Ebenen: Ort > Hotel ...) am Datum der correspAction nachweisbar?

Ein Ort gilt als belegt, wenn an dem Tag
  - derselbe Ort verzeichnet ist,
  - der Ort in einem verzeichneten Ort liegt (Brief aus dem Hotel, verzeichnet
    ist die Stadt; Hierarchie aus indices/listplace.xml und der Verschachtelung
    der Aufenthaltsdaten), oder
  - der Ort einen verzeichneten Ort enthält (Brief aus "Wien", verzeichnet ist
    eine Wiener Adresse).
In Wien kommen Schnitzlers Wohnadressen (meta/wohnadressen.json) hinzu.

Datum: gültiges @when (hat Vorrang), sonst notBefore/from bis notAfter/to.
Zeiträume mit mehr als 10 Tagen werden übersprungen (--max-tage). Bei einem
Zeitraum genügt ein einziger Tag mit Treffer.

Ausgabe: Liste der zu prüfenden Dateien, nach Befund gruppiert.
  ABWEICHUNG  Für alle Tage gibt es Aufenthaltsdaten, der Ort ist an keinem belegt.
  UNKLAR      Der Ort ist nicht belegt, aber für einzelne Tage fehlen Daten.
Einzeltage ohne Aufenthaltsdaten werden nur gezählt.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 python/ort_abgleich.py [--csv pruefung/ort-abgleich.csv] [--nur L04318 ...]
    python3 python/ort_abgleich.py --nested /pfad/wienerschnitzler_complete_nested.xml
"""

import argparse
import csv
import json
import re
import sys
from datetime import date, timedelta
from pathlib import Path
from urllib.request import urlopen

from lxml import etree

REPO = Path(__file__).resolve().parent.parent
EDITIONS = REPO / "editions"
LISTPLACE = REPO / "indices" / "listplace.xml"
WOHNADRESSEN = REPO / "meta" / "wohnadressen.json"
DEFAULT_NESTED = REPO.parent / "wienerschnitzler-data" / "data" / "editions" / "xml" / "wienerschnitzler_complete_nested.xml"
NESTED_URL = ("https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/"
              "refs/heads/main/data/editions/xml/wienerschnitzler_complete_nested.xml")

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
T = "{http://www.tei-c.org/ns/1.0}"
SCHNITZLER_REFS = {"#pmb2121", "https://d-nb.info/gnd/118609807"}
WIEN = "pmb50"
PMB_RE = re.compile(r"^#?(?:pmb)?(\d+)$")


def pmb_id(ref):
    """'#pmb483' / '#59' / 'pmb483' -> 'pmb483'; alles andere -> None."""
    m = PMB_RE.match((ref or "").strip())
    return f"pmb{m.group(1)}" if m else None


def parse_date(s):
    try:
        return date.fromisoformat(s) if s and re.fullmatch(r"\d{4}-\d{2}-\d{2}", s) else None
    except ValueError:
        return None


def tage(d):
    """Alle Tage eines tei:date (siehe Modul-Docstring); [] bei ungenauem Datum."""
    when = parse_date(d.get("when"))
    if when:
        return [when]
    von = parse_date(d.get("notBefore")) or parse_date(d.get("from"))
    bis = parse_date(d.get("notAfter")) or parse_date(d.get("to"))
    if von and bis and von <= bis:
        return [von + timedelta(days=i) for i in range((bis - von).days + 1)]
    return []


# ---------------------------------------------------------------------------
# Daten laden
# ---------------------------------------------------------------------------

def load_nested(path):
    if path and Path(path).exists():
        return etree.parse(str(path)).getroot()
    print(f"{path} nicht gefunden, lade {NESTED_URL} ...", file=sys.stderr)
    with urlopen(NESTED_URL) as r:
        return etree.fromstring(r.read())


class Aufenthalte:
    """tag (ISO) -> (Menge aller Orte inkl. Zwischenebenen, {Ort: Name}); dazu die
    Eltern-Beziehungen aus der Verschachtelung."""

    def __init__(self, root):
        self.days = {}
        self.parents = {}  # pmbN -> Menge der Oberorte
        for ev in root.iter(T + "event"):
            when = ev.get("when")
            if not when:
                continue
            refs, names = set(), {}
            lp = ev.find(T + "listPlace")
            if lp is not None:
                for p in lp.findall(T + "place"):
                    self._walk(p, None, refs, names)
            self.days[when] = (refs, names)

    def _walk(self, place, parent, refs, names):
        pid = pmb_id(place.get("corresp"))
        if pid:
            refs.add(pid)
            nm = place.find(T + "placeName")
            if nm is not None and nm.text:
                names[pid] = nm.text.strip()
            if parent:
                self.parents.setdefault(pid, set()).add(parent)
        lp = place.find(T + "listPlace")
        if lp is not None:
            for c in lp.findall(T + "place"):
                self._walk(c, pid or parent, refs, names)


def load_listplace_parents():
    parents = {}
    root = etree.parse(str(LISTPLACE)).getroot()
    for pl in root.iter(T + "place"):
        xid = pl.get("{http://www.w3.org/XML/1998/namespace}id")
        if not xid:
            continue
        for loc in pl.findall(T + "location"):
            if loc.get("type") != "located_in_place":
                continue
            nm = loc.find(T + "placeName")
            key = pmb_id(nm.get("key")) if nm is not None else None
            if key:
                parents.setdefault(xid, set()).add(key)
    return parents


def load_wohnungen():
    try:
        data = json.loads(WOHNADRESSEN.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return []
    return [e for e in data if e["personRef"] == "#pmb2121"]


def wohnungen_am(wohnungen, tag):
    iso = tag.isoformat()
    return {pmb_id(e["placeRef"]) for e in wohnungen
            if (not e["start"] or e["start"] <= iso) and (not e["end"] or iso <= e["end"])}


class Hierarchie:
    def __init__(self, *parent_maps):
        self.maps = parent_maps
        self._cache = {}

    def ancestors(self, pid):
        if pid in self._cache:
            return self._cache[pid]
        seen, stack = set(), [pid]
        while stack:
            cur = stack.pop()
            for m in self.maps:
                for p in m.get(cur, ()):
                    if p not in seen:
                        seen.add(p)
                        stack.append(p)
        self._cache[pid] = seen
        return seen


# ---------------------------------------------------------------------------
# Prüfung
# ---------------------------------------------------------------------------

def beleg(ort, refs, hier):
    """Ist `ort` (pmbN) gegenüber der Orte-Menge `refs` eines Tages belegt?"""
    if ort in refs:
        return True
    if hier.ancestors(ort) & refs:  # Brief aus einem Ort innerhalb eines verzeichneten Ortes
        return True
    return any(ort in hier.ancestors(r) for r in refs)  # Brief aus dem Oberort


def pruefe(ort, tag_liste, aufenthalte, wohnungen, hier):
    """-> (status, belegte_tage, tage_ohne_daten, orte_der_tage)"""
    ohne_daten, orte, treffer = 0, {}, 0
    for tag in tag_liste:
        eintrag = aufenthalte.days.get(tag.isoformat())
        if not eintrag:
            ohne_daten += 1
            continue
        refs, names = eintrag
        orte.update(names)
        verfuegbar = set(refs)
        if WIEN in refs:
            verfuegbar |= wohnungen_am(wohnungen, tag)
        if beleg(ort, verfuegbar, hier):
            treffer += 1
    if treffer:
        status = "ok"
    elif ohne_daten == len(tag_liste):
        status = "keine-daten"
    elif ohne_daten:
        status = "unklar"
    else:
        status = "abweichung"
    return status, treffer, ohne_daten, orte


def namen_der_tage(tag_liste, aufenthalte, limit=6):
    """Namen der verzeichneten Orte (nur tiefste Ebene je Tag reicht nicht - hier alle,
    ohne Wiener Bezirke) für die Anzeige."""
    gesammelt = []
    for tag in tag_liste:
        eintrag = aufenthalte.days.get(tag.isoformat())
        if not eintrag:
            continue
        for pid, nm in eintrag[1].items():
            if nm not in gesammelt:
                gesammelt.append(nm)
    return gesammelt[:limit] + (["…"] if len(gesammelt) > limit else [])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--nested", default=str(DEFAULT_NESTED),
                    help="Pfad zu wienerschnitzler_complete_nested.xml (sonst Download)")
    ap.add_argument("--max-tage", type=int, default=10, help="längere Zeiträume überspringen (Standard 10)")
    ap.add_argument("--csv", help="Befunde zusätzlich als CSV schreiben")
    ap.add_argument("--nur", nargs="*", help="nur diese Briefe, z. B. L04318 oder 4318")
    args = ap.parse_args()

    aufenthalte = Aufenthalte(load_nested(args.nested))
    hier = Hierarchie(load_listplace_parents(), aufenthalte.parents)
    wohnungen = load_wohnungen()

    if args.nur:
        files = [EDITIONS / ("L%05d.xml" % int(re.sub(r"\D", "", n))) for n in args.nur]
    else:
        files = sorted(EDITIONS.glob("L*.xml"))

    zaehler = {"geprueft": 0, "ok": 0, "keine-daten": 0, "zeitraum-zu-lang": 0, "ungenaues-datum": 0,
               "kein-pmb-ort": 0}
    befunde = []
    for f in files:
        try:
            root = etree.parse(str(f)).getroot()
        except (OSError, etree.XMLSyntaxError) as e:
            print(f"{f.name}: {e}", file=sys.stderr)
            continue
        for ca in root.iterfind(".//tei:correspAction", NS):
            if not any(p.get("ref") in SCHNITZLER_REFS for p in ca.findall("tei:persName", NS)):
                continue
            d = ca.find("tei:date", NS)
            for pn in ca.findall("tei:placeName", NS):
                ort = pmb_id(pn.get("ref"))
                if not ort:
                    zaehler["kein-pmb-ort"] += 1
                    continue
                tl = tage(d) if d is not None else []
                if not tl:
                    zaehler["ungenaues-datum"] += 1
                    continue
                if len(tl) > args.max_tage:
                    zaehler["zeitraum-zu-lang"] += 1
                    continue
                zaehler["geprueft"] += 1
                status, treffer, ohne, _ = pruefe(ort, tl, aufenthalte, wohnungen, hier)
                if status in ("ok", "keine-daten"):
                    zaehler[status] += 1
                    continue
                befunde.append({
                    "datei": f.name,
                    "status": status.upper(),
                    "action": ca.get("type"),
                    "datum": f"{tl[0]}" if len(tl) == 1 else f"{tl[0]}–{tl[-1]}",
                    "tage_ohne_daten": ohne,
                    "brief_ort": (" ".join("".join(pn.itertext()).split()) or "?"),
                    "brief_ref": pn.get("ref"),
                    "evidence": pn.get("evidence") or "",
                    "laut_wienerschnitzler": "; ".join(namen_der_tage(tl, aufenthalte)),
                })

    for status in ("ABWEICHUNG", "UNKLAR"):
        gruppe = [b for b in befunde if b["status"] == status]
        print(f"\n=== {status}: {len(gruppe)} Eintrag/Einträge in {len({b['datei'] for b in gruppe})} Datei(en) ===")
        for b in gruppe:
            extra = f" [{b['tage_ohne_daten']} Tag(e) ohne Daten]" if b["tage_ohne_daten"] else ""
            ev = f" ({b['evidence']})" if b["evidence"] else ""
            print(f"{b['datei']}  {b['action']:<8} {b['datum']}  Brief: {b['brief_ort']} {b['brief_ref']}{ev}"
                  f"  |  Wienerschnitzler: {b['laut_wienerschnitzler']}{extra}")

    print("\n--- Dateien zur Prüfung ---")
    print(" ".join(sorted({b["datei"] for b in befunde})))
    print("\n--- Zählung ---")
    for k, v in zaehler.items():
        print(f"{k:>18}: {v}")

    if args.csv:
        Path(args.csv).parent.mkdir(parents=True, exist_ok=True)
        with open(args.csv, "w", encoding="utf-8", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(befunde[0].keys()) if befunde else ["datei"])
            w.writeheader()
            w.writerows(befunde)
        print(f"\nCSV: {args.csv}")


if __name__ == "__main__":
    main()
