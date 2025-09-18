import os
import re
import glob
import requests
from lxml import etree
from datetime import date

NAMESPACES = {
    'tei': 'http://www.tei-c.org/ns/1.0'
}

LISTCORR_URL = 'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-arbeit/refs/heads/main/indices/listcorrespondence.xml'
EDITION_PATH = './editions/'
OUTDIR = './tocs/'

def name_ohne_komma(name):
    """Entfernt Komma aus Namen im Format 'Nachname, Vorname'."""
    parts = name.split(', ')
    return f"{parts[1]} {parts[0]}" if len(parts) == 2 else name

def get_listcorrespondence():
    response = requests.get(LISTCORR_URL)
    response.raise_for_status()
    return etree.fromstring(response.content)

def get_matching_files(corresp_id):
    files = glob.glob(os.path.join(EDITION_PATH, '**', 'L0*.xml'), recursive=True)
    result = []
    for file in files:
        try:
            doc = etree.parse(file)
            refs = doc.xpath('//tei:correspContext/tei:ref[@type="belongsToCorrespondence"]', namespaces=NAMESPACES)
            if any(ref.attrib.get('target') == corresp_id for ref in refs):
                result.append(doc)
        except Exception:
            continue
    return result

def get_ana_attribute(doc, person_pmb_id):
    """Bestimmt das ana-Attribut basierend auf der Rolle von #pmb2121 und dem aktuellen Korrespondenzpartner."""
    
    # Prüfe ob #pmb2121 der Sender ist
    sent_pmb2121 = doc.xpath("//tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type='sent'][1]/tei:persName[@ref='#pmb2121']", namespaces=NAMESPACES)
    
    if sent_pmb2121:
        # #pmb2121 ist Sender - prüfe ob der Empfänger der aktuelle Korrespondenzpartner ist
        received_current = doc.xpath(f"//tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type='received'][1]/tei:persName[@ref='{person_pmb_id}']", namespaces=NAMESPACES)
        return "as-sender" if received_current else "umfeld"
    
    # Prüfe ob #pmb2121 der Empfänger ist
    received_pmb2121 = doc.xpath("//tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type='received'][1]/tei:persName[@ref='#pmb2121']", namespaces=NAMESPACES)
    
    if received_pmb2121:
        # #pmb2121 ist Empfänger - prüfe ob der Sender der aktuelle Korrespondenzpartner ist
        sent_current = doc.xpath(f"//tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type='sent'][1]/tei:persName[@ref='{person_pmb_id}']", namespaces=NAMESPACES)
        return "as-empf" if sent_current else "umfeld"
    
    # Fallback - #pmb2121 weder als Sender noch als Empfänger gefunden
    return "umfeld"

def generate_toc(corresp_id, person_name, matching_docs, person_pmb_id, person_grp_ana=None):
    toc_root = etree.Element('{http://www.tei-c.org/ns/1.0}TEI', nsmap={
        None: "http://www.tei-c.org/ns/1.0",
        "xsi": "http://www.w3.org/2001/XMLSchema-instance"
    })
    toc_root.set("{http://www.w3.org/2001/XMLSchema-instance}schemaLocation",
                 "http://www.tei-c.org/ns/1.0 http://diglib.hab.de/rules/schema/tei/P5/v2.3.0/tei-p5-transcr.xsd")
    toc_root.set("{http://www.w3.org/XML/1998/namespace}id", f"korrespondenz_{corresp_id}")

    header = etree.SubElement(toc_root, "teiHeader")
    fileDesc = etree.SubElement(header, "fileDesc")

    titleStmt = etree.SubElement(fileDesc, "titleStmt")
    etree.SubElement(titleStmt, "title", level="s").text = "Arthur Schnitzler: Briefwechsel mit Autorinnen und Autoren"
    title2 = etree.SubElement(titleStmt, "title", level="a")
    title2.text = f"Korrespondenz Arthur Schnitzler – {person_name}"

    # Zusätzliche Texte basierend auf personGrp @ana-Attribut
    if person_grp_ana == "edition-in-progress":
        title2.text += " (Objekte noch nicht vollständig ediert)"
    elif person_grp_ana == "corrections-in-progress":
        title2.text += " (noch nicht abschließend korrigiert)"

    respStmt1 = etree.SubElement(titleStmt, "respStmt")
    etree.SubElement(respStmt1, "resp").text = "providing the content"
    for name in ["Martin Anton Müller", "Gerd-Hermann Susen", "Laura Untner", "Selma Jahnke"]:
        etree.SubElement(respStmt1, "name").text = name

    respStmt2 = etree.SubElement(titleStmt, "respStmt")
    etree.SubElement(respStmt2, "resp").text = "converted to XML encoding"
    etree.SubElement(respStmt2, "name").text = "Martin Anton Müller"

    pubStmt = etree.SubElement(fileDesc, "publicationStmt")
    etree.SubElement(pubStmt, "publisher").text = "Austrian Centre for Digital Humanities and Cultural Heritage (ACDH-CH)"
    etree.SubElement(pubStmt, "date").text = date.today().isoformat()
    idno = etree.SubElement(pubStmt, "idno", type="URI")
    idno.text = f"https://id.acdh.oeaw.ac.at/schnitzler-briefe/tocs/toc_{corresp_id}.xml"

    sourceDesc = etree.SubElement(fileDesc, "sourceDesc")
    etree.SubElement(sourceDesc, "p").text = "Inhaltsverzeichnis einzelner Korrespondenzen von schnitzler-briefe"

    text = etree.SubElement(toc_root, "text")
    body = etree.SubElement(text, "body")

    # Zusätzliche Paragraphen basierend auf personGrp @ana-Attribut
    if person_grp_ana == "edition-in-progress":
        p_elem = etree.SubElement(body, "p")
        p_elem.text = "Vorsicht! Die Korrespondenzstücke dieses Briefwechsels sind noch nicht alle verzeichnet. Wir arbeiten daran."
    elif person_grp_ana == "corrections-in-progress":
        p_elem = etree.SubElement(body, "p")
        p_elem.text = "Wir haben alle Korrespondenzstücke dieses Briefwechsels aufgenommen, sitzen aber noch an den Korrekturen."

    list_elem = etree.SubElement(body, "list")

    for doc in sorted(matching_docs, key=lambda d: (
            d.xpath("string(//tei:correspAction[@type='sent']/tei:date/@when)", namespaces=NAMESPACES) or "")):
        item = etree.SubElement(list_elem, "item")
        xml_id = doc.getroot().get("{http://www.w3.org/XML/1998/namespace}id")
        if xml_id is not None:
            item.set("corresp", xml_id)
        else:
            # Falls kein xml:id vorhanden, ggf. Platzhalter oder überspringen
            item.set("corresp", "unknown")
        
        item.set("ana", get_ana_attribute(doc, person_pmb_id))

        title = doc.xpath("//tei:titleStmt/tei:title[@level='a'][1]", namespaces=NAMESPACES)
        date_el = doc.xpath("//tei:correspAction[@type='sent']/tei:date[1]", namespaces=NAMESPACES)

        if title:
            item.append(title[0])
        if date_el:
            item.append(date_el[0])


    return etree.ElementTree(toc_root)

def main():
    os.makedirs(OUTDIR, exist_ok=True)
    listcorresp_doc = get_listcorrespondence()

    for personGrp in listcorresp_doc.xpath('//tei:listPerson/tei:personGrp[not(@xml:id="correspondence_null")]', namespaces=NAMESPACES):
        person_grp_id = personGrp.attrib['{http://www.w3.org/XML/1998/namespace}id']
        corresp_id = person_grp_id.replace('correspondence_', '')
        person_name_el = personGrp.xpath("tei:persName[@role='main'][1]/text()", namespaces=NAMESPACES)
        person_name = name_ohne_komma(person_name_el[0]) if person_name_el else 'Unbekannt'
        
        # Die PMB-ID der Person aus der personGrp extrahieren
        person_pmb_id = personGrp.xpath("tei:persName[@role='main'][1]/@ref", namespaces=NAMESPACES)
        person_pmb_id = person_pmb_id[0] if person_pmb_id else None

        # Das @ana-Attribut der personGrp extrahieren
        person_grp_ana = personGrp.get('ana')

        matching_docs = get_matching_files(person_grp_id)

        toc_tree = generate_toc(corresp_id, person_name, matching_docs, person_pmb_id, person_grp_ana)
        toc_tree.write(os.path.join(OUTDIR, f"toc_{corresp_id}.xml"), pretty_print=True, encoding='utf-8', xml_declaration=True)

if __name__ == "__main__":
    main()
