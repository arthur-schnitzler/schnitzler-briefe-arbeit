#!/usr/bin/env python3
"""
Findet Fälle im //body//text, wo zwei Inline-Elemente aufeinanderstoßen,
die nicht <space/> sind und zwischen denen kein Whitespace steht.
"""

import xml.etree.ElementTree as ET
from pathlib import Path


def get_element_text_end(elem):
    """Holt die letzten Zeichen aus einem Element."""
    # Zuerst: Wenn Element Kinder hat, nimm den tail des letzten Kindes
    if len(elem):
        last_child = elem[-1]
        if last_child.tail and last_child.tail.strip():
            return last_child.tail.strip()[-20:]
        # Sonst den Text des letzten Kindes
        text = get_element_text_end(last_child)
        if text:
            return text

    # Wenn keine Kinder, nimm den Text des Elements selbst
    if elem.text and elem.text.strip():
        return elem.text.strip()[-20:]

    return ""


def get_element_text_start(elem):
    """Holt die ersten Zeichen aus einem Element."""
    # Zuerst: Wenn Element Text hat, nimm diesen
    if elem.text and elem.text.strip():
        return elem.text.strip()[:20]

    # Sonst: Wenn Element Kinder hat, nimm den Text des ersten Kindes
    if len(elem):
        first_child = elem[0]
        text = get_element_text_start(first_child)
        if text:
            return text

    return ""


def is_inline_element(elem):
    """Prüft, ob ein Element ein Inline-Element ist."""
    tag = elem.tag
    if isinstance(tag, str):
        tag = tag.split('}')[-1]
        inline_tags = ['rs', 'add', 'del', 'hi', 'supplied', 'unclear',
                       'c', 'subst', 'choice', 'sic', 'corr', 'abbr',
                       'expan', 'date', 'time', 'measure', 'num']
        return tag in inline_tags
    return False


def should_skip_element(elem):
    """Prüft, ob ein Element übersprungen werden soll."""
    tag = elem.tag
    if isinstance(tag, str):
        tag = tag.split('}')[-1]
        skip_tags = ['pb', 'lb', 'note', 'anchor', 'seg', 'p',
                     'salute', 'closer', 'opener', 'dateline', 'signed',
                     'subst']
        return tag in skip_tags
    return False


def is_inside_subst(elem, root):
    """Prüft, ob ein Element innerhalb eines <subst> Elements ist."""
    # Durchlaufe alle Vorfahren des Elements
    parent = elem
    while parent is not None:
        tag = parent.tag
        if isinstance(tag, str):
            tag = tag.split('}')[-1]
            if tag == 'subst':
                return True
        # Finde Parent (ineffizient, aber funktioniert)
        parent = None
        for candidate in root.iter():
            if elem in list(candidate):
                parent = candidate
                elem = parent
                break
    return False


def process_file(filepath):
    """Verarbeitet eine XML-Datei und findet problematische Stellen."""
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()

        ns = {'tei': 'http://www.tei-c.org/ns/1.0'}

        # Finde alle writingSession divs im body
        sessions = root.findall(
            './/tei:body//tei:div[@type="writingSession"]', ns)
        if not sessions:
            return []

        issues = []

        def walk(element, parent_is_subst=False):
            result = []
            children = list(element)

            # Prüfe, ob aktuelles Element ein subst ist
            elem_tag = (element.tag.split('}')[-1]
                       if isinstance(element.tag, str)
                       else str(element.tag))
            is_subst = elem_tag == 'subst'

            for i in range(len(children) - 1):
                current = children[i]
                next_elem = children[i + 1]

                # Überspringe space-Elemente
                next_tag = (next_elem.tag.split('}')[-1]
                            if isinstance(next_elem.tag, str)
                            else str(next_elem.tag))

                if next_tag == 'space':
                    continue

                # Überspringe, wenn wir innerhalb eines subst sind
                if parent_is_subst or is_subst:
                    result.extend(walk(current, is_subst))
                    continue

                # Nur prüfen, wenn beide Inline-Elemente sind
                if not (is_inline_element(current)
                        and is_inline_element(next_elem)):
                    # Rekursiv in Kinder gehen
                    result.extend(walk(current, is_subst))
                    continue

                # Prüfe den tail des aktuellen Elements
                tail = current.tail if current.tail else ""

                # Wenn tail leer ist oder nur Whitespace enthält
                if not tail.strip():
                    current_text = get_element_text_end(current)
                    next_text = get_element_text_start(next_elem)

                    if current_text and next_text:
                        snippet = current_text + next_text
                        result.append(snippet)

                # Rekursiv in Kinder gehen
                result.extend(walk(current, is_subst))

            # Letztes Kind auch durchgehen
            if children:
                result.extend(walk(children[-1], is_subst))

            return result

        for session in sessions:
            issues.extend(walk(session))

        return issues

    except Exception as e:
        print(f"Fehler bei {filepath}: {e}")
        return []


def main():
    editions_dir = Path("editions")

    if not editions_dir.exists():
        print("Verzeichnis 'editions' nicht gefunden!")
        return

    print("Prüfe XML-Dateien auf fehlende <space/>-Elemente...\n")

    found_issues = False

    for xml_file in sorted(editions_dir.glob("L*.xml")):
        issues = process_file(xml_file)

        if issues:
            found_issues = True
            print(f"{xml_file.stem}")
            for issue in issues:
                print(f"{issue}")
            print()

    if not found_issues:
        print("Keine Probleme gefunden!")


if __name__ == "__main__":
    main()
