#!/usr/bin/env python3
"""Findet Wörter mit kleinem "f" in den Transkriptionen (editions/*.xml),
die nicht im deutschen Wörterbuch (hunspell de_DE/de_AT) stehen.

Zweck: typische Transkribus-Fehler aufspüren, bei denen ein langes ſ
als f gelesen wurde (z. B. "ift" statt "iſt").

Vor dem Wörterbuch-Abgleich wird ſ zu s normalisiert, damit korrekte
Wörter wie "ſchaffen" nicht fälschlich gemeldet werden.

Ausgabe:
  f-words-report.txt  – alle Treffer mit Häufigkeit und Fundstellen
  f-words-summary.md  – Markdown-Zusammenfassung (für GITHUB_STEP_SUMMARY)
"""

import argparse
import glob
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict

from lxml import etree

TEI_NS = "http://www.tei-c.org/ns/1.0"

# Elemente, deren Inhalt nicht geprüft wird (editorischer Text bzw. kein Brieftext)
SKIP_ELEMENTS = {"note", "fw"}

XML_LANG = "{http://www.w3.org/XML/1998/namespace}lang"

# xml:lang-Werte, die als Deutsch gelten (alles andere wird übersprungen)
GERMAN_LANGS = ("de", "ger", "deu")

# Leere Elemente, die eine Wortgrenze markieren (außer bei break="no")
BREAK_ELEMENTS = {"lb", "pb", "cb"}

# <c rendition="..."/> steht für Sonderzeichen; Geminationsstriche werden
# zum doppelten Konsonanten aufgelöst (Hofma<c rendition="#gemination-n"/>sthal
# → Hofmannsthal), alles andere wirkt als Wortgrenze
C_RENDITION_MAP = {
    "#gemination-m": "mm",
    "#gemination-n": "nn",
}

WORD_RE = re.compile(r"[^\W\d_]+", re.UNICODE)


def local_name(el):
    if not isinstance(el.tag, str):
        return None
    return etree.QName(el).localname


def extract_text(el, parts):
    name = local_name(el)
    lang = el.get(XML_LANG)
    foreign = lang and not lang.lower().startswith(GERMAN_LANGS)
    if name is None or name in SKIP_ELEMENTS or foreign:
        if el.tail:
            parts.append(el.tail)
        return
    if name in BREAK_ELEMENTS and el.get("break") != "no":
        parts.append(" ")
    if name == "space":
        parts.append(" ")
    if name == "c":
        parts.append(C_RENDITION_MAP.get(el.get("rendition"), " "))
    if el.text:
        parts.append(el.text)
    for child in el:
        extract_text(child, parts)
    if el.tail:
        parts.append(el.tail)


def collect_words(editions_dir):
    """Sammelt alle Wörter mit kleinem 'f' aus den body-Elementen."""
    counts = Counter()
    occurrences = defaultdict(set)
    files = sorted(glob.glob(os.path.join(editions_dir, "L*.xml")))
    if not files:
        print(f"ERROR: keine XML-Dateien in {editions_dir} gefunden")
        sys.exit(1)
    print(f"{len(files)} Dateien werden geprüft ...")
    parser = etree.XMLParser(recover=True)
    for i, path in enumerate(files, 1):
        if i % 500 == 0:
            print(f"  {i}/{len(files)}")
        try:
            tree = etree.parse(path, parser)
        except Exception as e:
            print(f"  WARNUNG: {path} nicht lesbar: {e}")
            continue
        basename = os.path.basename(path)
        for body in tree.iter(f"{{{TEI_NS}}}body"):
            parts = []
            extract_text(body, parts)
            text = "".join(parts)
            for word in WORD_RE.findall(text):
                if "f" in word:
                    counts[word] += 1
                    occurrences[word].add(basename)
    return counts, occurrences


def hunspell_unknown(words, dicts):
    """Gibt die Teilmenge der Wörter zurück, die hunspell nicht kennt."""
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", suffix=".txt", delete=False
    ) as f:
        f.write("\n".join(sorted(words)) + "\n")
        tmp = f.name
    try:
        result = subprocess.run(
            ["hunspell", "-d", dicts, "-l", "-i", "utf-8", tmp],
            capture_output=True,
            text=True,
            check=True,
        )
    finally:
        os.unlink(tmp)
    return set(result.stdout.split())


def load_allowlist(path):
    allow = set()
    if path and os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    allow.add(line)
    return allow


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--editions-dir", default="editions")
    ap.add_argument("--allowlist", default="python/f-words-allowlist.txt")
    ap.add_argument("--dicts", default="de_DE,de_AT")
    ap.add_argument("--report", default="f-words-report.txt")
    ap.add_argument("--summary", default="f-words-summary.md")
    ap.add_argument(
        "--max-summary-words",
        type=int,
        default=300,
        help="maximale Anzahl Wörter in der Markdown-Zusammenfassung",
    )
    args = ap.parse_args()

    counts, occurrences = collect_words(args.editions_dir)
    print(f"{len(counts)} verschiedene Wörter mit kleinem 'f' gefunden")

    # ſ → s normalisieren, damit das Wörterbuch die Wörter erkennt
    normalized = {w: w.replace("ſ", "s") for w in counts}
    unknown_normalized = hunspell_unknown(set(normalized.values()), args.dicts)

    allow = load_allowlist(args.allowlist)
    hits = {
        w: c
        for w, c in counts.items()
        if normalized[w] in unknown_normalized
        and w not in allow
        and normalized[w] not in allow
    }
    print(f"{len(hits)} Wörter stehen nicht im Wörterbuch")

    ranked = sorted(hits.items(), key=lambda x: (-x[1], x[0]))

    with open(args.report, "w", encoding="utf-8") as f:
        f.write(f"# Wörter mit kleinem 'f', die nicht im Wörterbuch stehen\n")
        f.write(f"# {len(hits)} Wörter, Wörterbücher: {args.dicts}\n\n")
        for word, count in ranked:
            files = sorted(occurrences[word])
            shown = ", ".join(files[:10])
            more = f" (+{len(files) - 10} weitere)" if len(files) > 10 else ""
            f.write(f"{word}\t{count}\t{shown}{more}\n")

    with open(args.summary, "w", encoding="utf-8") as f:
        f.write("# Wörter mit kleinem »f« ohne Wörterbuch-Eintrag\n\n")
        f.write(f"**{len(hits)}** Wörter gefunden ")
        f.write(f"({sum(hits.values())} Vorkommen insgesamt).\n\n")
        if ranked:
            f.write("| Wort | Anzahl | Dateien |\n|---|---|---|\n")
            for word, count in ranked[: args.max_summary_words]:
                files = sorted(occurrences[word])
                shown = ", ".join(files[:5])
                more = f" … (+{len(files) - 5})" if len(files) > 5 else ""
                f.write(f"| {word} | {count} | {shown}{more} |\n")
            if len(ranked) > args.max_summary_words:
                f.write(
                    f"\n… und {len(ranked) - args.max_summary_words} weitere – "
                    "siehe Artefakt `f-words-report`.\n"
                )
        else:
            f.write("Keine Auffälligkeiten. 🎉\n")

    print(f"Report: {args.report}")
    print(f"Zusammenfassung: {args.summary}")


if __name__ == "__main__":
    main()
