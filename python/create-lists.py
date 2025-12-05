from lxml import etree as ET
import requests
import os
import time

# TEI Namespace
NS = {'tei': 'http://www.tei-c.org/ns/1.0'}

# Zielverzeichnis
output_dir = "./indices"
os.makedirs(output_dir, exist_ok=True)

# Temporäres Verzeichnis für XSLT-Verarbeitung
temp_dir = "./temp-indices"
os.makedirs(temp_dir, exist_ok=True)

# Hilfsfunktion: schön formatieren
def pretty_xml(elem):
    return ET.tostring(
        elem,
        encoding='utf-8',
        pretty_print=True,
        xml_declaration=True
    ).decode('utf-8')

# Hilfsfunktion: Entität von PMB API holen
def fetch_entity_from_api(entity_id, entity_type):
    """
    Holt eine Entität von der PMB API
    entity_type: 'person', 'place', 'org', 'work', 'event'
    """
    api_urls = {
        'person': f'https://pmb.acdh.oeaw.ac.at/apis/tei/person/{entity_id}',
        'place': f'https://pmb.acdh.oeaw.ac.at/apis/tei/place/{entity_id}',
        'org': f'https://pmb.acdh.oeaw.ac.at/apis/tei/institution/{entity_id}',
        'work': f'https://pmb.acdh.oeaw.ac.at/apis/tei/work/{entity_id}',
        'event': f'https://pmb.acdh.oeaw.ac.at/apis/tei/event/{entity_id}'
    }

    if entity_type not in api_urls:
        print(f"⚠️ Unbekannter Entitätstyp: {entity_type}")
        return None

    try:
        print(f"🌐 Lade {entity_type} {entity_id} von PMB API...")
        headers = {
            "Content-type": "application/xml; charset=utf-8",
            "Accept-Charset": "utf-8",
        }
        r = requests.get(api_urls[entity_type], headers=headers)

        # XML parsen und Element extrahieren
        api_root = ET.fromstring(r.content.decode("utf-8"))

        # ID anpassen: place__298436 -> pmb298436
        old_id = api_root.get("{http://www.w3.org/XML/1998/namespace}id", "")
        if old_id.startswith(f"{entity_type}__"):
            new_id = f"pmb{entity_id}"
            api_root.set("{http://www.w3.org/XML/1998/namespace}id", new_id)

        # Kurz warten um API nicht zu überlasten
        time.sleep(0.1)

        return api_root

    except Exception as e:
        print(f"❌ Fehler beim Laden von {entity_type} {entity_id}: {e}")
        return None

# Hilfsfunktion: TEI-Template mit Liste erstellen
def create_tei_with_template(list_element, list_type):
    # TEI-Grundstruktur mit Header erstellen
    tei = ET.Element("{http://www.tei-c.org/ns/1.0}TEI")
    
    # teiHeader erstellen
    header = ET.SubElement(tei, "{http://www.tei-c.org/ns/1.0}teiHeader")
    file_desc = ET.SubElement(header, "{http://www.tei-c.org/ns/1.0}fileDesc")
    
    # titleStmt
    title_stmt = ET.SubElement(file_desc, "{http://www.tei-c.org/ns/1.0}titleStmt")
    series_title = ET.SubElement(title_stmt, "{http://www.tei-c.org/ns/1.0}title")
    series_title.set("level", "s")
    series_title.text = "Arthur Schnitzler: Briefwechsel mit Autorinnen und Autoren"
    
    main_title = ET.SubElement(title_stmt, "{http://www.tei-c.org/ns/1.0}title")
    main_title.set("level", "a")
    
    # Titel je nach Typ setzen
    if list_type == "person":
        main_title.text = "Verzeichnis der vorkommenden Personen"
    elif list_type == "bibl":
        main_title.text = "Verzeichnis der vorkommenden Werke"
    elif list_type == "org":
        main_title.text = "Verzeichnis der vorkommenden Institutionen"
    elif list_type == "place":
        main_title.text = "Verzeichnis der vorkommenden Orte"
    elif list_type == "event":
        main_title.text = "Verzeichnis der vorkommenden Ereignisse"
    
    # respStmt
    resp_stmt = ET.SubElement(title_stmt, "{http://www.tei-c.org/ns/1.0}respStmt")
    resp = ET.SubElement(resp_stmt, "{http://www.tei-c.org/ns/1.0}resp")
    resp.text = "providing the content"
    for name in ["Martin Anton Müller", "Gerd-Hermann Susen", "Laura Untner", "Selma Jahnke", "PMB (Personen der Moderne Basis)"]:
        name_elem = ET.SubElement(resp_stmt, "{http://www.tei-c.org/ns/1.0}name")
        name_elem.text = name
    
    resp_stmt2 = ET.SubElement(title_stmt, "{http://www.tei-c.org/ns/1.0}respStmt")
    resp2 = ET.SubElement(resp_stmt2, "{http://www.tei-c.org/ns/1.0}resp")
    resp2.text = "converted to XML encoding"
    name2 = ET.SubElement(resp_stmt2, "{http://www.tei-c.org/ns/1.0}name")
    name2.text = "Martin Anton Müller"
    
    # publicationStmt
    pub_stmt = ET.SubElement(file_desc, "{http://www.tei-c.org/ns/1.0}publicationStmt")
    publisher = ET.SubElement(pub_stmt, "{http://www.tei-c.org/ns/1.0}publisher")
    publisher.text = "Austrian Centre for Digital Humanities and Cultural Heritage (ACDH-CH)"
    pub_place = ET.SubElement(pub_stmt, "{http://www.tei-c.org/ns/1.0}pubPlace")
    pub_place.text = "Vienna, Austria"
    date = ET.SubElement(pub_stmt, "{http://www.tei-c.org/ns/1.0}date")
    date.text = "2025"
    
    # idno URI
    idno_uri = ET.SubElement(pub_stmt, "{http://www.tei-c.org/ns/1.0}idno")
    idno_uri.set("type", "URI")
    if list_type == "person":
        idno_uri.text = "https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listPerson"
    elif list_type == "bibl":
        idno_uri.text = "https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listBibl"
    elif list_type == "org":
        idno_uri.text = "https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listOrg"
    elif list_type == "place":
        idno_uri.text = "https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listPlace"
    elif list_type == "event":
        idno_uri.text = "https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listEvent"
    
    # idno handle
    idno_handle = ET.SubElement(pub_stmt, "{http://www.tei-c.org/ns/1.0}idno")
    idno_handle.set("type", "handle")
    if list_type == "person":
        idno_handle.text = "https://hdl.handle.net/21.11115/0000-000E-753F-9"
    elif list_type == "bibl":
        idno_handle.text = "https://hdl.handle.net/21.11115/0000-000E-7542-4"
    elif list_type == "org":
        idno_handle.text = "https://hdl.handle.net/21.11115/0000-000E-753D-B"
    elif list_type == "place":
        idno_handle.text = "https://hdl.handle.net/21.11115/0000-000E-753E-A"
    elif list_type == "event":
        idno_handle.text = "XXXX"
    
    # sourceDesc
    source_desc = ET.SubElement(file_desc, "{http://www.tei-c.org/ns/1.0}sourceDesc")
    p = ET.SubElement(source_desc, "{http://www.tei-c.org/ns/1.0}p")
    p.text = "Entitäten für die Edition der Korrespondenz Schnitzlers mit Autorinnen und Autoren, https://schnitzler-briefe.acdh.oeaw.ac.at/"
    
    # text und body
    text = ET.SubElement(tei, "{http://www.tei-c.org/ns/1.0}text")
    body = ET.SubElement(text, "{http://www.tei-c.org/ns/1.0}body")
    
    # Liste in body einfügen
    body.append(list_element)
    
    return tei

# Fallback: Einfache TEI-Struktur
def create_simple_tei(list_element, list_type):
    tei = ET.Element("{http://www.tei-c.org/ns/1.0}TEI")
    text = ET.SubElement(tei, "{http://www.tei-c.org/ns/1.0}text")
    body = ET.SubElement(text, "{http://www.tei-c.org/ns/1.0}body")
    body.append(list_element)
    return tei

# Konfiguration für jede Entität
entities = [
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listperson.xml",
        "local_list": "./temp-indices/mentioned-persons.xml",
        "list_tag": "listPerson",
        "item_tag": "person",
        "id_prefix": "person__",
        "output": "listperson.xml"
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listplace.xml",
        "local_list": "./temp-indices/mentioned-places.xml",
        "list_tag": "listPlace",
        "item_tag": "place",
        "id_prefix": "place__",
        "output": "listplace.xml"
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listorg.xml",
        "local_list": "./temp-indices/mentioned-orgs.xml",
        "list_tag": "listOrg",
        "item_tag": "org",
        "id_prefix": "org__",
        "output": "listorg.xml"
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listbibl.xml",
        "local_list": "./temp-indices/mentioned-bibl.xml",
        "list_tag": "listBibl",
        "item_tag": "bibl",
        "id_prefix": "work__",
        "output": "listbibl.xml"
    },
    {
        "url": "https://pmb.acdh.oeaw.ac.at/media/listevent.xml",
        "local_list": "./temp-indices/mentioned-event.xml",
        "list_tag": "listEvent",
        "item_tag": "event",
        "id_prefix": "event__",
        "output": "listevent.xml"
    }
]

# Hauptschleife
# Hauptschleife
for ent in entities:
    print(f"\n🔄 Verarbeite: {ent['output']}")

    # 1. XML-Datei aus dem Netz laden mit optimierten Headern
    headers = {
        "Content-type": "application/xml; charset=utf-8",
        "Accept-Charset": "utf-8",
    }
    r = requests.get(ent["url"], headers=headers)
    source_tree = ET.ElementTree(ET.fromstring(r.content.decode("utf-8")))
    source_root = source_tree.getroot()

    # 2. Erwähnte IDs laden
    mentioned_ids = set()
    mentioned_tree = ET.parse(ent["local_list"])
    for item in mentioned_tree.getroot().findall("item"):
        mentioned_ids.add("pmb" + item.text.strip())

    # 3. Entitäten filtern und fehlende von API laden
    container = source_root.find(f".//tei:{ent['list_tag']}", namespaces=NS)

    # Zuerst existierende Entitäten filtern
    existing_ids = set()
    for item in list(container.findall(f"tei:{ent['item_tag']}", namespaces=NS)):
        old_id = item.attrib.get("{http://www.w3.org/XML/1998/namespace}id", "")
        new_id = old_id.replace(ent["id_prefix"], "pmb")
        item.set("{http://www.w3.org/XML/1998/namespace}id", new_id)

        if new_id in mentioned_ids:
            existing_ids.add(new_id)
        else:
            container.remove(item)

    # Fehlende Entitäten von API laden
    missing_ids = mentioned_ids - existing_ids
    entity_type_map = {
        'listperson.xml': 'person',
        'listplace.xml': 'place',
        'listorg.xml': 'org',
        'listbibl.xml': 'work',
        'listevent.xml': 'event'
    }

    entity_type = entity_type_map.get(ent['output'])
    if entity_type and missing_ids:
        print(f"📥 {len(missing_ids)} fehlende {entity_type} Entitäten von API laden...")

        for missing_id in missing_ids:
            # pmb298436 -> 298436
            entity_id = missing_id.replace("pmb", "")

            # Von API laden
            api_entity = fetch_entity_from_api(entity_id, entity_type)
            if api_entity is not None:
                # Zur Liste hinzufügen
                container.append(api_entity)
                print(f"✅ {missing_id} hinzugefügt")
            else:
                print(f"❌ {missing_id} konnte nicht geladen werden")

    # 3b. Alle @key- und @ref-Attribute rekursiv durchgehen und ersetzen
    def update_references(element):
        for attr in ['key', 'ref']:
            if attr in element.attrib:
                for prefix in ["person__", "place__", "work__", "org__", "event__"]:
                    if element.attrib[attr].startswith(prefix):
                        element.attrib[attr] = element.attrib[attr].replace(prefix, "pmb")
        for child in element:
            update_references(child)

    update_references(source_root)

    # 4. Speichern mit XSLT-Template
    output_path = os.path.join(output_dir, ent["output"])
    print(f"Ziel: {output_path}")
    tag = ent['item_tag']
    print(f"Anzahl Elemente: {len(container.findall(f'tei:{tag}', namespaces=NS))}")

    # XSLT-Template anwenden
    # list_type basierend auf output-Datei bestimmen
    if ent['output'] == 'listperson.xml':
        list_type = 'person'
    elif ent['output'] == 'listbibl.xml':
        list_type = 'bibl'
    elif ent['output'] == 'listorg.xml':
        list_type = 'org'
    elif ent['output'] == 'listplace.xml':
        list_type = 'place'
    elif ent['output'] == 'listevent.xml':
        list_type = 'event'
    else:
        list_type = ent['item_tag']  # fallback
    
    tei_with_template = create_tei_with_template(container, list_type)
    
    xml_string = pretty_xml(tei_with_template)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(xml_string)
    print(f"✔️ Gespeichert: {ent['output']}")

print("\n🧹 Cleaning up temporary files...")
import shutil
if os.path.exists(temp_dir):
    shutil.rmtree(temp_dir)
    print(f"✔️ Temporary directory {temp_dir} removed")

