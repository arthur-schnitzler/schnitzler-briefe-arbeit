import xml.etree.ElementTree as ET
from xml.dom import minidom
import urllib.request
import glob
import os

# Namespace definieren
NS = {'tei': 'http://www.tei-c.org/ns/1.0'}

# Temp-Verzeichnis erstellen
os.makedirs("./temp-indices", exist_ok=True)

# Zu verarbeitende Elemente und Zieldateien
targets = [
    ("persName", "./temp-indices/mentioned-persons.xml"),
    ("placeName", "./temp-indices/mentioned-places.xml"),
    ("orgName", "./temp-indices/mentioned-orgs.xml"),
    ("work", "./temp-indices/mentioned-bibl.xml"),
    ("event", "./temp-indices/mentioned-event.xml")
]

# Hilfsfunktion: XML schön formatieren
def pretty_xml(element):
    rough_string = ET.tostring(element, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")

# Sets für spätere Verwendung
mentioned_person_keys = set()
work_ids = set()

# Verarbeitung aller L*.xml Dateien in ./editions/
xml_files = glob.glob("./editions/L*.xml")

for tag_name, output_filename in targets:
    keys = set()

    for xml_file in xml_files:
        try:
            tree = ET.parse(xml_file)
            root = tree.getroot()
            
            # Nur tei:back Elemente verarbeiten
            back_elements = root.findall(".//tei:back", namespaces=NS)
            
            for back in back_elements:
                # Spezielle Behandlung für alle Entitätstypen - nur direkte Kinder berücksichtigen
                # Alle verschachtelten Entitäten in person/bibl/place/org-Elementen ignorieren
                
                if tag_name == "persName":
                    # Nur direkte tei:listPerson/tei:person (nicht verschachtelt)
                    for list_person in back.findall("./tei:listPerson", namespaces=NS):
                        for elem in list_person.findall("./tei:person", namespaces=NS):
                            key = elem.get("key") or elem.get("ref") or elem.get("{http://www.w3.org/XML/1998/namespace}id")
                            if key and key.startswith("pmb"):
                                clean_key = key.replace("pmb", "", 1)
                                keys.add(clean_key)
                
                elif tag_name == "work":
                    # Nur direkte tei:listBibl/tei:bibl (nicht verschachtelt)
                    for list_bibl in back.findall("./tei:listBibl", namespaces=NS):
                        for elem in list_bibl.findall("./tei:bibl", namespaces=NS):
                            key = elem.get("key") or elem.get("ref") or elem.get("{http://www.w3.org/XML/1998/namespace}id")
                            if key and key.startswith("pmb"):
                                clean_key = key.replace("pmb", "", 1)
                                keys.add(clean_key)
                                work_ids.add(clean_key)
                
                elif tag_name == "placeName":
                    # Nur direkte tei:listPlace/tei:place (nicht verschachtelt)
                    for list_place in back.findall("./tei:listPlace", namespaces=NS):
                        for elem in list_place.findall("./tei:place", namespaces=NS):
                            key = elem.get("key") or elem.get("ref") or elem.get("{http://www.w3.org/XML/1998/namespace}id")
                            if key and key.startswith("pmb"):
                                clean_key = key.replace("pmb", "", 1)
                                keys.add(clean_key)
                
                elif tag_name == "orgName":
                    # Nur direkte tei:listOrg/tei:org (nicht verschachtelt)
                    for list_org in back.findall("./tei:listOrg", namespaces=NS):
                        for elem in list_org.findall("./tei:org", namespaces=NS):
                            key = elem.get("key") or elem.get("ref") or elem.get("{http://www.w3.org/XML/1998/namespace}id")
                            if key and key.startswith("pmb"):
                                clean_key = key.replace("pmb", "", 1)
                                keys.add(clean_key)
                
                elif tag_name == "event":
                    # Nur direkte tei:listEvent/tei:event (nicht in person/bibl/place/org verschachtelt)
                    for list_event in back.findall("./tei:listEvent", namespaces=NS):
                        for elem in list_event.findall("./tei:event", namespaces=NS):
                            key = elem.get("key") or elem.get("ref") or elem.get("{http://www.w3.org/XML/1998/namespace}id")
                            if key and key.startswith("pmb"):
                                clean_key = key.replace("pmb", "", 1)
                                keys.add(clean_key)

        except ET.ParseError as e:
            print(f"Fehler beim Parsen von {xml_file}: {e}")
        except Exception as e:
            print(f"Fehler beim Verarbeiten von {xml_file}: {e}")

    # Nur bei Personen sofort merken für später
    if tag_name == "persName":
        mentioned_person_keys.update(keys)

    # XML-Struktur erzeugen und schreiben
    list_elem = ET.Element("list")
    for key in sorted(keys):
        item = ET.SubElement(list_elem, "item")
        item.text = key

    with open(output_filename, "w", encoding="utf-8") as f:
        f.write(pretty_xml(list_elem))

# ===== Autoren der Werke aus listbibl.xml nachschlagen =====
try:
    response = urllib.request.urlopen("https://pmb.acdh.oeaw.ac.at/media/listbibl.xml")
    listbibl_tree = ET.parse(response)
    listbibl_root = listbibl_tree.getroot()

    work_keys_in_listbibl = {f"work__{wid}" for wid in work_ids}

    for bibl in listbibl_root.findall(".//tei:bibl", namespaces=NS):
        bibl_key = bibl.get("{http://www.w3.org/XML/1998/namespace}id")  # xml:id beachten!
        if bibl_key and bibl_key in work_keys_in_listbibl:
            for author in bibl.findall(".//tei:author", namespaces=NS):
                author_key = author.get("key")
                if author_key and author_key.startswith("person__"):
                    author_id = author_key.replace("person__", "")
                    mentioned_person_keys.add(author_id)

except Exception as e:
    print(f"Fehler beim Laden oder Verarbeiten von listbibl.xml: {e}")

# Neue mentioned-persons.xml mit Autoren schreiben
person_list_elem = ET.Element("list")
for key in sorted(mentioned_person_keys):
    item = ET.SubElement(person_list_elem, "item")
    item.text = key

with open("./temp-indices/mentioned-persons.xml", "w", encoding="utf-8") as f:
    f.write(pretty_xml(person_list_elem))
