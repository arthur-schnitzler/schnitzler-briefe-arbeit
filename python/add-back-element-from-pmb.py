#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import urllib.request
import urllib.parse
import sys
from urllib.error import URLError, HTTPError

try:
    from lxml import etree
except ImportError:
    print("lxml is not installed. Please install it with: pip3 install lxml")
    sys.exit(1)

def transform_tei_document(xml_content, enrich_data=False, clean_pmb_data=False):
    """
    Transform TEI document by adding/updating back element with lists
    based on references found in the document.
    
    Args:
        xml_content: The XML content as string
        enrich_data: If True, fetch detailed data from PMB API and enrich the entries
        clean_pmb_data: If True, apply PMB data cleaning transformations
    """
    # Parse the XML content
    parser = etree.XMLParser(ns_clean=True, recover=True)
    
    # Handle both string and bytes input
    if isinstance(xml_content, str):
        # Convert string to bytes to handle encoding declaration
        xml_bytes = xml_content.encode('utf-8')
        root = etree.fromstring(xml_bytes, parser)
    else:
        root = etree.fromstring(xml_content, parser)
    
    # Define TEI namespace
    TEI_NS = "http://www.tei-c.org/ns/1.0"
    namespaces = {'tei': TEI_NS}
    
    # Check if this is a TEI document without facsimile
    if root.tag != f"{{{TEI_NS}}}TEI":
        return xml_content
    
    facsimile = root.find(f".//{{{TEI_NS}}}facsimile")
    if facsimile is not None:
        return xml_content
    
    # Create new TEI element
    new_tei = etree.Element(f"{{{TEI_NS}}}TEI", nsmap={None: TEI_NS})
    
    # Copy attributes
    for attr, value in root.attrib.items():
        new_tei.set(attr, value)
    
    # Copy teiHeader
    tei_header = root.find(f".//{{{TEI_NS}}}teiHeader")
    if tei_header is not None:
        new_tei.append(tei_header)
    
    # Check if facsimile should be added
    pb_elements = root.xpath(".//tei:pb/@facs", namespaces=namespaces)
    valid_facs = [facs for facs in pb_elements 
                  if facs and facs.strip() and '.pdf' not in facs and not facs.startswith('http')]
    
    if valid_facs:
        facsimile_elem = etree.SubElement(new_tei, f"{{{TEI_NS}}}facsimile")
        for facs_url in set(valid_facs):  # distinct values
            graphic_elem = etree.SubElement(facsimile_elem, f"{{{TEI_NS}}}graphic")
            graphic_elem.set('url', facs_url)
    
    # Process text element
    text_elem = root.find(f".//{{{TEI_NS}}}text")
    if text_elem is not None:
        new_text = create_text_with_back(text_elem, root, TEI_NS, namespaces, enrich_data)
        new_tei.append(new_text)
    
    # Apply PMB cleaning if requested
    if clean_pmb_data:
        xml_string = etree.tostring(new_tei, encoding='unicode', pretty_print=True)
        new_tei = apply_pmb_cleaning(xml_string, TEI_NS, namespaces)
    
    return etree.tostring(new_tei, encoding='unicode', pretty_print=True)

def create_text_with_back(text_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create new text element with updated back section"""
    new_text = etree.Element(f"{{{TEI_NS}}}text")
    
    # Copy attributes
    for attr, value in text_elem.attrib.items():
        new_text.set(attr, value)
    
    # Copy all children except back
    for child in text_elem:
        if child.tag != f"{{{TEI_NS}}}back":
            new_text.append(child)
    
    # Create new back element
    back_elem = etree.SubElement(new_text, f"{{{TEI_NS}}}back")
    
    # Create lists
    create_list_person(back_elem, tei_root, TEI_NS, namespaces, enrich_data)
    create_list_bibl(back_elem, tei_root, TEI_NS, namespaces, enrich_data)
    create_list_place(back_elem, tei_root, TEI_NS, namespaces, enrich_data)
    create_list_org(back_elem, tei_root, TEI_NS, namespaces, enrich_data)
    create_list_event(back_elem, tei_root, TEI_NS, namespaces, enrich_data)
    
    return new_text

def create_list_person(back_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create listPerson element"""
    list_person = etree.SubElement(back_elem, f"{{{TEI_NS}}}listPerson")
    person_ids = set()
    
    # Check if there are rs elements with # in @ref
    rs_with_hash = tei_root.xpath(".//tei:rs/@ref[contains(., '#')]", namespaces=namespaces)
    
    if rs_with_hash:
        # Case 1: rs with hash
        # Get person references from elements with @type='person', persName, or author
        person_refs = tei_root.xpath(
            ".//tei:*[(@type='person' or local-name()='persName' or local-name()='author') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in person_refs:
            if ref:
                # Split by # and get non-empty values
                ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
                person_ids.update(ids)
    else:
        # Case 2: no rs with hash - split by space
        person_refs = tei_root.xpath(
            ".//tei:*[(@type='person' or local-name()='persName' or local-name()='author')]/@ref",
            namespaces=namespaces
        )
        
        for ref in person_refs:
            if ref:
                # Split by space and get non-empty values
                ids = [id_val.strip() for id_val in ref.split() if id_val.strip()]
                person_ids.update(ids)
    
    # Add handShift/@scribe references
    handshift_refs = tei_root.xpath(".//tei:handShift/@scribe", namespaces=namespaces)
    for ref in handshift_refs:
        if ref:
            clean_ref = ref.replace('#', '').strip()
            if clean_ref:
                person_ids.add(clean_ref)
    
    # Add handNote/@corresp references (excluding 'schreibkraft')
    handnote_refs = tei_root.xpath(".//tei:handNote/@corresp", namespaces=namespaces)
    for ref in handnote_refs:
        if ref and ref != 'schreibkraft':
            clean_ref = ref.replace('#', '').strip()
            if clean_ref:
                person_ids.add(clean_ref)
    
    # Only create listPerson if there are person IDs and not enriching empty lists
    if not person_ids and not enrich_data:
        list_person.getparent().remove(list_person)
        return
    
    # Create person elements
    for person_id in sorted(person_ids):
        if enrich_data:
            create_enriched_person(list_person, person_id, TEI_NS)
        else:
            person_elem = etree.SubElement(list_person, f"{{{TEI_NS}}}person")
            person_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", person_id)

def create_list_bibl(back_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create listBibl element"""
    list_bibl = etree.SubElement(back_elem, f"{{{TEI_NS}}}listBibl")
    bibl_ids = set()
    
    # Check for rs[@type='work'] with # in @ref
    work_rs_refs = tei_root.xpath(
        ".//tei:rs[@type='work' and not(ancestor::tei:back)]/@ref[contains(., '#')]",
        namespaces=namespaces
    )
    
    for ref in work_rs_refs:
        if ref:
            ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
            bibl_ids.update(ids)
    
    # Get title/@ref from biblStruct
    title_refs = tei_root.xpath(".//tei:biblStruct//tei:title/@ref", namespaces=namespaces)
    for ref in title_refs:
        if ref:
            ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
            bibl_ids.update(ids)
    
    # Get title/@ref from teiHeader
    header_title_refs = tei_root.xpath(".//tei:teiHeader//tei:title/@ref", namespaces=namespaces)
    for ref in header_title_refs:
        if ref:
            clean_ref = ref.replace('#', '').strip()
            if clean_ref:
                bibl_ids.add(clean_ref)
    
    # Only create listBibl if there are bibl IDs and not enriching empty lists
    if not bibl_ids and not enrich_data:
        list_bibl.getparent().remove(list_bibl)
        return
    
    # Create bibl elements
    for bibl_id in sorted(bibl_ids):
        if enrich_data:
            create_enriched_bibl(list_bibl, bibl_id, TEI_NS)
        else:
            bibl_elem = etree.SubElement(list_bibl, f"{{{TEI_NS}}}bibl")
            bibl_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", bibl_id)

def create_list_place(back_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create listPlace element"""
    list_place = etree.SubElement(back_elem, f"{{{TEI_NS}}}listPlace")
    place_ids = set()
    
    # Check if there are rs elements with # in @ref
    rs_with_hash = tei_root.xpath(".//tei:rs/@ref[contains(., '#')]", namespaces=namespaces)
    
    if rs_with_hash:
        # Case 1: rs with hash
        place_refs = tei_root.xpath(
            ".//tei:*[(@type='place' or local-name()='placeName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in place_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
                place_ids.update(ids)
    else:
        # Case 2: no rs with hash - split by space
        place_refs = tei_root.xpath(
            ".//tei:*[(@type='place' or local-name()='placeName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in place_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split() if id_val.strip()]
                place_ids.update(ids)
    
    # Only create listPlace if there are place IDs and not enriching empty lists
    if not place_ids and not enrich_data:
        list_place.getparent().remove(list_place)
        return
    
    # Create place elements
    for place_id in sorted(place_ids):
        if enrich_data:
            create_enriched_place(list_place, place_id, TEI_NS)
        else:
            place_elem = etree.SubElement(list_place, f"{{{TEI_NS}}}place")
            place_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", place_id)

def create_list_org(back_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create listOrg element"""
    list_org = etree.SubElement(back_elem, f"{{{TEI_NS}}}listOrg")
    org_ids = set()
    
    # Check if there are rs elements with # in @ref
    rs_with_hash = tei_root.xpath(".//tei:rs/@ref[contains(., '#')]", namespaces=namespaces)
    
    if rs_with_hash:
        # Case 1: rs with hash
        org_refs = tei_root.xpath(
            ".//tei:*[(@type='org' or local-name()='orgName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in org_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
                org_ids.update(ids)
    else:
        # Case 2: no rs with hash - split by space
        org_refs = tei_root.xpath(
            ".//tei:*[(@type='org' or local-name()='orgName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in org_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split() if id_val.strip()]
                org_ids.update(ids)
    
    # Only create listOrg if there are org IDs and not enriching empty lists
    if not org_ids and not enrich_data:
        list_org.getparent().remove(list_org)
        return
    
    # Create org elements
    for org_id in sorted(org_ids):
        if enrich_data:
            create_enriched_org(list_org, org_id, TEI_NS)
        else:
            org_elem = etree.SubElement(list_org, f"{{{TEI_NS}}}org")
            org_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", org_id)

def create_list_event(back_elem, tei_root, TEI_NS, namespaces, enrich_data=False):
    """Create listEvent element"""
    list_event = etree.SubElement(back_elem, f"{{{TEI_NS}}}listEvent")
    event_ids = set()
    
    # Check if there are rs elements with # in @ref
    rs_with_hash = tei_root.xpath(".//tei:rs/@ref[contains(., '#')]", namespaces=namespaces)
    
    if rs_with_hash:
        # Case 1: rs with hash
        event_refs = tei_root.xpath(
            ".//tei:*[(@type='event' or local-name()='eventName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in event_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split('#') if id_val.strip()]
                event_ids.update(ids)
    else:
        # Case 2: no rs with hash - split by space
        event_refs = tei_root.xpath(
            ".//tei:*[(@type='event' or local-name()='eventName') and not(ancestor::tei:back)]/@ref",
            namespaces=namespaces
        )
        
        for ref in event_refs:
            if ref:
                ids = [id_val.strip() for id_val in ref.split() if id_val.strip()]
                event_ids.update(ids)
    
    # Only create listEvent if there are event IDs and not enriching empty lists
    if not event_ids and not enrich_data:
        list_event.getparent().remove(list_event)
        return
    
    # Create event elements
    for event_id in sorted(event_ids):
        if enrich_data:
            create_enriched_event(list_event, event_id, TEI_NS)
        else:
            event_elem = etree.SubElement(list_event, f"{{{TEI_NS}}}event")
            event_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", event_id)

# Enrichment functions for PMB data
def fetch_pmb_data(entity_type, pmb_id):
    """Fetch data from PMB API"""
    url = f"https://pmb.acdh.oeaw.ac.at/apis/tei/{entity_type}/{pmb_id}"
    try:
        with urllib.request.urlopen(url) as response:
            return response.read().decode('utf-8')
    except (URLError, HTTPError) as e:
        print(f"Error fetching {url}: {e}")
        return None

def copy_element_without_namespaces(source_elem, target_parent, TEI_NS):
    """Copy an element without namespaces"""
    new_elem = etree.SubElement(target_parent, f"{{{TEI_NS}}}{source_elem.tag}")
    
    # Copy attributes
    for attr, value in source_elem.attrib.items():
        new_elem.set(attr, value)
    
    # Copy text content
    if source_elem.text:
        new_elem.text = source_elem.text
    if source_elem.tail:
        new_elem.tail = source_elem.tail
    
    # Recursively copy children
    for child in source_elem:
        copy_element_without_namespaces(child, new_elem, TEI_NS)

def create_enriched_person(list_person, person_id, TEI_NS):
    """Create enriched person element with PMB data"""
    clean_id = person_id.replace('#', '').replace('pmb', '')
    
    # Special case for Arthur Schnitzler
    if clean_id in ['2121', 'pmb2121']:
        person_elem = etree.SubElement(list_person, f"{{{TEI_NS}}}person")
        person_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", 'pmb2121')
        
        # Add Schnitzler data
        persname = etree.SubElement(person_elem, f"{{{TEI_NS}}}persName")
        surname = etree.SubElement(persname, f"{{{TEI_NS}}}surname")
        surname.text = "Schnitzler"
        forename = etree.SubElement(persname, f"{{{TEI_NS}}}forename")
        forename.text = "Arthur"
        
        birth = etree.SubElement(person_elem, f"{{{TEI_NS}}}birth")
        birth_date = etree.SubElement(birth, f"{{{TEI_NS}}}date")
        birth_date.set("when", "1862-05-15")
        birth_date.text = "15. 5. 1862"
        settlement = etree.SubElement(birth, f"{{{TEI_NS}}}settlement")
        settlement.set("key", "pmb50")
        placename = etree.SubElement(settlement, f"{{{TEI_NS}}}placeName")
        placename.set("type", "pref")
        placename.text = "Wien"
        location = etree.SubElement(settlement, f"{{{TEI_NS}}}location")
        geo = etree.SubElement(location, f"{{{TEI_NS}}}geo")
        geo.text = "48,208333 16,373056"
        
        death = etree.SubElement(person_elem, f"{{{TEI_NS}}}death")
        death_date = etree.SubElement(death, f"{{{TEI_NS}}}date")
        death_date.set("when", "1931-10-21")
        death_date.text = "21. 10. 1931"
        settlement2 = etree.SubElement(death, f"{{{TEI_NS}}}settlement")
        settlement2.set("key", "pmb50")
        placename2 = etree.SubElement(settlement2, f"{{{TEI_NS}}}placeName")
        placename2.set("type", "pref")
        placename2.text = "Wien"
        location2 = etree.SubElement(settlement2, f"{{{TEI_NS}}}location")
        geo2 = etree.SubElement(location2, f"{{{TEI_NS}}}geo")
        geo2.text = "48,208333 16,373056"
        
        sex = etree.SubElement(person_elem, f"{{{TEI_NS}}}sex")
        sex.set("value", "male")
        
        occupation1 = etree.SubElement(person_elem, f"{{{TEI_NS}}}occupation")
        occupation1.set("ref", "pmb90")
        occupation1.text = "Schriftsteller*in"
        
        occupation2 = etree.SubElement(person_elem, f"{{{TEI_NS}}}occupation")
        occupation2.set("ref", "pmb97")
        occupation2.text = "Mediziner*in"
        
        idno = etree.SubElement(person_elem, f"{{{TEI_NS}}}idno")
        idno.set("type", "gnd")
        idno.text = "https://d-nb.info/gnd/118609807/"
        
        return
    
    # For other persons, try to fetch from PMB
    if clean_id.isdigit():
        pmb_data = fetch_pmb_data('person', clean_id)
        if pmb_data:
            try:
                pmb_root = etree.fromstring(pmb_data)
                person_elem = etree.SubElement(list_person, f"{{{TEI_NS}}}person")
                person_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", f'pmb{clean_id}')
                
                # Copy specific elements without @type='loschen'
                for elem in pmb_root.xpath(".//persName[not(@type='loschen')] | .//birth | .//death | .//sex | .//occupation | .//idno"):
                    copy_element_without_namespaces(elem, person_elem, TEI_NS)
                
                return
            except etree.XMLSyntaxError:
                pass
    
    # Fallback: create error element
    error_elem = etree.SubElement(list_person, f"{{{TEI_NS}}}error")
    error_elem.set("type", "person")
    error_elem.text = clean_id

def create_enriched_bibl(list_bibl, bibl_id, TEI_NS):
    """Create enriched bibl element with PMB data"""
    clean_id = bibl_id.replace('#', '').replace('pmb', '')
    
    if clean_id.isdigit():
        pmb_data = fetch_pmb_data('work', clean_id)
        if pmb_data:
            try:
                pmb_root = etree.fromstring(pmb_data)
                bibl_elem = etree.SubElement(list_bibl, f"{{{TEI_NS}}}bibl")
                bibl_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", f'pmb{clean_id}')
                
                # Copy specific elements without @type='loschen'
                for elem in pmb_root.xpath(".//title[not(@type='loschen')] | .//author | .//date | .//note[@type] | .//idno"):
                    copy_element_without_namespaces(elem, bibl_elem, TEI_NS)
                
                return
            except etree.XMLSyntaxError:
                pass
    
    # Fallback: create error element
    error_elem = etree.SubElement(list_bibl, f"{{{TEI_NS}}}error")
    error_elem.set("type", "bibl")
    error_elem.text = clean_id

def create_enriched_place(list_place, place_id, TEI_NS):
    """Create enriched place element with PMB data"""
    clean_id = place_id.replace('#', '').replace('pmb', '')
    
    # Special case for Wien (pmb50)
    if clean_id == '50':
        place_elem = etree.SubElement(list_place, f"{{{TEI_NS}}}place")
        place_elem.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", 'pmb50')
        
        # Add Wien data (abbreviated version)
        placename = etree.SubElement(place_elem, f"{{{TEI_NS}}}placeName")
        placename.text = "Wien"
        
        placename_alt = etree.SubElement(place_elem, f"{{{TEI_NS}}}placeName")
        placename_alt.set("type", "ort_fruherer-name")
        placename_alt.text = "K.K. Reichshaupt- und Residenzstadt Wien"
        
        desc = etree.SubElement(place_elem, f"{{{TEI_NS}}}desc")
        desc.set("type", "entity_type")
        desc.text = "A.ADM2"
        
        location = etree.SubElement(place_elem, f"{{{TEI_NS}}}location")
        location.set("type", "coords")
        geo = etree.SubElement(location, f"{{{TEI_NS}}}geo")
        geo.text = "48,208333 16,373056"
        
        idno = etree.SubElement(place_elem, f"{{{TEI_NS}}}idno")
        idno.set("type", "URL")
        idno.set("subtype", "geonames")
        idno.text = "https://sws.geonames.org/2761369/"
        
        return
    
    # For other places, try to fetch from PMB
    if clean_id.isdigit():
        pmb_data = fetch_pmb_data('place', clean_id)
        if pmb_data:
            try:
                pmb_root = etree.fromstring(pmb_data)
                # Copy the entire place element
                copy_element_without_namespaces(pmb_root, list_place, TEI_NS)
                return
            except etree.XMLSyntaxError:
                pass
    
    # Fallback: create error element
    error_elem = etree.SubElement(list_place, f"{{{TEI_NS}}}error")
    error_elem.set("type", "place")
    error_elem.text = clean_id

def create_enriched_org(list_org, org_id, TEI_NS):
    """Create enriched org element with PMB data"""
    clean_id = org_id.replace('#', '').replace('pmb', '')
    
    if clean_id.isdigit():
        pmb_data = fetch_pmb_data('org', clean_id)
        if pmb_data:
            try:
                pmb_root = etree.fromstring(pmb_data)
                # Copy the entire org element
                copy_element_without_namespaces(pmb_root, list_org, TEI_NS)
                return
            except etree.XMLSyntaxError:
                pass
    
    # Fallback: create error element
    error_elem = etree.SubElement(list_org, f"{{{TEI_NS}}}error")
    error_elem.set("type", "org")
    error_elem.text = clean_id

def create_enriched_event(list_event, event_id, TEI_NS):
    """Create enriched event element with PMB data"""
    clean_id = event_id.replace('#', '').replace('pmb', '')
    
    if clean_id.isdigit():
        pmb_data = fetch_pmb_data('event', clean_id)
        if pmb_data:
            try:
                pmb_root = etree.fromstring(pmb_data)
                # Copy the entire event element
                copy_element_without_namespaces(pmb_root, list_event, TEI_NS)
                return
            except etree.XMLSyntaxError:
                pass
    
    # Fallback: create error element
    error_elem = etree.SubElement(list_event, f"{{{TEI_NS}}}error")
    error_elem.set("type", "event")
    error_elem.text = clean_id

# PMB Data Cleaning Functions (Third XSLT)
def apply_pmb_cleaning(xml_content, TEI_NS, namespaces):
    """Apply PMB data cleaning transformations"""
    root = etree.fromstring(xml_content)
    
    # Apply all cleaning transformations
    clean_iso_dates(root, namespaces)
    clean_date_elements(root, namespaces)
    clean_key_attributes(root, namespaces)
    clean_place_refs(root, namespaces)
    clean_bibl_elements(root, namespaces)
    clean_person_ids(root, namespaces)
    clean_place_ids(root, namespaces)
    clean_org_ids(root, namespaces)
    clean_event_ids(root, namespaces)
    clean_idno_elements(root, namespaces)
    clean_title_elements(root, namespaces)
    remove_duplicate_placenames(root, namespaces)
    remove_empty_lists(root, namespaces)
    
    return root

def clean_iso_dates(root, namespaces):
    """Convert ISO date attributes to standard format"""
    date_attrs = ['when-iso', 'notAfter-iso', 'notBefore-iso', 'from-iso', 'to-iso']
    
    for attr_name in date_attrs:
        xpath_expr = f".//@{attr_name}"
        attrs = root.xpath(xpath_expr)
        
        for attr in attrs:
            element = attr.getparent()
            date_value = attr
            
            # Process date formatting
            if '-' in date_value:
                year_part = date_value.split('-')[0]
                if len(year_part) < 4:
                    # Pad with zeros
                    padding = '0' * (4 - len(year_part))
                    new_value = padding + date_value
                else:
                    new_value = date_value
            else:
                new_value = date_value
            
            # Set the new attribute name (remove -iso suffix)
            new_attr_name = attr_name.replace('-iso', '')
            element.set(new_attr_name, new_value)
            
            # Remove old attribute
            del element.attrib[attr_name]

def clean_date_elements(root, namespaces):
    """Clean date elements containing encoded characters"""
    date_elements = root.xpath(".//tei:date[contains(text(), '&lt;')]", namespaces=namespaces)
    
    for date_elem in date_elements:
        if date_elem.text and '&lt;' in date_elem.text:
            # Remove everything after &lt;
            cleaned_text = date_elem.text.split('&lt;')[0]
            date_elem.text = cleaned_text

def clean_key_attributes(root, namespaces):
    """Convert @key attributes to @ref with pmb prefix"""
    key_attrs = root.xpath(".//@key")
    
    for attr in key_attrs:
        element = attr.getparent()
        key_value = attr
        
        if 'pmb' not in key_value:
            new_value = f'pmb{key_value}'
        else:
            new_value = key_value
        
        element.set('ref', new_value)
        del element.attrib['key']

def clean_place_refs(root, namespaces):
    """Clean placeName @ref attributes containing place__"""
    place_refs = root.xpath(".//tei:placeName/@ref[contains(., 'place__')] | .//tei:placeName/@key[contains(., 'place__')]", namespaces=namespaces)
    
    for attr in place_refs:
        element = attr.getparent()
        ref_value = attr
        
        if 'place__' in ref_value:
            new_value = f"pmb{ref_value.replace('place__', '')}"
            element.set('ref', new_value)

def clean_bibl_elements(root, namespaces):
    """Clean bibliography related elements"""
    # Remove collections
    collections = root.xpath(".//tei:back//tei:listBibl[tei:bibl/@type='collections']", namespaces=namespaces)
    for elem in collections:
        elem.getparent().remove(elem)
    
    collection_notes = root.xpath(".//tei:back//tei:bibl/tei:note[@type='collections']", namespaces=namespaces)
    for elem in collection_notes:
        elem.getparent().remove(elem)
    
    # Remove @type='main' from titles in back
    main_titles = root.xpath(".//tei:back//tei:title/@type[.='main']", namespaces=namespaces)
    for attr in main_titles:
        del attr.getparent().attrib['type']
    
    # Clean author refs
    author_refs = root.xpath(".//tei:back//tei:bibl/tei:author/@ref[starts-with(., 'pmbperson__') or starts-with(., 'person__')] | .//tei:back//tei:bibl/tei:author/@key[starts-with(., 'pmbperson__') or starts-with(., 'person__')]", namespaces=namespaces)
    for attr in author_refs:
        element = attr.getparent()
        ref_value = attr
        
        if 'person__' in ref_value:
            new_value = f"pmb{ref_value.split('person__')[1]}"
            element.set('ref', new_value)

def clean_person_ids(root, namespaces):
    """Clean person xml:id attributes"""
    person_ids = root.xpath(".//tei:back//tei:listPerson/tei:person/@xml:id[contains(., 'person__')]", namespaces=namespaces)
    
    for attr in person_ids:
        element = attr.getparent()
        id_value = attr
        
        if 'person__' in id_value:
            new_value = f"pmb{id_value.split('person__')[1]}"
            element.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", new_value)

def clean_place_ids(root, namespaces):
    """Clean place xml:id attributes"""
    place_ids = root.xpath(".//tei:back//tei:listPlace/tei:place/@xml:id[contains(., 'place__')]", namespaces=namespaces)
    
    for attr in place_ids:
        element = attr.getparent()
        id_value = attr
        
        if 'place__' in id_value:
            new_value = f"pmb{id_value.split('place__')[1]}"
            element.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", new_value)

def clean_org_ids(root, namespaces):
    """Clean org xml:id attributes"""
    org_ids = root.xpath(".//tei:back//tei:listOrg/tei:org/@xml:id[contains(., 'org__')]", namespaces=namespaces)
    
    for attr in org_ids:
        element = attr.getparent()
        id_value = attr
        
        if 'org__' in id_value:
            new_value = f"pmb{id_value.split('org__')[1]}"
            element.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", new_value)

def clean_event_ids(root, namespaces):
    """Clean event xml:id attributes"""
    event_ids = root.xpath(".//tei:back//tei:listEvent/tei:event/@xml:id[contains(., 'event__')]", namespaces=namespaces)
    
    for attr in event_ids:
        element = attr.getparent()
        id_value = attr
        
        if 'event__' in id_value:
            new_value = f"pmb{id_value.split('event__')[1]}"
            element.set(f"{{{etree.QName('http://www.w3.org/XML/1998/namespace', 'id').text}}}", new_value)

def extract_subtype_from_url(url):
    """Extract subtype from URL"""
    if 'wikipedia' in url:
        return 'wikipedia'
    elif 'wikidata' in url:
        return 'wikidata'
    elif 'geonames' in url:
        return 'geonames'
    elif url.startswith('https://www.'):
        return url.split('https://www.')[1].split('.')[0]
    elif url.startswith('http://www.'):
        return url.split('http://www.')[1].split('.')[0]
    elif url.startswith('https://'):
        return url.split('https://')[1].split('.')[0]
    elif url.startswith('http://'):
        return url.split('http://')[1].split('.')[0]
    else:
        return url.split('.')[0] if '.' in url else 'unknown'

def clean_idno_elements(root, namespaces):
    """Clean and convert various elements to idno"""
    TEI_NS = "http://www.tei-c.org/ns/1.0"
    
    # Convert note[@type='IDNO'] to idno
    idno_notes = root.xpath(".//tei:back//tei:note[@type='IDNO']", namespaces=namespaces)
    for note in idno_notes:
        parent = note.getparent()
        new_idno = etree.Element(f"{{{TEI_NS}}}idno")
        new_idno.set('type', 'URL')
        new_idno.set('subtype', extract_subtype_from_url(note.text or ''))
        new_idno.text = note.text
        
        parent.replace(note, new_idno)
    
    # Convert orgName with uri type to idno
    org_uris = root.xpath(".//tei:back//tei:orgName[contains(@type, 'uri')]", namespaces=namespaces)
    for orgname in org_uris:
        parent = orgname.getparent()
        new_idno = etree.Element(f"{{{TEI_NS}}}idno")
        new_idno.set('type', 'URL')
        new_idno.set('subtype', extract_subtype_from_url(orgname.text or ''))
        new_idno.text = orgname.text
        
        parent.replace(orgname, new_idno)
    
    # Add subtype to existing URL idnos
    url_idnos = root.xpath(".//tei:back//tei:idno[@type='URL' and not(@subtype)]", namespaces=namespaces)
    for idno in url_idnos:
        if idno.text:
            subtype = extract_subtype_from_url(idno.text)
            idno.set('subtype', subtype)

def clean_title_elements(root, namespaces):
    """Clean and convert title elements"""
    TEI_NS = "http://www.tei-c.org/ns/1.0"
    
    # Convert title[@type='bibliografische_angabe'] to note
    biblio_titles = root.xpath(".//tei:title[@type='bibliografische_angabe']", namespaces=namespaces)
    for title in biblio_titles:
        parent = title.getparent()
        new_note = etree.Element(f"{{{TEI_NS}}}note")
        new_note.set('type', 'bibliografische_angabe')
        new_note.text = title.text
        
        parent.replace(title, new_note)
    
    # Convert title[@type='uri_worklink'] to note
    worklink_titles = root.xpath(".//tei:title[@type='uri_worklink']", namespaces=namespaces)
    for title in worklink_titles:
        parent = title.getparent()
        new_note = etree.Element(f"{{{TEI_NS}}}note")
        new_note.set('type', 'uri_worklink')
        new_note.text = title.text
        
        parent.replace(title, new_note)
    
    # Convert title with wikipedia type to idno
    wiki_titles = root.xpath(".//tei:title[contains(@type, 'wikipedia')]", namespaces=namespaces)
    for title in wiki_titles:
        parent = title.getparent()
        new_idno = etree.Element(f"{{{TEI_NS}}}idno")
        new_idno.set('type', 'URL')
        new_idno.set('subtype', extract_subtype_from_url(title.text or ''))
        new_idno.text = title.text
        
        parent.replace(title, new_idno)

def remove_duplicate_placenames(root, namespaces):
    """Remove duplicate placeName elements"""
    placenames = root.xpath(".//tei:back//tei:placeName", namespaces=namespaces)
    
    seen_texts = set()
    to_remove = []
    
    for placename in placenames:
        if placename.text in seen_texts:
            to_remove.append(placename)
        else:
            seen_texts.add(placename.text)
    
    for elem in to_remove:
        if elem.getparent() is not None:
            elem.getparent().remove(elem)

def remove_empty_lists(root, namespaces):
    """Remove empty list elements"""
    empty_lists = root.xpath(".//tei:listOrg[not(child::*)] | .//tei:listBibl[not(child::*)] | .//tei:listPerson[not(child::*)] | .//tei:listPlace[not(child::*)] | .//tei:listEvent[not(child::*)]", namespaces=namespaces)
    
    for empty_list in empty_lists:
        if empty_list.getparent() is not None:
            empty_list.getparent().remove(empty_list)

# Example usage
if __name__ == "__main__":
    # Example TEI XML content with PMB data that needs cleaning
    sample_xml = """<TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <title ref="#work1">Sample Title</title>
        </teiHeader>
        <text>
            <body>
                <p>
                    <persName ref="pmb2121">Arthur Schnitzler</persName> wrote about 
                    <placeName key="50">Vienna</placeName> and 
                    <rs type="work" ref="#work2">Some Work</rs>.
                </p>
            </body>
            <back>
                <listPerson>
                    <person xml:id="person__2121">
                        <persName>Arthur Schnitzler</persName>
                        <birth>
                            <date when-iso="1862-05-15">15. 5. 1862</date>
                        </birth>
                        <note type="IDNO">https://d-nb.info/gnd/118609807/</note>
                    </person>
                </listPerson>
                <listPlace>
                    <place xml:id="place__50">
                        <placeName>Wien</placeName>
                        <placeName>Wien</placeName>
                    </place>
                </listPlace>
                <listBibl/>
            </back>
        </text>
    </TEI>"""
    
    print("=== Basic Transformation ===")
    result_basic = transform_tei_document(sample_xml, enrich_data=False, clean_pmb_data=False)
    print(result_basic)
    
    print("\n=== With PMB Cleaning ===")
    result_cleaned = transform_tei_document(sample_xml, enrich_data=False, clean_pmb_data=True)
    print(result_cleaned)
    
    print("\n=== Enriched + Cleaned ===")
    result_full = transform_tei_document(sample_xml, enrich_data=True, clean_pmb_data=True)
    print(result_full)