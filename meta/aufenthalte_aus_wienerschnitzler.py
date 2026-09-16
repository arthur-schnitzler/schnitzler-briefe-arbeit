#!/usr/bin/env python3
"""
Erzeugt meta/aufenthalte.json - für jeden Tag, an dem Arthur Schnitzler laut
dem Wiener-Schnitzler-Projekt NICHT (nur) in Wien war, die dafür verzeichneten
Orte (jeweils die genaueste PMB-referenzierte Stelle der verschachtelten
listPlace-Hierarchie). Für die Auswahlliste bei correspAction[@type='sent']/
placeName im Stempel-Abgleich-Tool, ergänzend zu meta/wohnadressen.json
(Wohnadressen) - diese Datei deckt stattdessen die Reisetage ab.

Quelle: ../wienerschnitzler-data/data/editions/xml/wienerschnitzler_complete_nested.xml
(24 MB, nicht in diesem Repo) - die Kurzfassung hier wird committet, damit
das Tool auch ohne dieses Nachbar-Repo lokal läuft.

Aufruf (aus dem Repo-Wurzelverzeichnis, wenn die Quelldatei aktualisiert wurde):
    python3 meta/aufenthalte_aus_wienerschnitzler.py
    python3 meta/aufenthalte_aus_wienerschnitzler.py --source /pfad/zur/datei.xml
"""

import argparse
import json
import re
from pathlib import Path
import xml.etree.ElementTree as ET

REPO = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = REPO.parent / "wienerschnitzler-data" / "data" / "editions" / "xml" / "wienerschnitzler_complete_nested.xml"
OUT_PATH = REPO / "meta" / "aufenthalte.json"

TEI_NS = "http://www.tei-c.org/ns/1.0"
NS = f"{{{TEI_NS}}}"
WIEN_REF = "#pmb50"
PMB_REF_RE = re.compile(r"^#pmb\d+$")
WHEN_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def deepest_pmb_place(place_el):
    """Läuft die verschachtelte listPlace/place-Hierarchie ab place_el nach
    unten durch und liefert die TIEFSTE (genaueste) Stelle mit einer
    "richtigen" PMB-Referenz (#pmbNNN) - Wiener Bezirks-IDs wie "#52" sind
    keine PMB-Referenzen und werden übersprungen."""
    result = None
    corresp = place_el.get("corresp") or ""
    if PMB_REF_RE.match(corresp):
        name_el = place_el.find(f"{NS}placeName")
        text = (name_el.text or "").strip() if name_el is not None else ""
        if text:
            result = {"ref": corresp, "text": text}
    nested_lp = place_el.find(f"{NS}listPlace")
    if nested_lp is not None:
        for child in nested_lp.findall(f"{NS}place"):
            deeper = deepest_pmb_place(child)
            if deeper is not None:
                result = deeper
    return result


def places_for_event(event_el):
    """Alle Orte eines Tages außer Wien selbst - an Reisetagen kann ein
    <listPlace> mehrere Orte parallel enthalten (Wien und die bereisten
    Stationen); nur die Wien-Kette (corresp="#pmb50") wird ausgeschlossen,
    alles andere gilt als "nicht in Wien"."""
    lp = event_el.find(f"{NS}listPlace")
    if lp is None:
        return []
    hits = []
    for place_el in lp.findall(f"{NS}place"):
        if (place_el.get("corresp") or "") == WIEN_REF:
            continue
        deepest = deepest_pmb_place(place_el)
        if deepest:
            hits.append(deepest)
    return hits


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--source", default=str(DEFAULT_SOURCE),
                     help="Pfad zu wienerschnitzler_complete_nested.xml")
    args = ap.parse_args()

    source = Path(args.source)
    if not source.exists():
        raise SystemExit(f"{source} nicht gefunden")

    root = ET.parse(str(source)).getroot()
    aufenthalte = {}
    for event_el in root.iter(f"{NS}event"):
        when = event_el.get("when")
        if not when or not WHEN_RE.match(when):
            continue
        hits = places_for_event(event_el)
        if not hits:
            continue
        seen = set()
        deduped = []
        for h in hits:
            if h["ref"] in seen:
                continue
            seen.add(h["ref"])
            deduped.append(h)
        aufenthalte[when] = deduped

    OUT_PATH.write_text(
        json.dumps(aufenthalte, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
        encoding="utf-8")
    print(f"{len(aufenthalte)} Tage außerhalb Wiens -> {OUT_PATH}")


if __name__ == "__main__":
    main()
