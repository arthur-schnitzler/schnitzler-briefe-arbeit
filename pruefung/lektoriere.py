#!/usr/bin/env python3
"""Lektorat per Briefnummer oder Nummernbereich – ein Befehl statt drei Schritte.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 pruefung/lektoriere.py 3971            # ein Brief
    python3 pruefung/lektoriere.py L03971
    python3 pruefung/lektoriere.py 3971-3980       # Bereich (nur vorhandene Dateien)
    python3 pruefung/lektoriere.py 3971 4002 4010-4015   # mehrere Angaben mischen
    python3 pruefung/lektoriere.py 3971-3980 -j 4  # vier Briefe parallel
    python3 pruefung/lektoriere.py 3971 --nur-bericht   # nur maschinelle Prüfung

Je Brief passiert:
  1. maschinelle Vorprüfung  -> pruefung/berichte/L#####.md
  2. kritische Lektüre durch `claude -p` nach pruefung/ANWEISUNG.md
                              -> pruefung/befunde/L#####.md
Zum Schluss werden alle Befundlisten des Laufs in
pruefung/befunde/_lauf-<Zeitstempel>.md zusammengefasst; das Format passt
zu LEKTORAT.md (Abschnitt 4) und python/lektorat.py.

Die Briefe müssen bereits in editions/ (oder temp/) liegen; verschoben wird
nichts. Bereits lektorierte Briefe werden übersprungen (--neu erzwingt Wiederholung).
"""

import argparse
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PRUEFUNG = REPO / "pruefung"
BERICHTE = PRUEFUNG / "berichte"
BEFUNDE = PRUEFUNG / "befunde"
ORDNER = (REPO / "editions", REPO / "temp")


def ids_aus_angaben(angaben):
    """'3971', 'L03971', '3971-3980', 'L03971-L03980' -> sortierte ID-Liste."""
    ids = set()
    for a in angaben:
        for teil in re.split(r"[,\s]+", a.strip()):
            if not teil:
                continue
            m = re.fullmatch(r"L?0*(\d+)(?:\s*[-–:]\s*L?0*(\d+))?", teil, re.I)
            if not m:
                sys.exit(f"Nicht verständlich: »{teil}« (erwartet: 3971 oder 3971-3980)")
            von = int(m.group(1))
            bis = int(m.group(2) or von)
            if bis < von:
                von, bis = bis, von
            ids.update(range(von, bis + 1))
    return sorted(ids)


def finde(nr):
    for ordner in ORDNER:
        p = ordner / f"L{nr:05d}.xml"
        if p.exists():
            return p
    return None


PROMPT = """Lektoriere {rel} nach pruefung/ANWEISUNG.md.
Der maschinelle Prüfbericht liegt in pruefung/berichte/{bid}.md.

Lies zuerst ANWEISUNG.md, dann den Bericht, dann die XML-Datei vollständig.
Gib ausschließlich die Befundliste im Format aus Abschnitt 6 der Anweisung aus
(Überschrift »## Lektorat {bid} (Datum)«, Befunde, Schlusszeile »Geprüft: …«) –
ohne Einleitung, ohne Nachbemerkung. Verändere keine Dateien."""


def lektoriere(nr, args):
    bid = f"L{nr:05d}"
    xml = finde(nr)
    bericht = BERICHTE / f"{bid}.md"
    befund = BEFUNDE / f"{bid}.md"

    if xml is None:
        return bid, "fehlt", None
    if befund.exists() and not args.neu and not args.nur_bericht:
        return bid, "übersprungen", befund

    r = subprocess.run(
        [sys.executable, str(PRUEFUNG / "pruefe_brief.py"), str(xml),
         "--out", str(bericht), "--quiet"],
        cwd=REPO, capture_output=True, text=True)
    if r.returncode != 0:
        return bid, f"Vorprüfung fehlgeschlagen: {(r.stderr or r.stdout).strip()[-300:]}", None
    if args.nur_bericht:
        return bid, "Bericht", bericht

    cmd = ["claude", "-p", "--allowedTools", "Read Grep Glob",
           "--permission-mode", "default"]
    if args.model:
        cmd += ["--model", args.model]
    prompt = PROMPT.format(rel=xml.relative_to(REPO), bid=bid)
    r = subprocess.run(cmd, input=prompt, cwd=REPO, capture_output=True, text=True)
    out = r.stdout.strip()
    if r.returncode != 0 or not out:
        return bid, f"claude fehlgeschlagen: {(r.stderr or out).strip()[-300:]}", None
    befund.write_text(out + "\n", encoding="utf-8")
    return bid, "lektoriert", befund


def main():
    ap = argparse.ArgumentParser(
        description="Lektorat per Briefnummer oder Nummernbereich (siehe pruefung/README.md)")
    ap.add_argument("briefe", nargs="+", help="Nummer(n) oder Bereich(e): 3971  3971-3980  L03971")
    ap.add_argument("-j", "--parallel", type=int, default=3, help="parallele Briefe (Standard 3)")
    ap.add_argument("--model", help="Modell für claude (z. B. opus, sonnet)")
    ap.add_argument("--neu", action="store_true", help="bereits vorhandene Befundlisten überschreiben")
    ap.add_argument("--nur-bericht", action="store_true", help="nur maschinelle Vorprüfung")
    args = ap.parse_args()

    nummern = ids_aus_angaben(args.briefe)
    vorhanden = [n for n in nummern if finde(n)]
    if not vorhanden:
        sys.exit("Keine der angegebenen Briefe liegt in editions/ oder temp/.")
    if len(nummern) > len(vorhanden):
        print(f"{len(nummern) - len(vorhanden)} Nummern ohne Datei im Bereich werden ignoriert.")

    BERICHTE.mkdir(exist_ok=True)
    BEFUNDE.mkdir(exist_ok=True)
    print(f"{len(vorhanden)} Brief(e): L{vorhanden[0]:05d}"
          + (f" … L{vorhanden[-1]:05d}" if len(vorhanden) > 1 else ""))

    # Korpusindex einmal vorab bauen, damit parallele Läufe ihn nicht doppelt bauen
    subprocess.run([sys.executable, str(PRUEFUNG / "pruefe_brief.py"), "--quiet", "--index-neu"]
                   if not (PRUEFUNG / ".cache" / "korpus-index.json.gz").exists() else ["true"],
                   cwd=REPO)

    ergebnisse = {}
    with ThreadPoolExecutor(max_workers=max(1, args.parallel)) as ex:
        futs = {ex.submit(lektoriere, n, args): n for n in vorhanden}
        for f in as_completed(futs):
            bid, status, pfad = f.result()
            ergebnisse[bid] = (status, pfad)
            print(f"  {bid}: {status}")

    if not args.nur_bericht:
        teile = [ergebnisse[b][1].read_text(encoding="utf-8").strip()
                 for b in sorted(ergebnisse) if ergebnisse[b][1] and ergebnisse[b][0] in ("lektoriert", "übersprungen")]
        if teile:
            sammel = BEFUNDE / f"_lauf-{datetime.now():%Y%m%d-%H%M%S}.md"
            sammel.write_text("\n\n".join(teile) + "\n", encoding="utf-8")
            print(f"\nBefunde gesammelt: {sammel.relative_to(REPO)}")
    fehler = [b for b, (s, _) in ergebnisse.items() if "fehlgeschlagen" in s]
    if fehler:
        print(f"Fehlgeschlagen: {', '.join(sorted(fehler))}")
        sys.exit(1)


if __name__ == "__main__":
    main()
