#!/usr/bin/env python3
"""
Trägt den genauesten Ort aus der Adresse (div[@type="address"]) automatisch
als placeName/@ref in die dafür zuständige correspAction ein:

    correspAction[@type='redirected'] - die erste, falls mehrere (der Ort, wie
    ursprünglich adressiert, bevor der Brief weitergeleitet wurde)
    sonst
    correspAction[@type='received']

Diese Zielregel generalisiert über Umleitungsketten (mehrere redirected
hintereinander, z. B. L01941.xml) und über Fälle mit correspAction[@type=
'transmitted'] vor 'redirected' (z. B. L01014.xml, Telegramme): der
Zielknoten wird über @type gesucht, nicht über Position. Ob ein Brief
weitergeleitet wurde, wird an der bereits vorhandenen correspAction[@type=
'redirected'] abgelesen - nicht an stamp/incident, da Umleitungen im Korpus
auch ohne <stamp> nur als Freitext in incident/desc stehen (z. B.
L00240.xml) und incident[@type='postal'] allein viel zu häufig ist (auch
gewöhnliche Poststempel), um als Signal zu taugen.

Quelle ist die LETZTE <address> innerhalb von div[@type="address"] - manche
Umschläge haben mehrere <address>-Elemente (z. B. ein Siegel-Vermerk vor der
eigentlichen Adresse, siehe L00079.xml), maßgeblich ist die letzte.

Innerhalb dieser Adresse gibt es oft mehrere rs[@type="place"]
(Ort/Straße/Hausnummer/Hotel/Land gleichermaßen ausgezeichnet) - gewünscht
ist immer der genaueste Punkt (Straße mit Hausnummer, Hotel etc.), nicht
zwingend der positionell letzte: bei L04415.xml etwa steht das Land
("Austria") in der letzten addrLine, die Straße ("Tiefer Graben 23") aber
in der vorletzten. Die Genauigkeit wird deshalb nicht über die Position,
sondern über die Orts-Hierarchie aus indices/listplace.xml bestimmt
(location[@type="located_in_place"]/placeName/@key): von allen
rs[@type="place"]-Refs der Adresse ist der genaueste Punkt derjenige, der
kein Vorfahre eines anderen Kandidaten in derselben Adresse ist (das
"Blatt" der Hierarchie), z. B. "Pension Quisisana" (located_in "Abbazia").

Schreibverhalten:
    - Ziel-correspAction hat noch kein placeName/@ref  -> wird eingetragen (neu)
    - Ziel hat bereits denselben Ref                    -> nichts zu tun
    - Ziel hat einen Ref, der laut Hierarchie ein Vorfahre des genaueren
      Adress-Refs ist (z. B. "Abbazia" statt "Pension Quisisana")
                                                          -> wird auf den
                                                             genaueren Ref
                                                             hochgestuft
    - Ziel hat einen Ref, der genauer oder unverwandt ist -> Prüffall,
      nichts wird überschrieben
    - mehrere unverwandte "Blatt"-Kandidaten in der Adresse (Hierarchie
      klärt die Mehrdeutigkeit nicht auf)                -> Prüffall

Aufruf (aus dem Repo-Wurzelverzeichnis):
    python3 adresse_ort_eintragen.py             # Dry-Run, nur Bericht
    python3 adresse_ort_eintragen.py --write     # schreibt Änderungen
    python3 adresse_ort_eintragen.py --file L00240 [--write]
"""

import argparse
import re
import sys
from pathlib import Path

from lxml import etree

sys.path.insert(0, str(Path(__file__).resolve().parent))
from stempel_abgleich import (  # noqa: E402
    EDITIONS,
    CORRESP_ACTION_RE,
    TYPE_ATTR_RE,
    apply_place_to_block,
    build_place_elem,
    indent_of,
    load_text,
    validate_and_save,
)

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
REPO = Path(__file__).resolve().parent.parent
LISTPLACE_PATH = REPO / "indices" / "listplace.xml"


# ---------------------------------------------------------------------------
# Orts-Hierarchie aus indices/listplace.xml
# ---------------------------------------------------------------------------
def load_parent_map(path=LISTPLACE_PATH):
    """id (ohne '#', z. B. 'pmb756') -> Liste der direkten located_in-Eltern-ids."""
    tree = etree.parse(str(path))
    parents = {}
    for place in tree.iter(f"{{{NS['tei']}}}place"):
        pid = place.get("{http://www.w3.org/XML/1998/namespace}id")
        if not pid:
            continue
        keys = place.xpath(
            "./tei:location[@type='located_in_place']/tei:placeName/@key", namespaces=NS
        )
        parents[pid] = [k[1:] if k.startswith("#") else k for k in keys]
    return parents


def ancestors(ref, parent_map):
    """Transitive Hülle der located_in-Eltern von ref (ohne '#')."""
    seen = set()
    stack = list(parent_map.get(ref, []))
    while stack:
        p = stack.pop()
        if p in seen:
            continue
        seen.add(p)
        stack.extend(parent_map.get(p, []))
    return seen


def most_precise(refs, parent_map):
    """Von mehreren Orts-Refs (mit '#') denjenigen zurückgeben, der laut
    Hierarchie kein Vorfahre eines anderen Kandidaten ist (das "Blatt").
    None bei Mehrdeutigkeit (0 oder >1 solcher Blätter)."""
    bare = [r[1:] if r.startswith("#") else r for r in refs]
    unique = sorted(set(bare))
    if len(unique) == 1:
        return refs[bare.index(unique[0])]
    anc_of = {r: ancestors(r, parent_map) for r in unique}
    leaves = [r for r in unique if not any(r in anc_of[other] for other in unique if other != r)]
    if len(leaves) != 1:
        return None
    return refs[bare.index(leaves[0])]


# ---------------------------------------------------------------------------
# Auslesen aus der Brief-Datei
# ---------------------------------------------------------------------------
def find_source_place(tree, parent_map):
    """{"ref", "text"} des genauesten Orts in der letzten <address>, oder
    None (keine Adresse/kein Orts-rs), oder {"ambiguous": True}."""
    addresses = tree.xpath(
        "//tei:div[@type='address']/tei:address", namespaces=NS
    )
    if not addresses:
        return None
    last_address = addresses[-1]
    nodes = last_address.xpath(".//tei:rs[@type='place']", namespaces=NS)
    candidates = [n for n in nodes if n.get("ref")]
    if not candidates:
        return None

    refs = [n.get("ref") for n in candidates]
    best_ref = most_precise(refs, parent_map)
    if best_ref is None:
        return {"ambiguous": True}
    node = candidates[refs.index(best_ref)]
    text = "".join(node.itertext()).strip()
    if not text:
        return None
    return {"ref": best_ref, "text": text}


def find_target_type(tree):
    if tree.xpath("boolean(//tei:correspAction[@type='redirected'])", namespaces=NS):
        return "redirected"
    if tree.xpath("boolean(//tei:correspAction[@type='received'])", namespaces=NS):
        return "received"
    return None


def find_target_place_ref(tree, target_type):
    refs = tree.xpath(
        f"(//tei:correspAction[@type='{target_type}'])[1]/tei:placeName/@ref",
        namespaces=NS,
    )
    return refs[0] if refs else None


def process(fid, write, parent_map):
    text = load_text(fid)
    try:
        tree = etree.fromstring(text.encode("utf-8"))
    except etree.XMLSyntaxError as e:
        return f"{fid}: XML-Fehler ({e})"

    source = find_source_place(tree, parent_map)
    if source is None:
        return None
    if source.get("ambiguous"):
        return f"{fid}: mehrere unverwandte Orts-rs in der Adresse - Prüffall"

    target_type = find_target_type(tree)
    if target_type is None:
        return None

    existing_ref = find_target_place_ref(tree, target_type)
    action_word = "neu"
    if existing_ref == source["ref"]:
        return None
    if existing_ref:
        existing_bare = existing_ref[1:] if existing_ref.startswith("#") else existing_ref
        source_bare = source["ref"][1:] if source["ref"].startswith("#") else source["ref"]
        if existing_bare not in ancestors(source_bare, parent_map):
            return (
                f"{fid}: correspAction[@type='{target_type}'] hat bereits "
                f"placeName/@ref={existing_ref!r}, Adresse liefert genaueren/"
                f"unverwandten Ref {source['ref']!r} - Prüffall (nicht überschrieben)"
            )
        action_word = "praezisiert"

    blocks = list(CORRESP_ACTION_RE.finditer(text))
    target_block = None
    for b in blocks:
        m = TYPE_ATTR_RE.search(b.group(0))
        if m and m.group(1) == target_type:
            target_block = b
            break
    if target_block is None:
        return f"{fid}: Ziel-correspAction im Rohtext nicht gefunden - Prüffall"

    block_text = target_block.group(0)
    indent = indent_of(text, target_block.start())
    child_m = re.search(r"\n([ \t]+)<\w", block_text)
    child_indent = child_m.group(1) if child_m else indent + "   "

    new_place_elem = build_place_elem(source)
    new_block_text = apply_place_to_block(block_text, child_indent, new_place_elem)
    if new_block_text == block_text:
        return None

    new_text = text[: target_block.start()] + new_block_text + text[target_block.end() :]

    if write:
        validate_and_save(fid, text, new_text)
    suffix = "" if write else " [dry-run]"
    prefix = "präzisiert" if action_word == "praezisiert" else "neu"
    return (
        f"{fid}: correspAction[@type='{target_type}']/placeName -> "
        f"ref={source['ref']!r} ({source['text']!r}) [{prefix}]{suffix}"
    )


def main():
    ap = argparse.ArgumentParser(description="Genauesten Ort aus Adresse in correspAction eintragen")
    ap.add_argument("--write", action="store_true", help="Änderungen tatsächlich schreiben (sonst Dry-Run)")
    ap.add_argument("--file", help="nur eine einzelne Datei (ohne .xml)")
    args = ap.parse_args()

    parent_map = load_parent_map()

    files = [args.file] if args.file else sorted(p.stem for p in EDITIONS.glob("*.xml"))

    changed = 0
    review = 0
    errors = 0
    for fid in files:
        try:
            msg = process(fid, args.write, parent_map)
        except Exception as e:  # noqa: BLE001
            print(f"{fid}: FEHLER beim Schreiben ({e})")
            errors += 1
            continue
        if msg is None:
            continue
        print(msg)
        if "Prüffall" in msg:
            review += 1
        else:
            changed += 1

    verb = "geändert" if args.write else "zu ändern"
    print(f"\n{changed} {verb}, {review} Prüffälle, {errors} Fehler.")


if __name__ == "__main__":
    main()
