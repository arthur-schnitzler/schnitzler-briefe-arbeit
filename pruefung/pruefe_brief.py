#!/usr/bin/env python3
"""Maschinelle Vorprüfung eines einzelnen Briefes (Schritt 1 des Lektorats-Workflows).

Erzeugt einen Prüfbericht in Markdown, der
  (a) alle maschinell feststellbaren Auffälligkeiten auflistet und
  (b) den Brief so aufbereitet (Klartext, Kommentare, Datums- und Verweistabelle),
      dass die anschließende kritische Lektüre (durch Mensch oder KI) darauf
      aufsetzen kann – siehe pruefung/ANWEISUNG.md.

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 pruefung/pruefe_brief.py L04318
    python3 pruefung/pruefe_brief.py temp/L03971.xml
    python3 pruefung/pruefe_brief.py L04318 --out pruefung/berichte/L04318.md
    python3 pruefung/pruefe_brief.py --index-neu      # Korpusindex neu aufbauen

Der Korpusindex (Wortfrequenzen aller editions/*.xml, PMB-Namen aus indices/,
Attributinventar) wird in pruefung/.cache/ abgelegt und beim ersten Aufruf
gebaut (wenige Sekunden).
"""

import argparse
import difflib
import glob
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
from datetime import date, datetime
from pathlib import Path

from lxml import etree

# ---------------------------------------------------------------------------
# Konfiguration
# ---------------------------------------------------------------------------
REPO = Path(__file__).resolve().parent.parent
PRUEFUNG = REPO / "pruefung"
CACHE = PRUEFUNG / ".cache"
INDEX_FILE = CACHE / "korpus-index.json.gz"
ALLOWLIST = PRUEFUNG / "allowlist.txt"
EDITIONS = REPO / "editions"
TEMP = REPO / "temp"
INDICES = REPO / "indices"

TEI = "http://www.tei-c.org/ns/1.0"
XML_LANG = "{http://www.w3.org/XML/1998/namespace}lang"
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"

ASPELL_NEU = "de_AT"      # heutige Rechtschreibung (Herausgebertext)
ASPELL_ALT = "de-alt"     # alte Rechtschreibung (Brieftext)

# Elemente, deren Inhalt nicht zum Brieftext gehört
EDITORISCH = {"note", "certainty", "listBibl"}

BREAK_ELEMENTS = {"lb", "pb", "cb"}
C_RENDITION_MAP = {"#gemination-m": "mm", "#gemination-n": "nn"}

WORD_RE = re.compile(r"[^\W\d_]+", re.UNICODE)
ROMAN_RE = re.compile(r"\b(?:X{0,3})(?:IX|IV|V?I{0,3})\b")

MONATE = {
    "januar": 1, "jänner": 1, "februar": 2, "feber": 2, "märz": 3, "april": 4,
    "mai": 5, "juni": 6, "juli": 7, "august": 8, "september": 9, "oktober": 10,
    "october": 10, "november": 11, "dezember": 12, "december": 12,
}
ROEM_MONAT = {"I": 1, "II": 2, "III": 3, "IV": 4, "V": 5, "VI": 6, "VII": 7,
              "VIII": 8, "IX": 9, "X": 10, "XI": 11, "XII": 12}

# Bekannte korrekte Dreifachbuchstaben (Komposita)
DREIFACH_OK = {
    "schlussszene", "schlusssatz", "schifffahrt", "schifffahrtsgesellschaft",
    "nussschale", "flussschifffahrt", "stofffarbe", "sauerstoffflasche",
    "kaffeeernte", "seeelefant", "brennnessel", "bestellliste",
}

# Unsichtbare bzw. problematische Zeichen. Das geschützte Leerzeichen (U+00A0)
# steht bewusst nicht hier: es wird im Korpus regulär verwendet.
UNSICHTBAR = {
    "\u00ad": "weiches Trennzeichen (U+00AD)",
    "\u200b": "Zero-Width-Space (U+200B)",
    "\u200e": "Left-to-Right-Mark (U+200E)",
    "\ufeff": "Byte-Order-Mark (U+FEFF)",
}

# Blockelemente: erzeugen im Klartext einen Zeilenumbruch
BLOCK_ELEMENTS = {"p", "lg", "l", "opener", "closer", "dateline", "salute",
                  "signed", "postscript", "head", "address", "addrLine",
                  "item", "row", "fw"}

# ANSI-Farben nur fürs Terminal
C = {"reset": "\033[0m", "bold": "\033[1m", "dim": "\033[2m",
     "red": "\033[31m", "yellow": "\033[33m", "green": "\033[32m"}
if not sys.stdout.isatty():
    C = {k: "" for k in C}


# ---------------------------------------------------------------------------
# Textextraktion
# ---------------------------------------------------------------------------
class TextBuilder:
    """Sammelt Text und merkt sich Element- und rs-Positionen."""

    def __init__(self):
        self.buf = []
        self.pos = 0
        self.grenzen = []       # Offsets, an denen eine Elementgrenze liegt
        self.rs = []            # (start, ende, ref, type, tag)
        self.zitat = []         # (start, ende) für quote/cit/title-Inhalte
        self.entfernt = set()   # Offsets, an denen Einrückung getilgt wurde

    def add(self, s):
        if s:
            self.buf.append(s)
            self.pos += len(s)

    def add_text(self, s):
        """Text-/Tail-Knoten hinzufügen; reine Einrückung wird vermerkt."""
        if not s:
            return
        g = glatt(s)
        if g:
            self.add(g)
        else:
            self.entfernt.add(self.pos)

    def mark(self):
        self.grenzen.append(self.pos)

    def text(self):
        return "".join(self.buf)


def lname(el):
    return etree.QName(el).localname if isinstance(el.tag, str) else None


def letztes_zeichen(tb):
    for p in reversed(tb.buf):
        if p:
            return p[-1]
    return None


def glatt(s):
    """Einrückung der XML-Quelle glätten.

    Reine Einrückungsknoten (nur Whitespace mit Zeilenumbruch, wie sie das
    Pretty-Printing zwischen Tags erzeugt) verschwinden ganz – sonst zerfiele
    »Revolu<damage><supplied>tio</supplied></damage>n« in drei Wörter.
    Alles andere wird zu einfachen Leerzeichen zusammengezogen.
    """
    if not s:
        return s
    if not s.strip():
        return "" if "\n" in s else s
    return re.sub(r"\s+", " ", s)


def extract(el, tb, skip=EDITORISCH, in_quote=False, mit_tail=True):
    """Rendert ein Element als Klartext (ungefähr wie die HTML-Ansicht).

    Umbrüche der XML-Quelle werden zu Leerzeichen geglättet; echte Zeilen-
    umbrüche (<lb/>, <pb/>, Blockelemente) erscheinen als »\\n«.
    """
    name = lname(el)
    # In <subst><del>alt</del><add>neu</add></subst> gilt nur die Endfassung,
    # sonst entstünde aus »90<subst><del>1</del><add>5</add></subst>« ein »9015«.
    getilgt = name == "del" and lname(el.getparent()) == "subst"
    if name is None or name in skip or getilgt:
        if mit_tail:
            tb.add_text(el.tail)
        return
    if name in BREAK_ELEMENTS and el.get("break") != "no":
        boundary = True
        if name == "pb":
            prev = letztes_zeichen(tb)
            nxt = el.tail.strip()[:1] if el.tail else None
            if (prev is not None and not prev.isspace() and nxt):
                boundary = False       # Umbruch mitten im Wort (Ver<pb/>faſſer)
        tb.add("\n" if boundary else "")
    if name in BLOCK_ELEMENTS or (name == "seg" and el.get("rend")):
        tb.add("\n")
    if name == "space":
        tb.add(" ")
    if name == "c":
        tb.add(C_RENDITION_MAP.get(el.get("rendition"), " "))
    if name == "ref" and not (el.text or "").strip() and len(el) == 0:
        # leere Verweise rendern in der HTML-Ansicht als Datum bzw. Pfeil
        tb.add(f"[→{el.get('target') or ''}]")

    start = tb.pos
    quote_hier = in_quote or name in ("quote", "cit")
    tb.mark()
    tb.add_text(el.text)
    for child in el:
        extract(child, tb, skip, quote_hier)
    tb.mark()
    ende = tb.pos

    if name == "rs":
        tb.rs.append((start, ende, (el.get("ref") or "").split()[0].lstrip("#")
                      if (el.get("ref") or "").strip() else "",
                      el.get("type") or "", el.get("subtype") or ""))
    if name in ("quote", "cit") and not in_quote:
        tb.zitat.append((start, ende))
    if mit_tail:
        tb.add_text(el.tail)


def render(el, skip=EDITORISCH):
    """Klartext eines Elements – ohne dessen tail (Text nach dem Endtag)."""
    tb = TextBuilder()
    extract(el, tb, skip, mit_tail=False)
    return tb


def normalisiere(text):
    """Lang-ſ auflösen, Apostrophvarianten vereinheitlichen."""
    return text.replace("ſ", "s")


def kompakt(text, breite=None):
    t = re.sub(r"\s+", " ", text).strip()
    if breite and len(t) > breite:
        t = t[:breite] + " …"
    return t


def umfeld(text, start, ende, links=45, rechts=45):
    a = max(0, start - links)
    b = min(len(text), ende + rechts)
    return ("…" if a > 0 else "") + kompakt(text[a:b]) + ("…" if b < len(text) else "")


# ---------------------------------------------------------------------------
# Wörterbuch
# ---------------------------------------------------------------------------
def aspell_unbekannt(woerter, dic):
    """Teilmenge der Wörter, die aspell im Wörterbuch `dic` nicht kennt."""
    woerter = [w for w in woerter if w]
    if not woerter:
        return set()
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".txt",
                                     delete=False) as f:
        f.write("\n".join(sorted(set(woerter))) + "\n")
        tmp = f.name
    try:
        res = subprocess.run(
            ["aspell", "-d", dic, "--encoding=utf-8",
             "--run-together", "--run-together-limit=3",
             "--run-together-min=5", "list"],
            stdin=open(tmp, encoding="utf-8"),
            capture_output=True, text=True,
        )
    except FileNotFoundError:
        os.unlink(tmp)
        print(f"{C['yellow']}WARNUNG: aspell nicht gefunden – "
              f"Rechtschreibprüfung übersprungen.{C['reset']}", file=sys.stderr)
        return set()
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)
    if res.returncode != 0 and not res.stdout:
        print(f"{C['yellow']}WARNUNG: aspell -d {dic} fehlgeschlagen: "
              f"{res.stderr.strip()[:200]}{C['reset']}", file=sys.stderr)
        return set()
    return set(res.stdout.split())


def abzug(korpus, text):
    """Die Wörter dieses Briefes aus den Korpusfrequenzen herausrechnen."""
    eigen = Counter(WORD_RE.findall(text))
    if not eigen:
        return korpus
    korpus = dict(korpus)
    for w, n in eigen.items():
        if w in korpus:
            korpus[w] = max(0, korpus[w] - n)
    return korpus


def kompositum_aufloesbar(woerter, dicts):
    """Wörter, die sich als Kompositum aus bekannten Teilen erklären lassen.

    aspell kennt deutsche Komposita nur unzuverlässig; ohne diese Auflösung
    stünden »Handlungsführung« oder »staatsgefährliche« in jedem Bericht.
    """
    splits, teile = {}, set()
    for w in woerter:
        if len(w) < 9:
            continue
        kandidaten = []
        for i in range(4, len(w) - 3):
            for fuge in ("", "s", "es", "n", "en"):
                if fuge and w[i:i + len(fuge)].lower() != fuge:
                    continue
                a, b = w[:i], w[i + len(fuge):]
                if len(a) < 4 or len(b) < 4:
                    continue
                kandidaten.append((a, b[0].upper() + b[1:]))
                kandidaten.append((a, b.lower()))
        if kandidaten:
            splits[w] = kandidaten
            for a, b in kandidaten:
                teile.update((a, b))
    if not teile:
        return set()
    unbekannt = set(teile)
    for dic in dicts:
        unbekannt &= aspell_unbekannt(unbekannt, dic)
    return {w for w, kand in splits.items()
            if any(a not in unbekannt and b not in unbekannt for a, b in kand)}


def lade_allowlist():
    allow = set()
    if ALLOWLIST.exists():
        for line in ALLOWLIST.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                allow.add(line.split()[0])
    return allow


# ---------------------------------------------------------------------------
# Korpusindex
# ---------------------------------------------------------------------------
def sammle_pmb_namen():
    """pmb-ID → Liste von Namensformen aus indices/list*.xml."""
    namen = defaultdict(list)
    quellen = {
        "listperson.xml": ("person", ("persName", "forename", "surname")),
        "listplace.xml": ("place", ("placeName",)),
        "listorg.xml": ("org", ("orgName",)),
        "listevent.xml": ("event", ("eventName",)),
        "listbibl.xml": ("bibl", ("title",)),
    }
    bezirke = {}
    parser = etree.XMLParser(recover=True, huge_tree=True)
    for datei, (art, tags) in quellen.items():
        pfad = INDICES / datei
        if not pfad.exists():
            continue
        tree = etree.parse(str(pfad), parser)
        for entity in tree.getroot().iter():
            eid = entity.get(XML_ID)
            if not eid or not eid.startswith("pmb"):
                continue
            formen = []
            if art == "person":
                for pn in entity.findall(f"{{{TEI}}}persName"):
                    vor = pn.findtext(f"{{{TEI}}}forename", "").strip()
                    nach = pn.findtext(f"{{{TEI}}}surname", "").strip()
                    if vor or nach:
                        formen += [f"{vor} {nach}".strip(), nach, vor]
                    elif (pn.text or "").strip():
                        roh = pn.text.strip()
                        formen.append(roh)
                        if "," in roh:
                            n, v = [x.strip() for x in roh.split(",", 1)]
                            formen += [f"{v} {n}".strip(), n]
            else:
                for tag in tags:
                    for e in entity.findall(f"{{{TEI}}}{tag}"):
                        if (e.text or "").strip():
                            formen.append(e.text.strip())
            formen = [f for f in dict.fromkeys(formen)
                      if f and not f.startswith("http")]
            if formen:
                namen[eid] = formen[:8]
            # Wiener Bezirk (aus located_in_place, z. B. "XVIII., Währing")
            if art == "place":
                for loc in entity.findall(f"{{{TEI}}}location"):
                    for pn in loc.findall(f"{{{TEI}}}placeName"):
                        m = re.match(r"^([IVXL]{1,6})\.,", (pn.text or "").strip())
                        if m:
                            bezirke[eid] = m.group(1)
    return namen, bezirke


def baue_index(verbose=True):
    """Wortfrequenzen des Korpus + PMB-Namen + Attributinventar."""
    dateien = sorted(glob.glob(str(EDITIONS / "L*.xml")))
    if not dateien:
        sys.exit(f"Keine Dateien in {EDITIONS} gefunden.")
    if verbose:
        print(f"Korpusindex wird gebaut ({len(dateien)} Dateien) …")
    brief = Counter()
    komm = Counter()
    attrib = defaultdict(Counter)
    parser = etree.XMLParser(recover=True, huge_tree=True)
    for i, pfad in enumerate(dateien, 1):
        if verbose and i % 500 == 0:
            print(f"  {i}/{len(dateien)}")
        try:
            tree = etree.parse(pfad, parser)
        except Exception as e:                      # pragma: no cover
            print(f"  WARNUNG: {pfad}: {e}")
            continue
        root = tree.getroot()
        for body in root.iter(f"{{{TEI}}}body"):
            brief.update(w for w in WORD_RE.findall(normalisiere(render(body).text())))
            for note in body.iter(f"{{{TEI}}}note"):
                if note.get("type") == "commentary":
                    komm.update(WORD_RE.findall(render(note, skip=set()).text()))
        for el in root.iter():
            n = lname(el)
            if n is None:
                continue
            for a in ("type", "subtype", "rendition", "rend"):
                v = el.get(a)
                if v:
                    attrib[f"{n}/@{a}"][v] += 1
    namen, bezirke = sammle_pmb_namen()
    tokens = set()
    for formen in namen.values():
        for form in formen:
            tokens.update(w for w in re.split(r"\W+", form) if len(w) > 3)
    index = {
        "gebaut": datetime.now().isoformat(timespec="seconds"),
        "dateien": len(dateien),
        "brieftext": dict(brief),
        "kommentar": dict(komm),
        "attribute": {k: dict(v) for k, v in attrib.items()},
        "pmb": {k: v for k, v in namen.items()},
        "bezirke": bezirke,
        "namenstokens": sorted(tokens),
        "briefids": sorted(Path(p).stem for p in dateien),
    }
    CACHE.mkdir(parents=True, exist_ok=True)
    with gzip.open(INDEX_FILE, "wt", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False)
    if verbose:
        print(f"Index gespeichert: {INDEX_FILE} "
              f"({len(brief)} Brief-, {len(komm)} Kommentarwortformen)")
    return index


def lade_index(neu=False, verbose=True):
    if neu or not INDEX_FILE.exists():
        return baue_index(verbose=verbose)
    with gzip.open(INDEX_FILE, "rt", encoding="utf-8") as f:
        index = json.load(f)
    index["briefids"] = set(index.get("briefids", []))
    return index


# ---------------------------------------------------------------------------
# Befunde
# ---------------------------------------------------------------------------
class Befunde:
    STUFEN = {"fehler": 0, "pruefen": 1, "hinweis": 2}
    SYMBOL = {"fehler": "**[Fehler]**", "pruefen": "[Prüffall]", "hinweis": "[Hinweis]"}

    def __init__(self):
        self.items = []

    def add(self, bereich, kategorie, stufe, stelle, text):
        self.items.append({"bereich": bereich, "kategorie": kategorie,
                           "stufe": stufe, "stelle": stelle, "text": text})

    def sortiert(self, bereich):
        return sorted((i for i in self.items if i["bereich"] == bereich),
                      key=lambda i: (self.STUFEN[i["stufe"]], i["kategorie"]))

    def __len__(self):
        return len(self.items)


# --- einzelne Prüfungen ----------------------------------------------------
def pruefe_dopplungen(bef, bereich, text, stelle_praefix=""):
    for m in re.finditer(r"\b([^\W\d_]{2,})(\s+)([^\W\d_]{2,})\b", text, re.UNICODE):
        erst, zweit = m.group(1), m.group(3)
        if normalisiere(erst).lower() != normalisiere(zweit).lower():
            continue
        if erst.lower() in ("roda", "baden"):     # Roda Roda, Baden-Baden
            continue
        bef.add(bereich, "Wortdopplung", "pruefen", stelle_praefix,
                f"»{umfeld(text, m.start(), m.end())}«")
    # Wortgruppen-Dopplung (»seine Frau seine Frau«, »wegen – hauptsächlich wegen«)
    for m in re.finditer(r"\b((?:[^\W\d_]+\s+){2,4}?)[\s–—,-]*\1", text, re.UNICODE):
        bef.add(bereich, "Wortgruppe doppelt", "pruefen", stelle_praefix,
                f"»{umfeld(text, m.start(), m.end())}«")
    for m in re.finditer(r"([,;:.!?])\s*\1", text):
        bef.add(bereich, "Satzzeichen doppelt", "fehler", stelle_praefix,
                f"»{umfeld(text, m.start(), m.end())}«")


def pruefe_dreifach(bef, bereich, text, bekannt, stelle_praefix=""):
    for m in re.finditer(r"[^\W\d_]*([^\W\d_])\1\1[^\W\d_]*", text, re.UNICODE):
        wort = m.group(0)
        if normalisiere(wort).lower() in DREIFACH_OK:
            continue
        if bekannt and normalisiere(wort) in bekannt:
            continue
        bef.add(bereich, "Dreifachbuchstabe", "pruefen", stelle_praefix,
                f"»{wort}« – {umfeld(text, m.start(), m.end(), 35, 35)}")


def pruefe_paarigkeit(bef, bereich, text, stelle_praefix=""):
    paare = [("»", "«", "Guillemets"), ("›", "‹", "einfache Guillemets"),
             ("(", ")", "runde Klammern"), ("[", "]", "eckige Klammern")]
    for auf, zu, name in paare:
        a, z = text.count(auf), text.count(zu)
        if a != z:
            bef.add(bereich, "Unpaarige Zeichen", "pruefen", stelle_praefix,
                    f"{name}: {a}× »{auf}«, {z}× »{zu}«")
    for zeichen, name in (("„", "typografische Anführung unten „"),
                          ("“", "typografische Anführung oben “"),
                          ('"', "gerades Anführungszeichen"),
                          ("''", "doppelter Apostroph")):
        if zeichen in text:
            i = text.index(zeichen)
            bef.add(bereich, "Anführungszeichen-Stil", "pruefen", stelle_praefix,
                    f"{name} statt »«/›‹: {umfeld(text, i, i + 1)}")


def pruefe_unsichtbar(bef, bereich, text, stelle_praefix=""):
    for zeichen, name in UNSICHTBAR.items():
        if zeichen in text:
            i = text.index(zeichen)
            bef.add(bereich, "Unsichtbares Zeichen", "fehler", stelle_praefix,
                    f"{name}: {umfeld(text, i, i + 1)!r}")


def pruefe_zusammenlauf(bef, bereich, tb, stelle_praefix="", intern=False):
    """Fehlendes Leerzeichen an einer Elementgrenze (»vonSonntag«).

    Mit `intern` zusätzlich innerhalb von Wörtern (»FriedrichHofreiter«) –
    im Herausgebertext ist das immer ein Fehler, im Brieftext dagegen oft nur
    ein Darstellungsartefakt abgekürzter Unterschriften (»ArthSch«).
    """
    text = tb.text()
    if intern:
        for m in re.finditer(r"[a-zäöüßſ][A-ZÄÖÜ][a-zäöüß]", text):
            bef.add(bereich, "Fehlendes Leerzeichen", "fehler", stelle_praefix,
                    f"»{umfeld(text, m.start(), m.end(), 30, 30)}« – "
                    f"zwei Wörter laufen zusammen")
    gemeldet = set()
    for pos in tb.grenzen:
        if 0 < pos < len(text) and pos not in tb.entfernt:
            links, rechts = text[pos - 1], text[pos]
            if (links.isalpha() and links.islower()
                    and rechts.isalpha() and rechts.isupper()):
                if pos in gemeldet:
                    continue
                gemeldet.add(pos)
                bef.add(bereich, "Fehlendes Leerzeichen", "pruefen", stelle_praefix,
                        f"»{umfeld(text, pos - 1, pos + 1, 30, 30)}« – "
                        f"an der Elementgrenze laufen zwei Wörter zusammen")


def pruefe_wortschatz(bef, bereich, text, index_counter, allow, dicts,
                      stelle_praefix="", zitat_spans=(), zitat_hinweis="",
                      namen=frozenset()):
    """Unbekannte Wörter melden, angereichert mit der Korpushäufigkeit."""
    treffer = {}
    for m in WORD_RE.finditer(text):
        w = m.group(0)
        if len(w) < 3 or w.isupper():
            continue
        treffer.setdefault(w, []).append(m.span())
    if not treffer:
        return
    norm = {w: normalisiere(w) for w in treffer}
    unbekannt = set(norm.values())
    for dic in dicts:
        unbekannt &= aspell_unbekannt(unbekannt, dic)
        if not unbekannt:
            return
    unbekannt -= namen                              # Namen aus indices/list*.xml
    unbekannt -= kompositum_aufloesbar(unbekannt, dicts)
    if not unbekannt:
        return
    for w, spans in sorted(treffer.items()):
        if norm[w] not in unbekannt or w in allow or norm[w] in allow:
            continue
        haeufig = index_counter.get(norm[w], 0)
        if norm[w] != w:                 # ſ-Schreibung zählt mit
            haeufig += index_counter.get(w, 0)
        start, ende = spans[0]
        im_zitat = any(a <= start < b for a, b in zitat_spans)
        if haeufig > 2:
            continue                     # im Korpus etabliert (z. B. »thun«)

        # ſ/f-Verwechslung bzw. Nachbarwort im Korpus – das ist die eigentliche
        # Signatur eines Transkriptionsfehlers; bloß seltene Wörter haben keine.
        kandidat = ""
        for a, b in (("f", "s"), ("s", "f")):
            if a in norm[w]:
                probe = norm[w].replace(a, b)
                if probe != norm[w] and not aspell_unbekannt({probe}, dicts[0]):
                    kandidat = (f" – lies wohl "
                                f"»{probe.replace('s', 'ſ') if a == 'f' else probe}«")
                    break
        if not kandidat:
            nachbar = naechstes_korpuswort(norm[w], index_counter)
            if nachbar:
                kandidat = f" – nahe am korpusüblichen »{nachbar}«"

        if kandidat:
            stufe = "pruefen" if im_zitat else "fehler"
        elif len(w) >= 12:
            stufe = "hinweis"            # seltenes langes Wort, meist korrekt
        else:
            stufe = "pruefen"
        zusatz = f" (Korpus: {haeufig}×)" if haeufig else " (im Korpus einmalig)"
        if im_zitat and zitat_hinweis:
            zusatz += f" – {zitat_hinweis}"
        bef.add(bereich, "Unbekanntes Wort", stufe, stelle_praefix,
                f"»{w}«{zusatz}{kandidat}: {umfeld(text, start, ende, 40, 40)}")


def naechstes_korpuswort(wort, korpus, mindest=3, schwelle=0.86):
    """Ähnlichstes im Korpus etabliertes Wort – ohne bloße Flexionsformen."""
    if len(wort) < 4:
        return None
    kand = [k for k, n in korpus.items()
            if n >= mindest and abs(len(k) - len(wort)) <= 2
            and k[:1].lower() == wort[:1].lower()]
    beste, quote = None, 0.0
    wl = wort.lower()
    for k in kand:
        kl = k.lower()
        if kl == wl or kl.startswith(wl) or wl.startswith(kl):
            continue                      # Flexion/Ableitung, kein Fehlerhinweis
        r = difflib.SequenceMatcher(None, wl, kl).ratio()
        if r > quote:
            beste, quote = k, r
    return beste if quote >= schwelle else None


def pruefe_alte_orthografie(bef, text, stelle_praefix="", zitat_spans=()):
    """ß-Formen im Herausgebertext, die heute ss geschrieben werden.

    Zitate bleiben außen vor – dort ist die historische Schreibung korrekt.
    """
    ausserhalb = "".join(
        c if not any(a <= i < b for a, b in zitat_spans) else " "
        for i, c in enumerate(text))
    kandidaten = {w for w in WORD_RE.findall(ausserhalb) if "ß" in w or "ss" in w}
    text = ausserhalb
    if not kandidaten:
        return
    unbekannt_neu = aspell_unbekannt(kandidaten, ASPELL_NEU)
    for w in sorted(unbekannt_neu):
        variante = w.replace("ß", "ss") if "ß" in w else w.replace("ss", "ß")
        if not aspell_unbekannt({variante}, ASPELL_NEU):
            i = text.find(w)
            bef.add("Herausgebertext", "Alte/falsche Schreibung", "fehler",
                    stelle_praefix,
                    f"»{w}« → »{variante}«: {umfeld(text, i, i + len(w))}")


def pruefe_platzhalter(bef, roh, brieftext, kommentare):
    for m in re.finditer(r"XXXX", roh):
        zeile = roh[:m.start()].count("\n") + 1
        kontext = kompakt(roh[max(0, m.start() - 70):m.end() + 70])
        if 'idno type="handle"' in roh[max(0, m.start() - 60):m.start() + 10]:
            continue
        bef.add("Struktur", "Platzhalter XXXX", "fehler", f"Zeile {zeile}",
                f"…{kontext}…")
    for m in re.finditer(r'target=""', roh):
        zeile = roh[:m.start()].count("\n") + 1
        bef.add("Struktur", "Leeres target", "fehler", f"Zeile {zeile}",
                f"…{kompakt(roh[max(0, m.start() - 90):m.end() + 40])}…")
    for m in re.finditer(r'\b(when|quantity|medium|style|unit)=""', roh):
        zeile = roh[:m.start()].count("\n") + 1
        bef.add("Struktur", "Leeres Attribut", "pruefen", f"Zeile {zeile}",
                f"{m.group(1)}=\"\" – …{kompakt(roh[max(0, m.start() - 70):m.end() + 30])}…")
    for text, bereich in ((brieftext, "Brieftext"), (kommentare, "Herausgebertext")):
        for muster, name in ((r"\[→\]", "leerer Verweis [→]"),
                             (r"\bTODO\b|\bCHECK\b|\bFIXME\b", "Arbeitsnotiz"),
                             (r"\?\?+", "doppeltes Fragezeichen")):
            for m in re.finditer(muster, text):
                bef.add(bereich, "Redaktionelle Restspur", "fehler", "",
                        f"{name}: {umfeld(text, m.start(), m.end())}")


def pruefe_verweise(bef, root, briefid, index, briefdatum):
    """Selbstverweise, tote Verweise, Datumsplausibilität, Attributwerte."""
    refs = []
    attribut_inventar = index.get("attribute", {})
    for ref in root.iter(f"{{{TEI}}}ref"):
        typ = ref.get("type") or ""
        target = ref.get("target") or ""
        subtype = ref.get("subtype") or ""
        refs.append((typ, subtype, target))
        if target.strip("#") == briefid:
            bef.add("Verweise", "Selbstverweis", "fehler", "",
                    f'<ref type="{typ}" target="{target}"/> zeigt auf den Brief selbst')
        if typ == "schnitzler-briefe" and re.fullmatch(r"L\d{5}", target):
            if target not in index["briefids"] and not (TEMP / f"{target}.xml").exists():
                bef.add("Verweise", "Unbekanntes Briefziel", "fehler", "",
                        f"target=\"{target}\" – keine Datei editions/{target}.xml")
        if subtype:
            bekannt = attribut_inventar.get("ref/@subtype", {})
            if bekannt and bekannt.get(subtype, 0) < 3:
                haeufiger = [k for k in bekannt if k.lower() == subtype.lower()
                             and bekannt[k] > bekannt.get(subtype, 0)]
                zusatz = f" – korpusüblich ist »{haeufiger[0]}«" if haeufiger else ""
                bef.add("Verweise", "Ungewöhnlicher subtype", "pruefen", "",
                        f'subtype="{subtype}" (korpusweit {bekannt.get(subtype, 0)}×)'
                        f"{zusatz}")
        # source= ist nur für correspContext üblich; ein subtype-Wert darin
        # (z. B. source="see") ist ein Attributverwechsler
        quelle = ref.get("source") or ""
        if quelle and not quelle.startswith("correspondence_"):
            hinweis = (" – gemeint ist wohl subtype="
                       if quelle in attribut_inventar.get("ref/@subtype", {})
                       or quelle.lower() in ("see", "cf") else "")
            bef.add("Verweise", "Ungewöhnliches Attribut", "fehler" if hinweis
                    else "pruefen", "", f'<ref … source="{quelle}"/>{hinweis}')
    # Datumsplausibilität
    tabelle = []
    for typ, subtype, target in refs:
        m = re.fullmatch(r"(\d{4})-(\d{2})-(\d{2})", target)
        if not m:
            continue
        try:
            ziel = date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        except ValueError:
            bef.add("Verweise", "Ungültiges Datum", "fehler", "",
                    f'type="{typ}" target="{target}"')
            continue
        delta = (ziel - briefdatum).days if briefdatum else None
        tabelle.append((typ, subtype, target, delta))
        if delta is not None and abs(delta) > 365:
            bef.add("Verweise", "Datum weit vom Briefdatum", "pruefen", "",
                    f'type="{typ}" target="{target}" – {abs(delta) // 365} Jahr(e) '
                    f'{"nach" if delta > 0 else "vor"} dem Brief '
                    f'({briefdatum.isoformat()}); häufigster Fehlertyp: '
                    f"falsche Jahreszahl im Verweisziel")
    return tabelle


def in_note(el):
    """Steht das Element innerhalb einer Anmerkung?"""
    for vorfahr in el.iterancestors():
        if lname(vorfahr) == "note":
            return True
    return False


def jahr_passt(gefunden, jahr):
    """»905«, »05« und »1905« meinen alle dasselbe Jahr."""
    j = int(jahr)
    return gefunden in (j, j % 100, j % 1000)


def pruefe_datumselemente(bef, root):
    """<date when="…">Anzeigetext</date> auf Übereinstimmung prüfen."""
    for d in root.iter(f"{{{TEI}}}date"):
        when = d.get("when") or d.get("when-iso") or ""
        text = kompakt(render(d).text())
        m = re.match(r"(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?$", when)
        if not m or not text or "Chr." in text or int(m.group(1)) < 1700:
            continue                      # Platzhalter und antike Daten
        j, mo, t = m.group(1), m.group(2), m.group(3)
        gefunden = zerlege_datum(text)
        if not gefunden:
            continue
        gt, gm, gj = gefunden
        probleme = []
        if gj and j and not jahr_passt(gj, j):
            probleme.append(f"Jahr {gj} ≠ {j}")
        if gm and mo and gm != int(mo):
            probleme.append(f"Monat {gm} ≠ {int(mo)}")
        if gt and t and gt != int(t):
            probleme.append(f"Tag {gt} ≠ {int(t)}")
        if probleme:
            bef.add("Struktur", "Datum ≠ @when", "fehler", "",
                    f'<date when="{when}">{text}</date> – ' + "; ".join(probleme))


def zerlege_datum(text):
    """(Tag, Monat, Jahr) aus einem Datumstext; None, wo nichts steht."""
    text = text.strip()
    m = re.search(r"\b(\d{1,2})\.\s*(\d{1,2})\.\s*(\d{2,4})\b", text)
    if m:
        return int(m.group(1)), int(m.group(2)), int(m.group(3))
    m = re.search(r"\b(\d{1,2})[./](\d{1,2})\.?\s*(\d{2,4})\b", text)
    if m:
        return int(m.group(1)), int(m.group(2)), int(m.group(3))
    m = re.search(r"\b(\d{1,2})[./\s]+([IVX]{1,4})[./\s]+(\d{2,4})\b", text)
    if m and m.group(2) in ROEM_MONAT:
        return int(m.group(1)), ROEM_MONAT[m.group(2)], int(m.group(3))
    m = re.search(r"\b(\d{1,2})\.\s*([A-Za-zäöü]+)\.?\s*(\d{2,4})?\b", text)
    if m and m.group(2).lower() in MONATE:
        jahr = int(m.group(3)) if m.group(3) else None
        return int(m.group(1)), MONATE[m.group(2).lower()], jahr
    m = re.fullmatch(r"\D*(\d{4})\D*", text)
    if m:
        return None, None, int(m.group(1))
    return None


def pruefe_datumsformat(bef, text, stelle_praefix=""):
    """Editionskonvention »1. 2. 1900« im Herausgebertext."""
    for m in re.finditer(r"\b\d{1,2}\.\s?\d{1,2}\.(?=\d)", text):
        bef.add("Herausgebertext", "Datumsformat", "fehler", stelle_praefix,
                f"fehlendes Leerzeichen: {umfeld(text, m.start(), m.end(), 25, 25)}")
    for m in re.finditer(r"(?<![\d.])0\d\.\s*\d{4}\b|\b\d{1,2}\.\s*0\d\.\s*\d{4}\b", text):
        bef.add("Herausgebertext", "Datumsformat", "pruefen", stelle_praefix,
                f"führende Null: {umfeld(text, m.start(), m.end(), 25, 25)}")


def pruefe_rs_namen(bef, tb, index, bereich):
    """Anzeigetext eines rs mit dem PMB-Namen vergleichen (Tippfehler-Klasse)."""
    text = tb.text()
    pmb = index.get("pmb", {})
    for start, ende, ref, typ, subtype in tb.rs:
        if not ref or subtype == "implied":
            continue
        anzeige = kompakt(text[start:ende])
        formen = pmb.get(ref)
        if not anzeige or not formen:
            if not formen and ref.startswith("pmb"):
                bef.add(bereich, "Unbekannte PMB-ID", "pruefen", "",
                        f'{ref} (»{anzeige}«) steht in keiner Liste unter indices/')
            continue
        kern = re.sub(r"\W+$", "", anzeige)
        kern_l = normalisiere(kern).lower()
        formen_l = [normalisiere(f).lower() for f in formen]
        # Teilnennung (»Schnitzler« für »Arthur Schnitzler«) ist normal; ein
        # enthaltener Name deckt den Anzeigetext dagegen nur ab, wenn er
        # fast dessen ganze Länge hat (»Arthur Schnitzlers«).
        if any(kern_l == f or kern_l in f
               or (f in kern_l and len(f) >= 0.8 * len(kern_l))
               for f in formen_l):
            continue
        # Flexionsendungen (Genitiv/Plural) und Teilnennungen abziehen
        if any(kern_l.rstrip("sne") == f.rstrip("sne") for f in formen_l):
            continue
        def stamm(w):
            for _ in range(2):
                w = re.sub(r"(en|em|er|es|e|n|s)$", "", w)
            return w

        form_token = {stamm(w) for f in formen_l for w in re.split(r"\W+", f) if w}
        kern_token = [stamm(w) for w in re.split(r"\W+", kern_l)
                      if w and not w.isdigit()]
        if kern_token and all(k in form_token for k in kern_token):
            continue
        beste = max(formen, key=lambda f: difflib.SequenceMatcher(
            None, kern_l, f.lower()).ratio())
        quote = difflib.SequenceMatcher(None, kern_l, beste.lower()).ratio()
        if 0.72 <= quote < 1.0:
            bef.add(bereich, "Abweichender rs-Anzeigetext", "pruefen", "",
                    f"»{kern}« vs. PMB {ref} »{beste}« – "
                    f"{umfeld(text, start, ende, 30, 30)}")


def pruefe_bezirke(bef, tb, index, bereich):
    """»Wien XVII Spöttelgasse« – römische Zahl vor einer Adresse prüfen."""
    text = tb.text()
    bezirke = index.get("bezirke", {})
    for start, ende, ref, typ, subtype in tb.rs:
        bezirk = bezirke.get(ref)
        if not bezirk:
            continue
        vorlauf = text[max(0, start - 60):start]
        gefunden = [r for r in ROMAN_RE.findall(vorlauf) if r]
        if not gefunden:
            continue
        letzte = gefunden[-1]
        if letzte != bezirk:
            bef.add(bereich, "Bezirksangabe", "pruefen", "",
                    f"»{letzte}« vor »{kompakt(text[start:ende])}« – "
                    f"laut PMB {ref} liegt der Ort im {bezirk}. Bezirk: "
                    f"{umfeld(text, start, ende, 45, 20)}")


def pruefe_kommentar_formalien(bef, kommentare):
    """Formalia der Herausgeberkommentare."""
    for kid, text, _tb in kommentare:
        t = kompakt(text)
        if not t:
            bef.add("Herausgebertext", "Leerer Kommentar", "fehler", kid,
                    "Die Anmerkung enthält keinen Text")
            continue
        if t[-1] not in ".!?»)]‹":
            bef.add("Herausgebertext", "Kommentarende", "pruefen", kid,
                    f"endet ohne Satzzeichen: »… {t[-70:]}«")
        # Doppelte Signatur/Titelangabe (»SZ-AAP/L1. SZ-AAP/L1«)
        for m in re.finditer(r"([^\s,;:]{4,})[.,]?\s+\1\b", t):
            bef.add("Herausgebertext", "Doppelte Angabe", "pruefen", kid,
                    f"»{kompakt(m.group(0))}«")
        for muster, hinweis in (
            (r"\b(dass|daß)\s+(dass|daß)\b", "doppelte Konjunktion"),
            (r"\bam\s+im\b|\bim\s+am\b|\bzu\s+zum\b", "zwei Präpositionen"),
            (r"\bder\s+der\b|\bdie\s+die\b|\bdas\s+das\b", "doppelter Artikel"),
        ):
            for m in re.finditer(muster, t):
                bef.add("Herausgebertext", "Grammatik", "pruefen", kid,
                        f"{hinweis}: {umfeld(t, m.start(), m.end())}")


def pruefe_rs_genitiv(bef, roh):
    for m in re.finditer(r"s</rs>s\b", roh):
        zeile = roh[:m.start()].count("\n") + 1
        bef.add("Struktur", "Doppeltes Genitiv-s", "fehler", f"Zeile {zeile}",
                f"…{kompakt(roh[max(0, m.start() - 80):m.end() + 20])}…")


def pruefe_datierung(bef, root, briefdatum):
    """Datumszeile im Brief ↔ correspAction-Datierung."""
    for dl in root.iter(f"{{{TEI}}}dateline"):
        for d in dl.iter(f"{{{TEI}}}date"):
            if in_note(d):
                continue                  # Datum innerhalb einer Anmerkung
            zeile = kompakt(render(d).text())
            zerlegt = zerlege_datum(zeile)
            when = d.get("when") or ""
            if briefdatum and zerlegt:
                gt, gm, gj = zerlegt
                abweich = []
                if gj and not jahr_passt(gj, briefdatum.year):
                    abweich.append(f"Jahr {gj}")
                if gm and gm != briefdatum.month:
                    abweich.append(f"Monat {gm}")
                if gt and gt != briefdatum.day:
                    abweich.append(f"Tag {gt}")
                if abweich:
                    bef.add("Struktur", "Datierung ↔ Datumszeile", "pruefen", "",
                            f"Datumszeile »{zeile}« weicht von der Datierung "
                            f"{briefdatum.isoformat()} ab ({', '.join(abweich)}) – "
                            f"erklärende Anmerkung vorhanden?")
            if when and briefdatum and when != briefdatum.isoformat():
                bef.add("Struktur", "Datierung ↔ @when", "pruefen", "",
                        f'<dateline><date when="{when}"> ≠ correspAction '
                        f"{briefdatum.isoformat()}")


def pruefe_unterschrift(bef, root, absender_namen):
    for signed in root.iter(f"{{{TEI}}}signed"):
        t = kompakt(render(signed, skip=set()).text())
        if not t:
            continue
        tn = normalisiere(t).lower()
        if any(normalisiere(n).lower() in tn for n in absender_namen if len(n) > 2):
            continue
        if re.fullmatch(r"[^\w]*([A-ZÄÖÜ]\.?\s*){1,4}[^\w]*", t):
            continue           # Initialen
        bef.add("Brieftext", "Unterschrift", "hinweis", "",
                f"»{t}« enthält keinen Namensteil des Absenders "
                f"({', '.join(absender_namen)}) – prüfen")


# ---------------------------------------------------------------------------
# Bericht
# ---------------------------------------------------------------------------
def kopfdaten(root, briefid, pfad):
    d = {"id": briefid, "datei": str(pfad.relative_to(REPO)) if
         str(pfad).startswith(str(REPO)) else str(pfad)}
    t = root.find(f".//{{{TEI}}}titleStmt/{{{TEI}}}title[@level='a']")
    d["titel"] = kompakt(t.text or "") if t is not None else ""
    for typ in ("sent", "received"):
        ca = root.find(f".//{{{TEI}}}correspAction[@type='{typ}']")
        if ca is None:
            continue
        pers = [kompakt(render(p, skip=set()).text())
                for p in ca.findall(f"{{{TEI}}}persName")]
        orte = [kompakt(render(p, skip=set()).text())
                for p in ca.findall(f"{{{TEI}}}placeName")]
        dt = ca.find(f"{{{TEI}}}date")
        d[typ] = {
            "person": pers,
            "ref": [(p.get("ref") or "").lstrip("#")
                    for p in ca.findall(f"{{{TEI}}}persName")],
            "ort": orte,
            "datum": (dt.get("when") or dt.get("notBefore") or "") if dt is not None else "",
            "datumstext": kompakt(render(dt, skip=set()).text()) if dt is not None else "",
        }
    rev = root.find(f".//{{{TEI}}}revisionDesc")
    d["status"] = rev.get("status") if rev is not None else ""
    d["aenderungen"] = [kompakt(render(c, skip=set()).text())
                        for c in root.iter(f"{{{TEI}}}change")]
    return d


def briefdatum_aus(kopf):
    for typ in ("sent", "received"):
        w = kopf.get(typ, {}).get("datum", "")
        m = re.match(r"(\d{4})-(\d{2})-(\d{2})", w)
        if m:
            return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    return None


def bericht(kopf, bef, brieftext, kommentare, textconst, refs_tabelle, indexinfo):
    z = []
    a = z.append
    a(f"# Maschinelle Vorprüfung {kopf['id']}")
    a("")
    a(f"Datei: `{kopf['datei']}` · erstellt: {datetime.now():%Y-%m-%d %H:%M} · "
      f"Korpusindex: {indexinfo}")
    a("")
    a("## 0 Kopfdaten")
    a("")
    a(f"- **Titel:** {kopf['titel']}")
    for typ, label in (("sent", "Absender"), ("received", "Empfänger")):
        k = kopf.get(typ)
        if k:
            a(f"- **{label}:** {', '.join(k['person'])} "
              f"({', '.join(k['ref'])}) · Ort: {', '.join(k['ort']) or '–'}"
              + (f" · Datum: {k['datum']} »{k['datumstext']}«" if k["datum"] or k["datumstext"] else ""))
    a(f"- **revisionDesc:** status=\"{kopf['status']}\"; "
      f"{'; '.join(kopf['aenderungen'][-3:])}")
    a("")

    a(f"## 1 Maschinelle Befunde ({len(bef)})")
    a("")
    if not len(bef):
        a("Keine maschinellen Auffälligkeiten.")
        a("")
    for bereich in ("Struktur", "Verweise", "Herausgebertext", "Brieftext"):
        items = bef.sortiert(bereich)
        if not items:
            continue
        a(f"### 1.{['Struktur', 'Verweise', 'Herausgebertext', 'Brieftext'].index(bereich) + 1} "
          f"{bereich} ({len(items)})")
        a("")
        for i in items:
            stelle = f" _{i['stelle']}_" if i["stelle"] else ""
            a(f"- {Befunde.SYMBOL[i['stufe']]} {i['kategorie']}{stelle}: {i['text']}")
        a("")

    a("## 2 Brieftext (Klartext, Lang-ſ beibehalten)")
    a("")
    a("```")
    a(kompakt_absaetze(brieftext))
    a("```")
    a("")

    a(f"## 3 Herausgeberkommentare ({len(kommentare)})")
    a("")
    if not kommentare:
        a("Keine `note type=\"commentary\"`.")
        a("")
    for kid, text, _ in kommentare:
        a(f"**{kid}**  {kompakt(text)}")
        a("")
    if textconst:
        a(f"## 4 textConst-Anmerkungen ({len(textconst)})")
        a("")
        for kid, text, _ in textconst:
            a(f"- **{kid}**: {kompakt(text)}")
        a("")

    a("## 5 Datumsverweise")
    a("")
    if refs_tabelle:
        a("| type | subtype | target | Abstand zum Briefdatum |")
        a("|---|---|---|---|")
        for typ, subtype, target, delta in sorted(
                refs_tabelle, key=lambda r: abs(r[3] or 0), reverse=True):
            d = f"{delta:+d} Tage" if delta is not None else "–"
            a(f"| {typ} | {subtype or '–'} | {target} | {d} |")
    else:
        a("Keine datierten Verweise.")
    a("")
    a("---")
    a("")
    a("Weiter mit der kritischen Lektüre nach `pruefung/ANWEISUNG.md`.")
    return "\n".join(z)


def kompakt_absaetze(text):
    zeilen = [kompakt(z) for z in text.split("\n")]
    return "\n".join(z for z in zeilen if z)


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def finde_datei(arg):
    p = Path(arg)
    if p.exists():
        return p.resolve()
    stem = p.stem.upper()
    if not stem.startswith("L"):
        stem = "L" + stem
    if len(stem) < 6:
        stem = "L" + stem[1:].zfill(5)
    for ordner in (EDITIONS, TEMP):
        kand = ordner / f"{stem}.xml"
        if kand.exists():
            return kand
    sys.exit(f"Datei nicht gefunden: {arg} (weder als Pfad noch in editions/ oder temp/)")


def main():
    ap = argparse.ArgumentParser(
        description="Maschinelle Vorprüfung eines Briefes (siehe pruefung/ANWEISUNG.md)")
    ap.add_argument("brief", nargs="?", help="Datei-ID (L04318) oder Pfad")
    ap.add_argument("--out", help="Bericht zusätzlich in diese Datei schreiben")
    ap.add_argument("--index-neu", action="store_true",
                    help="Korpusindex neu aufbauen und beenden (falls kein Brief angegeben)")
    ap.add_argument("--quiet", action="store_true", help="keine Fortschrittsmeldungen")
    args = ap.parse_args()

    if args.index_neu and not args.brief:
        baue_index(verbose=not args.quiet)
        return
    if not args.brief:
        ap.error("Bitte eine Datei-ID oder einen Pfad angeben (oder --index-neu).")

    pfad = finde_datei(args.brief)
    briefid = pfad.stem
    index = lade_index(neu=args.index_neu, verbose=not args.quiet)
    if isinstance(index.get("briefids"), list):
        index["briefids"] = set(index["briefids"])
    allow = lade_allowlist()

    roh = pfad.read_text(encoding="utf-8")
    parser = etree.XMLParser(recover=False, huge_tree=True)
    try:
        tree = etree.parse(str(pfad), parser)
    except etree.XMLSyntaxError as e:
        sys.exit(f"XML nicht wohlgeformt: {e}")
    root = tree.getroot()

    kopf = kopfdaten(root, briefid, pfad)
    briefdatum = briefdatum_aus(kopf)
    bef = Befunde()

    body = root.find(f".//{{{TEI}}}body")
    if body is None:
        sys.exit("Kein <body> gefunden.")

    # Brieftext (ohne editorische Elemente)
    brieftb = render(body)
    brieftext = brieftb.text()

    # Herausgebertext
    kommentare, textconst = [], []
    for note in body.iter(f"{{{TEI}}}note"):
        typ = note.get("type") or ""
        tb = render(note, skip={"listBibl"} if typ == "commentary" else set())
        kid = (note.get("corresp") or note.get(XML_ID) or "").replace("K_", "") or typ
        if typ == "commentary":
            kommentare.append((kid, tb.text(), tb))
        elif typ == "textConst":
            textconst.append((kid, tb.text(), tb))
    for supplied in body.iter(f"{{{TEI}}}supplied"):
        if supplied.get("type") == "image-description":
            tb = render(supplied, skip=set())
            kommentare.append(("Bildbeschreibung", tb.text(), tb))
    kommentartext = "\n".join(t for _, t, _ in kommentare)

    # Steht der Brief schon in editions/, dann steckt er selbst im Korpusindex;
    # seine eigenen Wörter werden abgezogen, damit »einmalig« auch einmalig heißt.
    eigen = pfad.parent.resolve() == EDITIONS.resolve()

    # --- Prüfungen: Brieftext
    korpus_brief = abzug(index["brieftext"], normalisiere(brieftext)) if eigen \
        else index["brieftext"]
    pruefe_dopplungen(bef, "Brieftext", brieftext)
    pruefe_dreifach(bef, "Brieftext", brieftext, korpus_brief)
    pruefe_paarigkeit(bef, "Brieftext", brieftext)
    pruefe_unsichtbar(bef, "Brieftext", brieftext)
    pruefe_zusammenlauf(bef, "Brieftext", brieftb)
    namen = set(index.get("namenstokens", []))
    pruefe_wortschatz(bef, "Brieftext", normalisiere(brieftext), korpus_brief, allow,
                      [ASPELL_NEU, ASPELL_ALT], namen=namen)
    pruefe_rs_namen(bef, brieftb, index, "Brieftext")
    pruefe_bezirke(bef, brieftb, index, "Brieftext")
    absender = kopf.get("sent", {}).get("person", [])
    namensteile = [teil.strip() for n in absender for teil in re.split(r"[,\s]+", n) if teil.strip()]
    if namensteile:
        pruefe_unterschrift(bef, root, namensteile)

    # --- Prüfungen: Herausgebertext
    korpus_komm = abzug(index["kommentar"], kommentartext) if eigen \
        else index["kommentar"]
    for kid, text, tb in kommentare:
        pruefe_dopplungen(bef, "Herausgebertext", text, kid)
        pruefe_dreifach(bef, "Herausgebertext", text, korpus_komm, kid)
        pruefe_paarigkeit(bef, "Herausgebertext", text, kid)
        pruefe_unsichtbar(bef, "Herausgebertext", text, kid)
        pruefe_zusammenlauf(bef, "Herausgebertext", tb, kid, intern=True)
        pruefe_datumsformat(bef, text, kid)
        pruefe_alte_orthografie(bef, text, kid, tb.zitat)
        pruefe_wortschatz(bef, "Herausgebertext", text, korpus_komm, allow,
                          [ASPELL_NEU], kid, zitat_spans=tb.zitat,
                          zitat_hinweis="steht in einem Zitat, ggf. [sic]",
                          namen=namen)
        pruefe_rs_namen(bef, tb, index, "Herausgebertext")
    pruefe_kommentar_formalien(bef, kommentare)

    # --- Prüfungen: Struktur und Verweise
    pruefe_platzhalter(bef, roh, brieftext, kommentartext)
    pruefe_rs_genitiv(bef, roh)
    pruefe_datumselemente(bef, root)
    pruefe_datierung(bef, root, briefdatum)
    refs_tabelle = pruefe_verweise(bef, root, briefid, index, briefdatum)

    text = bericht(kopf, bef, brieftext, kommentare, textconst, refs_tabelle,
                   f"{index['dateien']} Dateien, {index['gebaut'][:10]}")
    if args.out:
        out = Path(args.out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text + "\n", encoding="utf-8")
        if not args.quiet:
            print(f"Bericht geschrieben: {out}")
    print(text)


if __name__ == "__main__":
    main()
