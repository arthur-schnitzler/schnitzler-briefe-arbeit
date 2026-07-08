#!/usr/bin/env python3
"""
Lektorat-Tool für die Briefe in editions/*.xml.

Liest die Befunde aus LEKTORAT.md, öffnet pro Befund die HTML-Ansicht im Browser
und die XML-Datei in OxygenXML, zeigt den Fehler an und lässt ihn klassifizieren:
    erledigt · abgelehnt · später

Der Bearbeitungsstand wird in LEKTORAT.status.json gespeichert und ist über
mehrere Sitzungen hinweg fortsetzbar.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 lektorat.py            # offene Befunde durchgehen
    python3 lektorat.py --all      # auch bereits klassifizierte
    python3 lektorat.py --section 1
    python3 lektorat.py --file L03728
    python3 lektorat.py --stats
    python3 lektorat.py --list
    python3 lektorat.py --no-open  # Apps nicht automatisch öffnen
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Konfiguration
# ---------------------------------------------------------------------------
REPO = Path(__file__).resolve().parent
LEKTORAT_MD = REPO / "LEKTORAT.md"
STATUS_JSON = REPO / "LEKTORAT.status.json"
EDITIONS = REPO / "editions"
HTML_BASE = "https://schnitzler-briefe.acdh.oeaw.ac.at/{fid}.html"
OXYGEN_APP = "/Applications/Oxygen XML Editor/Oxygen XML Editor.app"

STATUS_LABELS = {
    "erledigt": "erledigt",
    "abgelehnt": "abgelehnt",
    "spaeter": "später",
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
    "erledigt": C["green"], "abgelehnt": C["red"],
    "spaeter": C["yellow"], "offen": C["dim"],
}

# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------
FILE_RE = re.compile(r"L\d{5}")
BULLET_RE = re.compile(r"^(\s*)[-*]\s+")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)")
GUILLEMET_RE = re.compile(r"(L\d{5})[`\s]*\(([^)]*)\)")


def clean(text: str) -> str:
    """Markdown-Auszeichnung für die Anzeige entfernen."""
    text = text.replace("`", "").replace("**", "").replace("*", "")
    return re.sub(r"\s+", " ", text).strip()


def make_id(section: str, text: str) -> str:
    h = hashlib.md5(f"{section}\n{text}".encode("utf-8")).hexdigest()
    return h[:10]


def parse_findings(md_path: Path):
    """LEKTORAT.md in eine Liste von Befunden zerlegen.

    Jeder Befund: {id, section, primary, files, text}
    - Tabellenzeilen (§1): Datei = erste Spalte.
    - Aufzählungspunkte (§2/§3a/§3c/§4): Datei(en) = alle L#####-Treffer.
    - §3b (Inline-Absatz): pro Datei ein Befund mit »/«-Zählung.
    """
    lines = md_path.read_text(encoding="utf-8").splitlines()
    findings = []
    seen = set()
    section = ""
    top_num = ""   # Nummer des übergeordneten ##-Abschnitts
    i = 0
    n = len(lines)

    def secnum(title):
        m = re.match(r"(\d+[a-z]?)\.", title)
        return m.group(1) if m else top_num

    def add(section, primary, files, text):
        text = clean(text)
        fid = make_id(section, text)
        if fid in seen:
            return
        seen.add(fid)
        findings.append({
            "id": fid,
            "section": section,
            "secnum": secnum(section),
            "primary": primary,
            "files": files,
            "text": text,
        })

    while i < n:
        line = lines[i]

        m = HEADING_RE.match(line)
        if m:
            section = m.group(2).strip()
            hm = re.match(r"(\d+)\.", section)
            if len(m.group(1)) == 2 and hm:   # Ebene-2-Überschrift mit Nummer
                top_num = hm.group(1)
            i += 1
            continue

        # Tabellenzeile
        if line.lstrip().startswith("|"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            col0 = cells[0] if cells else ""
            fm = FILE_RE.search(col0)
            # Nur Zeilen, deren erste Spalte im Wesentlichen eine Datei-ID ist
            # (Kopf-/Trennzeilen und Fließtext-Tabellen ohne Lxxxxx überspringen)
            if fm and not set(col0.replace(".xml", "")) <= set("L0123456789"):
                fm = None
            if fm:
                add(section, fm.group(0), [fm.group(0)], " · ".join(c for c in cells if c))
            i += 1
            continue

        # §3b: Inline-Absatz mit vielen Datei-Refs und (»/«)-Zählungen
        if section.startswith("3b") and GUILLEMET_RE.search(line):
            for mm in GUILLEMET_RE.finditer(line):
                fid_, cnt = mm.group(1), mm.group(2)
                add(section, fid_, [fid_],
                    f"{fid_}: unpaarige Guillemets (» / « = {cnt})")
            i += 1
            continue

        # Aufzählungspunkt (inkl. mehrzeiliger Umbrüche)
        bm = BULLET_RE.match(line)
        if bm:
            block = [line.strip().lstrip("-* ")]
            j = i + 1
            while j < n:
                nxt = lines[j]
                if nxt.strip() == "" or BULLET_RE.match(nxt) or HEADING_RE.match(nxt) or nxt.lstrip().startswith("|"):
                    break
                block.append(nxt.strip())
                j += 1
            text = " ".join(block)
            files = list(dict.fromkeys(FILE_RE.findall(text)))
            if files:
                add(section, files[0], files, text)
            i = j
            continue

        i += 1

    return findings


# ---------------------------------------------------------------------------
# Status-Persistenz
# ---------------------------------------------------------------------------
def load_status():
    if STATUS_JSON.exists():
        return json.loads(STATUS_JSON.read_text(encoding="utf-8"))
    return {}


def save_status(status):
    STATUS_JSON.write_text(
        json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8"
    )


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
def section_num(f):
    """Sektionsnummer eines Befunds (Fallback: aus dem Titel abgeleitet)."""
    if isinstance(f, dict):
        if f.get("secnum"):
            return f["secnum"]
        f = f.get("section", "")
    m = re.match(r"(\d+[a-z]?)\.", f)
    return m.group(1) if m else f.split(".")[0][:4]


def print_stats(findings, status):
    counts = {"offen": 0, "erledigt": 0, "abgelehnt": 0, "spaeter": 0}
    for f in findings:
        st = status.get(f["id"], {}).get("status", "offen")
        counts[st] = counts.get(st, 0) + 1
    total = len(findings)
    print(f"\n{C['bold']}Bearbeitungsstand{C['reset']}  ({total} Befunde)")
    for st in ("erledigt", "abgelehnt", "spaeter", "offen"):
        col = STATUS_COLOR[st]
        print(f"  {col}{STATUS_LABELS[st]:<10}{C['reset']} {counts.get(st, 0)}")
    print()


def print_list(findings, status):
    for idx, f in enumerate(findings, 1):
        st = status.get(f["id"], {}).get("status", "offen")
        col = STATUS_COLOR[st]
        sec = section_num(f)
        print(f"{idx:>4}  {col}{STATUS_LABELS[st]:<9}{C['reset']} "
              f"{C['cyan']}{f['primary']}{C['reset']}  "
              f"{C['dim']}[§{sec}]{C['reset']} {f['text'][:90]}")


def show_finding(f, status, position):
    st_entry = status.get(f["id"], {})
    st = st_entry.get("status", "offen")
    col = STATUS_COLOR[st]
    print("\n" + "─" * 78)
    print(f"{C['bold']}{position}{C['reset']}   "
          f"{C['cyan']}{C['bold']}{f['primary']}{C['reset']}   "
          f"{C['dim']}§{section_num(f)} · {f['section']}{C['reset']}")
    print(f"Status: {col}{STATUS_LABELS[st]}{C['reset']}"
          + (f"  {C['dim']}({st_entry.get('note','')}){C['reset']}" if st_entry.get("note") else ""))
    if len(f["files"]) > 1:
        print(f"Dateien: {C['cyan']}{', '.join(f['files'])}{C['reset']}")
    print()
    print(f"  {f['text']}")
    print(f"\n  {C['blue']}{HTML_BASE.format(fid=f['primary'])}{C['reset']}")


# ---------------------------------------------------------------------------
# Interaktive Schleife
# ---------------------------------------------------------------------------
HELP = f"""
  {C['bold']}e{C['reset']} erledigt   {C['bold']}a{C['reset']} abgelehnt   {C['bold']}s{C['reset']} später   {C['bold']}o{C['reset']} offen (zurücksetzen)
  {C['bold']}Enter{C['reset']}/{C['bold']}n{C['reset']} nächster (ohne Änderung)   {C['bold']}p{C['reset']} vorheriger
  {C['bold']}r{C['reset']} Apps erneut öffnen   {C['bold']}f{C['reset']} andere Datei öffnen (bei Mehrfach)
  {C['bold']}g{C['reset']} <Nr> springen   {C['bold']}l{C['reset']} Liste   {C['bold']}?{C['reset']} Hilfe   {C['bold']}q{C['reset']} beenden
"""


def review(findings, status, do_open=True):
    if not findings:
        print("Keine passenden Befunde.")
        return
    last_opened = None
    idx = 0
    while 0 <= idx < len(findings):
        f = findings[idx]
        show_finding(f, status, f"[{idx + 1}/{len(findings)}]")

        if do_open and last_opened != f["primary"]:
            open_in_browser(f["primary"])
            open_in_oxygen(f["primary"])
            last_opened = f["primary"]

        try:
            cmd = input(f"\n  {C['bold']}›{C['reset']} [e/a/s/o · n/p · ?] ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nBeendet.")
            break

        low = cmd.lower()
        if low in ("q", "quit", "exit"):
            print("Beendet. Stand gespeichert.")
            break
        elif low in ("", "n", "next"):
            idx += 1
        elif low in ("p", "prev", "b"):
            idx = max(0, idx - 1)
        elif low in ("?", "h", "help"):
            print(HELP)
        elif low in ("l", "list"):
            print()
            print_list(findings, status)
        elif low == "r":
            open_in_browser(f["primary"])
            open_in_oxygen(f["primary"])
            last_opened = f["primary"]
        elif low.startswith("f"):
            target = cmd[1:].strip().upper()
            if not target and len(f["files"]) > 1:
                print("  Dateien: " + ", ".join(f["files"]))
                target = input("  Welche öffnen? ").strip().upper()
            if target and not target.startswith("L"):
                target = "L" + target
            if target in f["files"] or (EDITIONS / f"{target}.xml").exists():
                open_in_browser(target)
                open_in_oxygen(target)
                last_opened = target
            else:
                print(f"  {C['red']}Unbekannte Datei: {target}{C['reset']}")
        elif low.startswith("g"):
            arg = cmd[1:].strip()
            if arg.isdigit() and 1 <= int(arg) <= len(findings):
                idx = int(arg) - 1
            else:
                print("  Ungültige Nummer.")
        elif low in ("e", "a", "s", "o"):
            mapping = {"e": "erledigt", "a": "abgelehnt", "s": "spaeter", "o": "offen"}
            new = mapping[low]
            note = ""
            if low in ("a", "s"):
                note = input(f"  Notiz zu »{STATUS_LABELS[new]}« (optional): ").strip()
            if new == "offen":
                status.pop(f["id"], None)
            else:
                status[f["id"]] = {
                    "status": new,
                    "primary": f["primary"],
                    "section": section_num(f),
                    "text": f["text"][:200],
                }
                if note:
                    status[f["id"]]["note"] = note
            save_status(status)
            col = STATUS_COLOR[new]
            print(f"  → {col}{STATUS_LABELS[new]}{C['reset']} gespeichert.")
            idx += 1
        else:
            print("  Unbekannter Befehl. »?« für Hilfe.")

    print()
    print_stats(findings, status)


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Lektorat-Tool für editions/*.xml")
    ap.add_argument("--all", action="store_true",
                    help="auch bereits klassifizierte Befunde durchgehen")
    ap.add_argument("--section", help="nur Abschnitt (z. B. 1, 3a, 4)")
    ap.add_argument("--file", help="nur Befunde zu einer Datei (z. B. L03728)")
    ap.add_argument("--stats", action="store_true", help="nur Statistik zeigen")
    ap.add_argument("--list", action="store_true", help="nur Liste zeigen")
    ap.add_argument("--no-open", action="store_true",
                    help="Apps nicht automatisch öffnen")
    args = ap.parse_args()

    if not LEKTORAT_MD.exists():
        sys.exit(f"LEKTORAT.md nicht gefunden unter {LEKTORAT_MD}")

    findings = parse_findings(LEKTORAT_MD)
    status = load_status()

    # Filtern
    sel = findings
    if args.section:
        sel = [f for f in sel if section_num(f).lower() == args.section.lower()]
    if args.file:
        want = args.file.upper()
        if not want.startswith("L"):
            want = "L" + want
        sel = [f for f in sel if want in f["files"]]

    if args.stats:
        print_stats(findings, status)
        return
    if args.list:
        print_list(sel, status)
        print_stats(sel, status)
        return

    if not args.all:
        sel = [f for f in sel if status.get(f["id"], {}).get("status", "offen") == "offen"]

    print_stats(findings, status)
    print(f"{C['dim']}Zu bearbeiten: {len(sel)} Befund(e).  »?« für Hilfe, »q« zum Beenden.{C['reset']}")
    review(sel, status, do_open=not args.no_open)


if __name__ == "__main__":
    main()
