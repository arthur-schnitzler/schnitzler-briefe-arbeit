#!/usr/bin/env python3
"""
Poststempel-Prüf-Tool für die Briefe in editions/*.xml.

Findet Briefe/Postkarten mit Poststempel, deren Datierung nicht bereits aus
einem übermittelten Datum stammt:

    //TEI[descendant::physDesc/descendant::stamp
          and not(descendant::correspAction/@type='transmitted')]

Öffnet pro Kandidat die HTML-Ansicht im Browser und die XML-Datei in
OxygenXML, zeigt Briefdatum vs. Poststempeldatum und lässt den Befund
klassifizieren: bestätigt · korrigiert · Prüffall

Der Bearbeitungsstand wird lokal in poststempel.status.json gespeichert
(nicht git-getrackt) und ist über mehrere Sitzungen hinweg fortsetzbar.

Zwei Personen können die Liste parallel bearbeiten, ohne sich zu
überschneiden: die Kandidatenliste wird deterministisch aus dem Korpus
berechnet (auf beiden Rechnern identisch) – eine Person arbeitet sie mit
--von-hinten von hinten durch, die andere per Default von vorne.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 python/poststempel.py             # Kandidaten von vorne durchgehen
    python3 python/poststempel.py --von-hinten  # von hinten durchgehen
    python3 python/poststempel.py --file L04529
    python3 python/poststempel.py --stats
    python3 python/poststempel.py --list
    python3 python/poststempel.py --all       # auch bereits klassifizierte
    python3 python/poststempel.py --no-open   # Apps nicht automatisch öffnen
"""

import argparse
import subprocess
import sys
from datetime import date
from json import dumps, loads
from pathlib import Path

from lxml import etree

# ---------------------------------------------------------------------------
# Konfiguration
# ---------------------------------------------------------------------------
REPO = Path(__file__).resolve().parent.parent
EDITIONS = REPO / "editions"
STATUS_JSON_DEFAULT = REPO / "poststempel.status.json"
HTML_BASE = "https://schnitzler-briefe.acdh.oeaw.ac.at/{fid}.html"
OXYGEN_APP = "/Applications/Oxygen XML Editor/Oxygen XML Editor.app"

NS = {"tei": "http://www.tei-c.org/ns/1.0"}

STATUS_LABELS = {
    "bestaetigt": "bestätigt",
    "korrigiert": "korrigiert",
    "pruefen": "Prüffall",
    "offen": "offen",
}

# ANSI-Farben (nur wenn Terminal)
C = {
    "reset": "\033[0m", "bold": "\033[1m", "dim": "\033[2m",
    "green": "\033[32m", "red": "\033[31m", "yellow": "\033[33m",
    "blue": "\033[34m", "cyan": "\033[36m", "mag": "\033[35m",
}
if not sys.stdout.isatty():
    C = {k: "" for k in C}

STATUS_COLOR = {
    "bestaetigt": C["green"], "korrigiert": C["mag"],
    "pruefen": C["yellow"], "offen": C["dim"],
}


# ---------------------------------------------------------------------------
# Kandidatenermittlung
# ---------------------------------------------------------------------------
def load_candidate(path: Path):
    """Liefert dict mit id/Brief-/Stempeldatum, falls path ein Kandidat ist,
    sonst None."""
    try:
        tree = etree.parse(str(path))
    except etree.XMLSyntaxError:
        return None

    has_stamp = bool(tree.xpath("boolean(.//tei:physDesc//tei:stamp)", namespaces=NS))
    if not has_stamp:
        return None
    has_transmitted = bool(
        tree.xpath("boolean(.//tei:correspAction[@type='transmitted'])", namespaces=NS)
    )
    if has_transmitted:
        return None

    sent = tree.xpath("string(.//tei:correspAction[@type='sent']/tei:date/@when)", namespaces=NS)
    stamp_dates = tree.xpath(".//tei:physDesc//tei:stamp/tei:date/@when", namespaces=NS)

    return {
        "id": path.stem,
        "sent": sent or None,
        "stamps": list(stamp_dates),
    }


def find_candidates():
    candidates = []
    for path in sorted(EDITIONS.glob("*.xml")):
        cand = load_candidate(path)
        if cand:
            candidates.append(cand)
    return candidates


def date_diff_note(cand):
    """Textnotiz zur Tagesdifferenz Brief- vs. Stempeldatum, falls eindeutig."""
    sent = cand.get("sent")
    stamps = cand.get("stamps") or []
    if not sent or len(stamps) != 1:
        return None
    try:
        d_sent = date.fromisoformat(sent)
        d_stamp = date.fromisoformat(stamps[0])
    except ValueError:
        return None
    delta = (d_stamp - d_sent).days
    if delta == 1:
        return "Brief 1 Tag vor Stempel"
    if delta == 0:
        return "Brief am Stempeltag"
    if delta > 1:
        return f"Brief {delta} Tage vor Stempel"
    return f"Brief {-delta} Tage NACH Stempel"


# ---------------------------------------------------------------------------
# Status-Persistenz
# ---------------------------------------------------------------------------
def load_status(status_path: Path):
    if status_path.exists():
        return loads(status_path.read_text(encoding="utf-8"))
    return {}


def save_status(status_path: Path, status):
    status_path.write_text(dumps(status, ensure_ascii=False, indent=2, sort_keys=True), encoding="utf-8")


# ---------------------------------------------------------------------------
# Öffnen von Browser & Oxygen
# ---------------------------------------------------------------------------
def open_in_browser(fid):
    url = HTML_BASE.format(fid=fid)
    subprocess.run(["open", url], check=False)


def open_in_oxygen(fid):
    xml = EDITIONS / f"{fid}.xml"
    if not xml.exists():
        print(f"  {C['red']}!{C['reset']} {xml} nicht gefunden – Oxygen nicht geöffnet.")
        return
    subprocess.run(["open", "-a", OXYGEN_APP, str(xml)], check=False)


# ---------------------------------------------------------------------------
# Anzeige
# ---------------------------------------------------------------------------
def print_stats(candidates, status):
    counts = {"bestaetigt": 0, "korrigiert": 0, "pruefen": 0, "offen": 0}
    for cand in candidates:
        st = status.get(cand["id"], {}).get("status", "offen")
        counts[st] = counts.get(st, 0) + 1
    total = len(candidates)
    print(f"\n{C['bold']}Bearbeitungsstand{C['reset']}  ({total} Kandidaten)")
    for st in ("bestaetigt", "korrigiert", "pruefen", "offen"):
        col = STATUS_COLOR[st]
        print(f"  {col}{STATUS_LABELS[st]:<10}{C['reset']} {counts.get(st, 0)}")
    print()


def print_list(candidates, status):
    for idx, cand in enumerate(candidates, 1):
        st = status.get(cand["id"], {}).get("status", "offen")
        col = STATUS_COLOR[st]
        note = date_diff_note(cand) or ""
        print(f"{idx:>4}  {col}{STATUS_LABELS[st]:<9}{C['reset']} "
              f"{C['cyan']}{cand['id']}{C['reset']}  "
              f"{C['dim']}{note}{C['reset']}")


def show_candidate(cand, status, position, richtung):
    st_entry = status.get(cand["id"], {})
    st = st_entry.get("status", "offen")
    col = STATUS_COLOR[st]
    print("\n" + "─" * 78)
    print(f"{C['bold']}{position}{C['reset']}   "
          f"{C['cyan']}{C['bold']}{cand['id']}{C['reset']}   "
          f"{C['dim']}{richtung}{C['reset']}")
    print(f"Status: {col}{STATUS_LABELS[st]}{C['reset']}")
    print()
    print(f"  Brief:    {cand['sent'] or '?'}")
    stamps = ", ".join(cand["stamps"]) if cand["stamps"] else "?"
    diff = date_diff_note(cand)
    print(f"  Stempel:  {stamps}" + (f"  {C['dim']}({diff}){C['reset']}" if diff else ""))
    print(f"\n  {C['blue']}{HTML_BASE.format(fid=cand['id'])}{C['reset']}")


# ---------------------------------------------------------------------------
# Interaktive Schleife
# ---------------------------------------------------------------------------
HELP = f"""
  {C['bold']}b{C['reset']} bestätigt   {C['bold']}k{C['reset']} korrigiert   {C['bold']}f{C['reset']} Prüffall   {C['bold']}o{C['reset']} offen (zurücksetzen)
  {C['bold']}Enter{C['reset']}/{C['bold']}n{C['reset']} nächster (ohne Änderung)   {C['bold']}z{C['reset']} zurück
  {C['bold']}r{C['reset']} Apps erneut öffnen   {C['bold']}g{C['reset']} <Nr> springen   {C['bold']}l{C['reset']} Liste   {C['bold']}?{C['reset']} Hilfe   {C['bold']}q{C['reset']} beenden
"""


def review(candidates, status, status_path, richtung, do_open=True):
    if not candidates:
        print("Keine passenden Kandidaten.")
        return
    last_opened = None
    idx = 0
    while 0 <= idx < len(candidates):
        cand = candidates[idx]
        show_candidate(cand, status, f"[{idx + 1}/{len(candidates)}]", richtung)

        if do_open and last_opened != cand["id"]:
            open_in_browser(cand["id"])
            open_in_oxygen(cand["id"])
            last_opened = cand["id"]

        try:
            cmd = input(f"\n  {C['bold']}›{C['reset']} [b/k/f/o · n/z · q · ?] ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nBeendet.")
            break

        low = cmd.lower()
        if low in ("q", "quit", "exit"):
            print("Beendet. Stand gespeichert.")
            break
        elif low in ("", "n", "next"):
            idx += 1
        elif low in ("z", "zurueck", "zurück"):
            idx = max(0, idx - 1)
        elif low in ("?", "h", "help"):
            print(HELP)
        elif low in ("l", "list"):
            print()
            print_list(candidates, status)
        elif low == "r":
            open_in_browser(cand["id"])
            open_in_oxygen(cand["id"])
            last_opened = cand["id"]
        elif low.startswith("g"):
            arg = cmd[1:].strip()
            if arg.isdigit() and 1 <= int(arg) <= len(candidates):
                idx = int(arg) - 1
            else:
                print("  Ungültige Nummer.")
        elif low in ("b", "k", "f", "o"):
            mapping = {"b": "bestaetigt", "k": "korrigiert", "f": "pruefen", "o": "offen"}
            new = mapping[low]
            if new == "offen":
                status.pop(cand["id"], None)
            else:
                status[cand["id"]] = {
                    "status": new,
                    "sent": cand["sent"],
                    "stamps": cand["stamps"],
                }
            save_status(status_path, status)
            col = STATUS_COLOR[new]
            print(f"  → {col}{STATUS_LABELS[new]}{C['reset']} gespeichert.")
            idx += 1
        else:
            print("  Unbekannter Befehl. »?« für Hilfe.")

    print()
    print_stats(candidates, status)


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Poststempel-Prüf-Tool für editions/*.xml")
    ap.add_argument("--von-hinten", action="store_true",
                     help="Kandidatenliste von hinten durchgehen (für Arbeitsteilung zu zweit)")
    ap.add_argument("--file", help="nur einen Kandidaten (z. B. L04529)")
    ap.add_argument("--stats", action="store_true", help="nur Statistik zeigen")
    ap.add_argument("--list", action="store_true", help="nur Liste zeigen")
    ap.add_argument("--all", action="store_true",
                     help="auch bereits klassifizierte Kandidaten durchgehen")
    ap.add_argument("--no-open", action="store_true",
                     help="Apps nicht automatisch öffnen")
    ap.add_argument("--status-file", default=str(STATUS_JSON_DEFAULT),
                     help="alternative Statusdatei (Default: poststempel.status.json)")
    args = ap.parse_args()

    status_path = Path(args.status_file)
    candidates = find_candidates()
    status = load_status(status_path)

    if args.von_hinten:
        candidates = list(reversed(candidates))
    richtung = "von hinten" if args.von_hinten else "von vorne"

    sel = candidates
    if args.file:
        want = args.file.upper()
        if not want.startswith("L"):
            want = "L" + want
        sel = [c for c in sel if c["id"] == want]
        if not sel:
            sys.exit(f"{want} ist kein Kandidat (kein Stempel oder bereits übermitteltes Datum).")

    if args.stats:
        print_stats(candidates, status)
        return
    if args.list:
        print_list(sel, status)
        print_stats(sel, status)
        return

    if not args.all and not args.file:
        sel = [c for c in sel if status.get(c["id"], {}).get("status", "offen") == "offen"]

    print_stats(candidates, status)
    print(f"{C['dim']}Zu bearbeiten: {len(sel)} Kandidat(en), {richtung}.  »?« für Hilfe, »q« zum Beenden.{C['reset']}")
    review(sel, status, status_path, richtung, do_open=not args.no_open)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.stderr.close()
