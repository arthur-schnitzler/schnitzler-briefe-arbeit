import os
import copy
import requests
from lxml import etree

NS = {'tei': 'http://www.tei-c.org/ns/1.0'}

def get_cmif_context_map():
    print("Lade schnitzler-briefe-cmif.xml ...")
    url = 'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-arbeit/refs/heads/main/indices/schnitzler-briefe-cmif.xml'
    response = requests.get(url)
    response.raise_for_status()
    cmif_root = etree.fromstring(response.content)

    context_map = {}

    for cdesc in cmif_root.xpath('//tei:correspDesc', namespaces=NS):
        key = cdesc.get('key')
        context = cdesc.find('tei:correspContext', namespaces=NS)
        if key and context is not None:
            children = [
                copy.deepcopy(child)
                for child in context
                if etree.QName(child).localname != 'ab'
            ]
            context_map[key] = children

    print(f"{len(context_map)} Kontext-Einträge gefunden.")
    return context_map

# Zielverzeichnis
input_dir = './editions/'

# Kontextdaten laden
context_map = get_cmif_context_map()

# Alle Dateien bearbeiten
for filename in os.listdir(input_dir):
    if not filename.endswith('.xml'):
        continue

    filepath = os.path.join(input_dir, filename)
    print(f"Verarbeite: {filename}")

    try:
        tree = etree.parse(filepath)
        root = tree.getroot()

        # XML-ID vom <TEI> holen
        tei_elem = root.xpath('//tei:TEI', namespaces=NS)
        if not tei_elem:
            print(" - Kein <TEI>-Element gefunden.")
            continue

        tei = tei_elem[0]
        xml_id = tei.get('{http://www.w3.org/XML/1998/namespace}id')

        if not xml_id:
            print(" - Kein xml:id im <TEI> gefunden.")
            continue

        if xml_id not in context_map:
            print(f" - Kein Eintrag im CMIF für ID '{xml_id}'")
            continue

        # correspDesc suchen
        corresp_desc = tei.xpath('.//tei:correspDesc', namespaces=NS)
        if not corresp_desc:
            print(" - Kein <correspDesc> gefunden.")
            continue

        cd = corresp_desc[0]

        # Vorhandenes correspContext entfernen
        for cc in cd.xpath('tei:correspContext', namespaces=NS):
            cd.remove(cc)

        # Neues correspContext anhängen
        new_cc = etree.Element('{http://www.tei-c.org/ns/1.0}correspContext')
        for child in context_map[xml_id]:
            new_cc.append(copy.deepcopy(child))

        cd.append(new_cc)

        # Datei überschreiben
        tree.write(filepath, pretty_print=True, xml_declaration=True, encoding='UTF-8')

        print(" - correspContext eingefügt.")
    except Exception as e:
        print(f"Fehler in {filename}: {e}")

print("✅ Fertig.")
