#!/usr/bin/env python3
"""
TEI XML Back Element Generator and PMB Enricher

Kombiniert zwei XSLT-Funktionen in Python:
1. Generiert back-Element mit Listen basierend auf Referenzen im Dokument
2. Reichert die Listen mit Daten aus der PMB-API an
"""

import xml.etree.ElementTree as ET
from typing import Set, List, Optional, Dict
import re
import argparse
import sys
import requests
from pathlib import Path
import urllib.request
import urllib.parse
import time


class TEIBackGenerator:
    def __init__(self):
        self.tei_ns = "http://www.tei-c.org/ns/1.0"
        # Namespace-Map für XPath-Suchen
        self.ns_map = {'tei': self.tei_ns}
        # Registriere Namespace für ElementTree
        ET.register_namespace('', self.tei_ns)
        
        # Cache für PMB-Listen
        self.pmb_lists = {}
        self.pmb_lookups = {}
        
        # Cache-Dateien für persistente Speicherung
        self.cache_dir = Path.home() / '.cache' / 'pmb-lists'
        self.cache_max_age = 24 * 60 * 60  # 24 Stunden in Sekunden
        
        # Cache-Dateien für jede Entity-Type
        self.cache_files = {
            'person': self.cache_dir / 'listperson.xml',
            'work': self.cache_dir / 'listbibl.xml', 
            'place': self.cache_dir / 'listplace.xml',
            'org': self.cache_dir / 'listorg.xml',
            'event': self.cache_dir / 'listevent.xml'
        }
        
        # Kompakte JSON-Index-Dateien für schnellere Performance
        self.index_files = {
            'person': self.cache_dir / 'person_index.json',
            'work': self.cache_dir / 'work_index.json',
            'place': self.cache_dir / 'place_index.json', 
            'org': self.cache_dir / 'org_index.json',
            'event': self.cache_dir / 'event_index.json'
        }
        
        # Wien-Eintrag für spezielle Behandlung
        self.wien_entry = {
            'pmb50': {
                'placeName': 'Wien',
                'additional_names': [
                    ('ort_fruherer-name', 'K.K. Reichshaupt- und Residenzstadt Wien'),
                    ('alternative-name', 'Bécs'),
                    ('alternative-name', 'Land Wien'),
                    ('alternative-name', 'Vídeň'),
                    ('alternative-name', 'Wenia'),
                    ('alternative-name', 'Beč'),
                    ('ort_fruherer-name', 'Vindobona'),
                    ('alternative-name', 'Vienna')
                ],
                'coords': '48,208333 16,373056'
            }
        }
    
    def extract_refs_from_attribute(self, ref_attr: str, has_hash: bool) -> Set[str]:
        """
        Extrahiert Referenzen aus einem @ref Attribut.
        
        Args:
            ref_attr: Der Wert des @ref Attributs
            has_hash: True wenn Referenzen mit # getrennt sind, False wenn mit Leerzeichen
        
        Returns:
            Set von bereinigten Referenz-IDs
        """
        if not ref_attr or not ref_attr.strip():
            return set()
        
        # Tokenize basierend auf Trennzeichen
        if has_hash:
            tokens = ref_attr.split('#')
        else:
            tokens = ref_attr.split()
        
        # Bereinigte IDs zurückgeben (ohne # und Leerzeichen)
        refs = set()
        for token in tokens:
            cleaned = token.replace('#', '').strip()
            if cleaned:
                refs.add(cleaned)
        
        return refs
    
    def _load_cache(self) -> bool:
        """Lädt PMB-Listen aus dem XML-Cache falls vorhanden und aktuell."""
        try:
            # Prüfe ob alle Cache-Dateien existieren
            if not all(cache_file.exists() for cache_file in self.cache_files.values()):
                return False
            
            # Prüfe Alter der Cache-Dateien (verwende älteste Datei)
            oldest_time = min(cache_file.stat().st_mtime for cache_file in self.cache_files.values())
            cache_age = time.time() - oldest_time
            if cache_age > self.cache_max_age:
                print("PMB-Cache ist veraltet, wird neu geladen...")
                return False
            
            print("Lade PMB-Listen aus XML-Cache...")
            total_entries = 0
            
            for entity_type, cache_file in self.cache_files.items():
                try:
                    # Parse cached XML file
                    tree = ET.parse(cache_file)
                    root = tree.getroot()
                    self.pmb_lists[entity_type] = root
                    
                    # Create lookup dictionary
                    self.pmb_lookups[entity_type] = {}
                    
                    # Bestimme Liste und Element Tags basierend auf Entity-Type
                    if entity_type == 'person':
                        list_tag = 'listPerson'
                        item_tag = 'person'
                    elif entity_type == 'work':
                        list_tag = 'listBibl'
                        item_tag = 'bibl'
                    elif entity_type == 'place':
                        list_tag = 'listPlace'
                        item_tag = 'place'
                    elif entity_type == 'org':
                        list_tag = 'listOrg'
                        item_tag = 'org'
                    elif entity_type == 'event':
                        list_tag = 'listEvent'
                        item_tag = 'event'
                    
                    # Finde die Liste im Root-Element
                    list_elem = root.find(f".//tei:{list_tag}", self.ns_map)
                    if list_elem is not None:
                        # Durchlaufe alle Items in der Liste
                        for item in list_elem.findall(f"tei:{item_tag}", self.ns_map):
                            xml_id = item.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
                            if xml_id:
                                # Extrahiere PMB-Nummer (entferne Präfixe wie person__, work__, etc.)
                                pmb_id = xml_id
                                if '__' in pmb_id:
                                    pmb_id = pmb_id.split('__')[-1]
                                if pmb_id.startswith('pmb'):
                                    pmb_id = pmb_id[3:]  # Entferne 'pmb' Präfix
                                
                                # Speichere das Element unter der PMB-ID
                                self.pmb_lookups[entity_type][pmb_id] = item
                                total_entries += 1
                    
                except Exception as e:
                    print(f"Fehler beim Laden der {entity_type} Cache-Datei: {e}")
                    return False
            
            print(f"PMB-Listen aus XML-Cache geladen ({total_entries} Einträge)")
            return True
            
        except Exception as e:
            print(f"Fehler beim Laden des XML-Caches: {e}")
            return False
    
    def _save_cache(self) -> None:
        """Speichert PMB-Listen als XML-Dateien im Cache."""
        try:
            # Erstelle Cache-Verzeichnis falls nicht vorhanden
            self.cache_dir.mkdir(parents=True, exist_ok=True)
            
            for entity_type, cache_file in self.cache_files.items():
                if entity_type in self.pmb_lists and self.pmb_lists[entity_type] is not None:
                    try:
                        # Atomisches Schreiben über temporäre Datei
                        temp_file = cache_file.with_suffix('.tmp')
                        
                        # Erstelle ElementTree für diese Liste
                        tree = ET.ElementTree(self.pmb_lists[entity_type])
                        
                        # Schreibe XML mit korrekter Kodierung
                        tree.write(temp_file, encoding='utf-8', xml_declaration=True)
                        
                        # Atomisch umbenennen
                        temp_file.replace(cache_file)
                        
                    except Exception as e:
                        print(f"Fehler beim Speichern der {entity_type} Cache-Datei: {e}")
                        # Aufräumen falls temporäre Datei existiert
                        temp_file = cache_file.with_suffix('.tmp')
                        if temp_file.exists():
                            try:
                                temp_file.unlink()
                            except:
                                pass
            
            print(f"PMB-Listen als XML im Cache gespeichert: {self.cache_dir}")
            
        except Exception as e:
            print(f"Fehler beim Speichern des XML-Caches: {e}")
    
    def clear_cache(self) -> None:
        """Löscht den PMB-XML-Cache."""
        try:
            deleted_files = 0
            for cache_file in self.cache_files.values():
                if cache_file.exists():
                    cache_file.unlink()
                    deleted_files += 1
            
            if deleted_files > 0:
                print(f"XML-Cache gelöscht: {deleted_files} Dateien aus {self.cache_dir}")
            else:
                print("Kein XML-Cache vorhanden")
        except Exception as e:
            print(f"Fehler beim Löschen des XML-Caches: {e}")
    
    def load_pmb_lists(self, minimal_mode: bool = False) -> None:
        """
        Lädt alle PMB-Listen von den URLs und erstellt Lookup-Dictionaries.
        Nutzt Cache für bessere Performance.
        
        Args:
            minimal_mode: Wenn True, werden nur die wichtigsten Felder extrahiert für bessere Performance
        """
        # Versuche zuerst aus Cache zu laden
        if self._load_cache():
            return
        
        pmb_urls = {
            'person': 'https://pmb.acdh.oeaw.ac.at/media/listperson.xml',
            'work': 'https://pmb.acdh.oeaw.ac.at/media/listbibl.xml',  # work entspricht bibl
            'place': 'https://pmb.acdh.oeaw.ac.at/media/listplace.xml',
            'org': 'https://pmb.acdh.oeaw.ac.at/media/listorg.xml',
            'event': 'https://pmb.acdh.oeaw.ac.at/media/listevent.xml'
        }
        
        print("Loading PMB lists from API...")
        
        for entity_type, url in pmb_urls.items():
            try:
                print(f"  Loading {entity_type} list...")
                with urllib.request.urlopen(url) as response:
                    content = response.read()
                
                # Parse XML
                root = ET.fromstring(content)
                self.pmb_lists[entity_type] = root
                
                # Create lookup dictionary
                self.pmb_lookups[entity_type] = {}
                
                # Bestimme Liste und Element Tags basierend auf Entity-Type
                if entity_type == 'person':
                    list_tag = 'listPerson'
                    item_tag = 'person'
                elif entity_type == 'work':
                    list_tag = 'listBibl'
                    item_tag = 'bibl'
                elif entity_type == 'place':
                    list_tag = 'listPlace'
                    item_tag = 'place'
                elif entity_type == 'org':
                    list_tag = 'listOrg'
                    item_tag = 'org'
                elif entity_type == 'event':
                    list_tag = 'listEvent'
                    item_tag = 'event'
                
                # Finde die Liste im Root-Element
                list_elem = root.find(f".//tei:{list_tag}", self.ns_map)
                if list_elem is not None:
                    # Durchlaufe alle Items in der Liste
                    for item in list_elem.findall(f"tei:{item_tag}", self.ns_map):
                        xml_id = item.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
                        if xml_id:
                            # Extrahiere PMB-Nummer (entferne Präfixe wie person__, work__, etc.)
                            pmb_id = xml_id
                            if '__' in pmb_id:
                                pmb_id = pmb_id.split('__')[-1]
                            if pmb_id.startswith('pmb'):
                                pmb_id = pmb_id[3:]  # Entferne 'pmb' Präfix
                            
                            # Speichere das Element unter der PMB-ID
                            self.pmb_lookups[entity_type][pmb_id] = item
                
                print(f"    Loaded {len(self.pmb_lookups[entity_type])} {entity_type} entries")
                
            except Exception as e:
                print(f"  Error loading {entity_type} list: {e}")
                self.pmb_lists[entity_type] = None
                self.pmb_lookups[entity_type] = {}
        
        print("PMB lists loaded successfully")
        
        # Speichere im Cache für zukünftige Verwendung
        self._save_cache()
    
    def get_entity_from_pmb_lists(self, entity_type: str, pmb_id: str) -> Optional[ET.Element]:
        """
        Sucht eine Entität zuerst in den lokalen PMB-Listen.
        
        Args:
            entity_type: 'person', 'work', 'place', 'org', oder 'event'
            pmb_id: Die PMB-ID (nur die Nummer)
        
        Returns:
            XML-Element oder None wenn nicht gefunden
        """
        # Initialisiere Listen falls noch nicht geladen
        if not self.pmb_lookups:
            self.load_pmb_lists()
        
        # Suche in lokalem Lookup
        if entity_type in self.pmb_lookups:
            element = self.pmb_lookups[entity_type].get(pmb_id)
            if element is not None:
                return element
        
        # Wenn nicht in lokalen Listen gefunden, return None
        # (caller kann dann online nachschlagen)
        return None
    
    def fetch_pmb_data(self, entity_type: str, pmb_id: str) -> Optional[ET.Element]:
        """
        Lädt Daten - zuerst aus lokalen PMB-Listen, dann aus der PMB-API.
        
        Args:
            entity_type: 'person', 'work', 'place', 'org', oder 'event'
            pmb_id: Die PMB-ID (nur die Nummer)
        
        Returns:
            XML-Element oder None bei Fehler
        """
        # Zuerst in lokalen Listen suchen
        local_data = self.get_entity_from_pmb_lists(entity_type, pmb_id)
        if local_data is not None:
            print(f"Found {entity_type}/{pmb_id} in local PMB lists")
            return local_data
        
        # Wenn nicht lokal gefunden, online nachschlagen
        print(f"Entity {entity_type}/{pmb_id} not found locally, fetching from API")
        url = f"https://pmb.acdh.oeaw.ac.at/apis/tei/{entity_type}/{pmb_id}"
        
        try:
            # URL escapen
            escaped_url = urllib.parse.quote(url, safe=':/?#[]@!')
            response = requests.get(escaped_url)
            response.raise_for_status()
            
            # Parse XML response
            root = ET.fromstring(response.content)
            return root
            
        except Exception as e:
            print(f"Fehler beim Laden von PMB-Daten für {entity_type}/{pmb_id}: {e}")
            return None
    
    def create_wien_place(self) -> ET.Element:
        """Erstellt den speziellen Wien-Eintrag."""
        place = self.create_element("place")
        place.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", "pmb50")
        
        # Hauptname
        main_name = self.create_element("placeName")
        main_name.text = "Wien"
        place.append(main_name)
        
        # Alternative Namen
        for name_type, name_text in self.wien_entry['pmb50']['additional_names']:
            alt_name = self.create_element("placeName", {"type": name_type})
            alt_name.text = name_text
            place.append(alt_name)
        
        # Beschreibungen
        desc1 = self.create_element("desc", {"type": "entity_type"})
        desc1.text = "A.ADM2"
        desc2 = self.create_element("desc", {"type": "entity_type_id"})
        desc2.text = "1135"
        place.append(desc1)
        place.append(desc2)
        
        # Koordinaten
        location = self.create_element("location", {"type": "coords"})
        geo = self.create_element("geo")
        geo.text = self.wien_entry['pmb50']['coords']
        location.append(geo)
        place.append(location)
        
        # Weitere Locations (vereinfacht)
        loc_austria = self.create_element("location", {"type": "located_in_place"})
        austria_name = self.create_element("placeName", {"ref": "pmb41240"})
        austria_name.text = "Österreich"
        austria_geo = self.create_element("geo")
        austria_geo.text = "47,33333 13,33333"
        loc_austria.append(austria_name)
        loc_austria.append(austria_geo)
        place.append(loc_austria)
        
        # IDNOs (vereinfacht)
        geonames_idno = self.create_element("idno", {"type": "URL", "subtype": "geonames"})
        geonames_idno.text = "https://sws.geonames.org/2761369/"
        dnb_idno = self.create_element("idno", {"type": "URL", "subtype": "d-nb"})
        dnb_idno.text = "https://d-nb.info/gnd/4066009-6"
        place.append(geonames_idno)
        place.append(dnb_idno)
        
        return place
    
    def copy_element_without_namespace(self, source_elem: ET.Element) -> ET.Element:
        """Kopiert ein Element ohne Namespace-Deklarationen."""
        new_elem = self.create_element(source_elem.tag.split('}')[-1])
        
        # Kopiere Attribute
        for key, value in source_elem.attrib.items():
            new_elem.set(key, value)
        
        # Kopiere Text
        if source_elem.text:
            new_elem.text = source_elem.text
        
        # Kopiere Kinder rekursiv
        for child in source_elem:
            new_elem.append(self.copy_element_without_namespace(child))
        
        # Kopiere tail text
        if source_elem.tail:
            new_elem.tail = source_elem.tail
        
        return new_elem
    
    def enrich_person_list(self, list_person: ET.Element) -> ET.Element:
        """Reichert die Personenliste mit PMB-Daten an."""
        enriched_list = self.create_element("listPerson")
        
        # Sammle alle xml:id Werte
        person_ids = set()
        for person in list_person.findall('tei:person', self.ns_map):
            xml_id = person.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
            if xml_id:
                person_ids.add(xml_id)
        
        # Verarbeite jede ID
        for person_id in sorted(person_ids):
            # Spezialbehandlung für Schnitzler
            if person_id in ['2121', 'pmb2121', '#pmb2121']:
                enriched_list.append(self.create_schnitzler_person())
            else:
                # Extrahiere PMB-Nummer
                pmb_number = person_id.replace('pmb', '').replace('#', '')
                
                # Lade Daten von PMB-API
                pmb_data = self.fetch_pmb_data('person', pmb_number)
                
                if pmb_data is not None:
                    # Erstelle Person-Element
                    person = self.create_element("person")
                    person.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", f"pmb{pmb_number}")
                    
                    # Kopiere relevante Elemente
                    for child in pmb_data:
                        tag_name = child.tag.split('}')[-1] if '}' in child.tag else child.tag
                        if tag_name in ['persName', 'birth', 'death', 'sex', 'occupation', 'idno']:
                            # Prüfe auf @type='loschen' bei persName
                            if tag_name == 'persName' and child.get('type') == 'loschen':
                                continue
                            person.append(self.copy_element_without_namespace(child))
                    
                    enriched_list.append(person)
                else:
                    # Fehler-Element erstellen
                    error = self.create_element("error", {"type": "person"})
                    error.text = pmb_number
                    enriched_list.append(error)
        
        return enriched_list
    def enrich_bibl_list(self, list_bibl: ET.Element) -> ET.Element:
        """Reichert die Bibliographie-Liste mit PMB-Daten an."""
        enriched_list = self.create_element("listBibl")
        
        # Sammle alle xml:id Werte
        bibl_ids = set()
        for bibl in list_bibl.findall('tei:bibl', self.ns_map):
            xml_id = bibl.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
            if xml_id:
                bibl_ids.add(xml_id)
        
        # Verarbeite jede ID
        for bibl_id in sorted(bibl_ids):
            # Extrahiere PMB-Nummer
            pmb_number = bibl_id.replace('pmb', '').replace('#', '')
            
            # Lade Daten von PMB-API
            pmb_data = self.fetch_pmb_data('work', pmb_number)
            
            if pmb_data is not None:
                # Erstelle bibl-Element
                bibl = self.create_element("bibl")
                bibl.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", f"pmb{pmb_number}")
                
                # Kopiere relevante Elemente
                for child in pmb_data:
                    tag_name = child.tag.split('}')[-1] if '}' in child.tag else child.tag
                    if tag_name in ['title', 'author', 'date', 'note', 'idno']:
                        # Prüfe auf @type='loschen' bei title
                        if tag_name == 'title' and child.get('type') == 'loschen':
                            continue
                        # Bei note nur solche mit @type
                        if tag_name == 'note' and not child.get('type'):
                            continue
                        bibl.append(self.copy_element_without_namespace(child))
                
                enriched_list.append(bibl)
            else:
                # Fehler-Element erstellen
                error = self.create_element("error", {"type": "bibl"})
                error.text = pmb_number
                enriched_list.append(error)
        
        return enriched_list
    
    def enrich_place_list(self, list_place: ET.Element) -> ET.Element:
        """Reichert die Orte-Liste mit PMB-Daten an."""
        enriched_list = self.create_element("listPlace")
        
        # Sammle alle xml:id Werte
        place_ids = set()
        for place in list_place.findall('tei:place', self.ns_map):
            xml_id = place.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
            if xml_id:
                place_ids.add(xml_id)
        
        # Verarbeite jede ID
        for place_id in sorted(place_ids):
            # Extrahiere PMB-Nummer
            pmb_number = place_id.replace('pmb', '').replace('#', '')
            
            # Spezialbehandlung für Wien
            if pmb_number == '50':
                enriched_list.append(self.create_wien_place())
            else:
                # Lade Daten von PMB-API
                pmb_data = self.fetch_pmb_data('place', pmb_number)
                
                if pmb_data is not None:
                    # Kopiere das gesamte Element
                    place_copy = self.copy_element_without_namespace(pmb_data)
                    enriched_list.append(place_copy)
                else:
                    # Fehler-Element erstellen
                    error = self.create_element("error", {"type": "place"})
                    error.text = pmb_number
                    enriched_list.append(error)
        
        return enriched_list
    
    def enrich_org_list(self, list_org: ET.Element) -> ET.Element:
        """Reichert die Organisations-Liste mit PMB-Daten an."""
        enriched_list = self.create_element("listOrg")
        
        # Sammle alle xml:id Werte
        org_ids = set()
        for org in list_org.findall('tei:org', self.ns_map):
            xml_id = org.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
            if xml_id:
                org_ids.add(xml_id)
        
        # Verarbeite jede ID
        for org_id in sorted(org_ids):
            # Extrahiere PMB-Nummer
            pmb_number = org_id.replace('pmb', '').replace('#', '')
            
            # Lade Daten von PMB-API
            pmb_data = self.fetch_pmb_data('org', pmb_number)
            
            if pmb_data is not None:
                # Kopiere das gesamte Element
                org_copy = self.copy_element_without_namespace(pmb_data)
                enriched_list.append(org_copy)
            else:
                # Fehler-Element erstellen
                error = self.create_element("error", {"type": "org"})
                error.text = pmb_number
                enriched_list.append(error)
        
        return enriched_list
    
    def enrich_event_list(self, list_event: ET.Element) -> ET.Element:
        """Reichert die Event-Liste mit PMB-Daten an."""
        enriched_list = self.create_element("listEvent")
        
        # Sammle alle xml:id Werte
        event_ids = set()
        for event in list_event.findall('tei:event', self.ns_map):
            xml_id = event.get(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id")
            if xml_id:
                event_ids.add(xml_id)
        
        # Verarbeite jede ID
        for event_id in sorted(event_ids):
            # Extrahiere PMB-Nummer
            pmb_number = event_id.replace('pmb', '').replace('#', '')
            
            # Lade Daten von PMB-API
            pmb_data = self.fetch_pmb_data('event', pmb_number)
            
            if pmb_data is not None:
                # Kopiere das gesamte Element
                event_copy = self.copy_element_without_namespace(pmb_data)
                enriched_list.append(event_copy)
            else:
                # Fehler-Element erstellen
                error = self.create_element("error", {"type": "event"})
                error.text = pmb_number
                enriched_list.append(error)
        
        return enriched_list
    
    def create_schnitzler_person(self) -> ET.Element:
        """Erstellt den speziellen Arthur Schnitzler Eintrag."""
        person = self.create_element("person", {"xml:id": "pmb2121"})
        
        # persName
        persName = self.create_element("persName")
        surname = self.create_element("surname")
        surname.text = "Schnitzler"
        forename = self.create_element("forename")
        forename.text = "Arthur"
        persName.append(surname)
        persName.append(forename)
        person.append(persName)
        
        # birth
        birth = self.create_element("birth")
        birth_date = self.create_element("date", {"when": "1862-05-15"})
        birth_date.text = "15. 5. 1862"
        birth_settlement = self.create_element("settlement", {"key": "pmb50"})
        birth_placeName = self.create_element("placeName", {"type": "pref"})
        birth_placeName.text = "Wien"
        birth_location = self.create_element("location")
        birth_geo = self.create_element("geo")
        birth_geo.text = "48,208333 16,373056"
        birth_location.append(birth_geo)
        birth_settlement.append(birth_placeName)
        birth_settlement.append(birth_location)
        birth.append(birth_date)
        birth.append(birth_settlement)
        person.append(birth)
        
        # death
        death = self.create_element("death")
        death_date = self.create_element("date", {"when": "1931-10-21"})
        death_date.text = "21. 10. 1931"
        death_settlement = self.create_element("settlement", {"key": "pmb50"})
        death_placeName = self.create_element("placeName", {"type": "pref"})
        death_placeName.text = "Wien"
        death_location = self.create_element("location")
        death_geo = self.create_element("geo")
        death_geo.text = "48,208333 16,373056"
        death_location.append(death_geo)
        death_settlement.append(death_placeName)
        death_settlement.append(death_location)
        death.append(death_date)
        death.append(death_settlement)
        person.append(death)
        
        # sex
        sex = self.create_element("sex", {"value": "male"})
        person.append(sex)
        
        # occupations
        occ1 = self.create_element("occupation", {"ref": "pmb90"})
        occ1.text = "Schriftsteller*in"
        occ2 = self.create_element("occupation", {"ref": "pmb97"})
        occ2.text = "Mediziner*in"
        person.append(occ1)
        person.append(occ2)
        
        # idno
        idno = self.create_element("idno", {"type": "gnd"})
        idno.text = "https://d-nb.info/gnd/118609807/"
        person.append(idno)
        
        return person
    
    def has_hash_refs(self, root: ET.Element) -> bool:
        """
        Prüft ob das Dokument Hash-basierte Referenzen verwendet.
        """
        # Suche nach rs-Elementen mit @ref die # enthalten
        for rs in root.findall('.//tei:rs[@ref]', self.ns_map):
            ref = rs.get('ref', '')
            if '#' in ref:
                return True
        return False
    
    def is_in_back_element(self, elem: ET.Element, root: ET.Element) -> bool:
        """Prüft ob ein Element innerhalb eines back-Elements liegt."""
        # Erstelle eine Map aller Elemente zu ihren Eltern
        parent_map = {c: p for p in root.iter() for c in p}
        
        # Durchlaufe die Eltern bis zur Wurzel
        current = elem
        while current in parent_map:
            parent = parent_map[current]
            if parent.tag == f"{{{self.tei_ns}}}back":
                return True
            current = parent
        return False
    
    def collect_person_refs(self, root: ET.Element, has_hash: bool) -> Set[str]:
        """Sammelt alle Personen-Referenzen."""
        refs = set()
        
        # Personen aus rs[@type='person'] mit @ref
        for rs in root.findall('.//tei:rs[@type="person"][@ref]', self.ns_map):
            if not self.is_in_back_element(rs, root):
                ref_attr = rs.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # persName mit @ref
        for persName in root.findall('.//tei:persName[@ref]', self.ns_map):
            if not self.is_in_back_element(persName, root):
                ref_attr = persName.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # author mit @ref
        for author in root.findall('.//tei:author[@ref]', self.ns_map):
            if not self.is_in_back_element(author, root):
                ref_attr = author.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # Zusätzlich handShift/@scribe und handNote/@corresp
        for handshift in root.findall('.//tei:handShift[@scribe]', self.ns_map):
            scribe = handshift.get('scribe', '').replace('#', '').strip()
            if scribe:
                refs.add(scribe)
        
        for handnote in root.findall('.//tei:handNote[@corresp]', self.ns_map):
            corresp = handnote.get('corresp', '').replace('#', '').strip()
            if corresp and corresp != 'schreibkraft':
                refs.add(corresp)
        
        return refs
    
    def collect_work_refs(self, root: ET.Element, has_hash: bool) -> Set[str]:
        """Sammelt alle Werk-Referenzen."""
        refs = set()
        
        # Werke aus rs[@type='work'] (nur wenn has_hash True ist)
        if has_hash:
            for rs in root.findall('.//tei:rs[@type="work"][@ref]', self.ns_map):
                if not self.is_in_back_element(rs, root):
                    ref_attr = rs.get('ref', '')
                    refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # Titel-Referenzen aus biblStruct
        for title in root.findall('.//tei:biblStruct//tei:title[@ref]', self.ns_map):
            ref_attr = title.get('ref', '')
            refs.update(self.extract_refs_from_attribute(ref_attr, True))  # Immer # für Titel
        
        # Titel-Referenzen aus teiHeader
        for title in root.findall('.//tei:teiHeader//tei:title[@ref]', self.ns_map):
            ref_attr = title.get('ref', '')
            cleaned = ref_attr.replace('#', '').strip()
            if cleaned:
                refs.add(cleaned)
        
        return refs
    
    def collect_place_refs(self, root: ET.Element, has_hash: bool) -> Set[str]:
        """Sammelt alle Orts-Referenzen."""
        refs = set()
        
        # rs[@type='place'] mit @ref
        for rs in root.findall('.//tei:rs[@type="place"][@ref]', self.ns_map):
            if not self.is_in_back_element(rs, root):
                ref_attr = rs.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # placeName mit @ref
        for placeName in root.findall('.//tei:placeName[@ref]', self.ns_map):
            if not self.is_in_back_element(placeName, root):
                ref_attr = placeName.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        return refs
    
    def collect_org_refs(self, root: ET.Element, has_hash: bool) -> Set[str]:
        """Sammelt alle Organisations-Referenzen."""
        refs = set()
        
        # rs[@type='org'] mit @ref
        for rs in root.findall('.//tei:rs[@type="org"][@ref]', self.ns_map):
            if not self.is_in_back_element(rs, root):
                ref_attr = rs.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # orgName mit @ref
        for orgName in root.findall('.//tei:orgName[@ref]', self.ns_map):
            if not self.is_in_back_element(orgName, root):
                ref_attr = orgName.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        return refs
    
    def collect_event_refs(self, root: ET.Element, has_hash: bool) -> Set[str]:
        """Sammelt alle Event-Referenzen."""
        refs = set()
        
        # rs[@type='event'] mit @ref
        for rs in root.findall('.//tei:rs[@type="event"][@ref]', self.ns_map):
            if not self.is_in_back_element(rs, root):
                ref_attr = rs.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        # eventName mit @ref
        for eventName in root.findall('.//tei:eventName[@ref]', self.ns_map):
            if not self.is_in_back_element(eventName, root):
                ref_attr = eventName.get('ref', '')
                refs.update(self.extract_refs_from_attribute(ref_attr, has_hash))
        
        return refs
    
    def create_element(self, tag_name: str, attribs: dict = None) -> ET.Element:
        """Erstellt ein Element mit TEI-Namespace."""
        elem = ET.Element(f"{{{self.tei_ns}}}{tag_name}")
        if attribs:
            for key, value in attribs.items():
                elem.set(key, value)
        return elem
    
    def create_facsimile_element(self, root: ET.Element) -> ET.Element:
        """Erstellt facsimile-Element basierend auf pb/@facs Attributen."""
        facsimile = self.create_element("facsimile")
        
        # Sammle alle facs-Attribute von pb-Elementen
        facs_urls = set()
        for pb in root.findall('.//tei:pb[@facs]', self.ns_map):
            facs = pb.get('facs', '').strip()
            # Filtere leere, PDF und HTTP-URLs aus
            if facs and not facs.endswith('.pdf') and not facs.startswith('http'):
                facs_urls.add(facs)
        
        # Erstelle graphic-Elemente
        for url in sorted(facs_urls):
            graphic = self.create_element("graphic", {"url": url})
            facsimile.append(graphic)
        
        return facsimile if len(facs_urls) > 0 else None
    
    def create_back_element(self, root: ET.Element) -> ET.Element:
        """Erstellt das komplette back-Element mit allen Listen."""
        back = self.create_element("back")
        has_hash = self.has_hash_refs(root)
        
        # listPerson
        list_person = self.create_element("listPerson")
        person_refs = self.collect_person_refs(root, has_hash)
        for ref_id in sorted(person_refs):
            person = self.create_element("person")
            person.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", ref_id)
            list_person.append(person)
        back.append(list_person)
        
        # listBibl
        list_bibl = self.create_element("listBibl")
        work_refs = self.collect_work_refs(root, has_hash)
        for ref_id in sorted(work_refs):
            bibl = self.create_element("bibl")
            bibl.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", ref_id)
            list_bibl.append(bibl)
        back.append(list_bibl)
        
        # listPlace
        list_place = self.create_element("listPlace")
        place_refs = self.collect_place_refs(root, has_hash)
        for ref_id in sorted(place_refs):
            place = self.create_element("place")
            place.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", ref_id)
            list_place.append(place)
        back.append(list_place)
        
        # listOrg
        list_org = self.create_element("listOrg")
        org_refs = self.collect_org_refs(root, has_hash)
        for ref_id in sorted(org_refs):
            org = self.create_element("org")
            org.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", ref_id)
            list_org.append(org)
        back.append(list_org)
        
        # listEvent
        list_event = self.create_element("listEvent")
        event_refs = self.collect_event_refs(root, has_hash)
        for ref_id in sorted(event_refs):
            event = self.create_element("event")
            event.set(f"{{{ET._namespace_map.get('xml', 'http://www.w3.org/XML/1998/namespace')}}}id", ref_id)
            list_event.append(event)
        back.append(list_event)
        
        return back
    
    def post_process_back_element(self, back_element: ET.Element) -> None:
        """
        Applies post-processing transformations from brief_backElement-3.xsl
        """
        # Transform date ISO attributes
        for elem in back_element.iter():
            # @when-iso -> @when
            if 'when-iso' in elem.attrib:
                when_iso = elem.attrib['when-iso']
                elem.set('when', self._normalize_date_attribute(when_iso))
                del elem.attrib['when-iso']
            
            # @notAfter-iso -> @notAfter
            if 'notAfter-iso' in elem.attrib:
                not_after_iso = elem.attrib['notAfter-iso']
                elem.set('notAfter', self._normalize_date_attribute(not_after_iso))
                del elem.attrib['notAfter-iso']
            
            # @notBefore-iso -> @notBefore
            if 'notBefore-iso' in elem.attrib:
                not_before_iso = elem.attrib['notBefore-iso']
                elem.set('notBefore', self._normalize_date_attribute(not_before_iso))
                del elem.attrib['notBefore-iso']
            
            # @from-iso -> @from
            if 'from-iso' in elem.attrib:
                from_iso = elem.attrib['from-iso']
                elem.set('from', from_iso)
                del elem.attrib['from-iso']
            
            # @to-iso -> @to
            if 'to-iso' in elem.attrib:
                to_iso = elem.attrib['to-iso']
                elem.set('to', to_iso)
                del elem.attrib['to-iso']
            
            # Transform @key to @ref with pmb prefix
            if 'key' in elem.attrib:
                key_val = elem.attrib['key']
                if not key_val.startswith('pmb'):
                    elem.set('ref', f'pmb{key_val}')
                else:
                    elem.set('ref', key_val)
                del elem.attrib['key']
        
        # Transform placeName @ref with place__ pattern
        for place_name in back_element.findall('.//tei:placeName', self.ns_map):
            ref_attr = place_name.get('ref', '')
            if 'place__' in ref_attr:
                new_ref = f"pmb{ref_attr.replace('place__', '')}"
                place_name.set('ref', new_ref)
        
        # Transform bibl/author @ref with person__ pattern
        for author in back_element.findall('.//tei:bibl/tei:author', self.ns_map):
            ref_attr = author.get('ref', '')
            if ref_attr.startswith('person__'):
                new_ref = f"pmb{ref_attr.replace('person__', '')}"
                author.set('ref', new_ref)
        
        # Transform xml:id attributes
        self._transform_xml_ids(back_element)
        
        # Transform URL elements and add subtypes
        self._transform_url_elements(back_element)
        
        # Transform titles and notes
        self._transform_titles_and_notes(back_element)
        
        # Remove duplicate placeName elements
        self._remove_duplicate_place_names(back_element)
        
        # Remove empty lists (handled by existing logic in process_tei_file)
        
        # Clean up date elements with &lt; content
        self._clean_date_elements(back_element)
        
        # Remove all collection-type elements
        self._remove_collection_elements(back_element)
    
    def _normalize_date_attribute(self, date_str: str) -> str:
        """Normalize date attribute by padding year to 4 digits"""
        if not date_str or '-' not in date_str:
            return date_str
        
        year_part = date_str.split('-')[0]
        if len(year_part) == 4:
            return date_str
        elif len(year_part) == 3:
            return f"0{date_str}"
        elif len(year_part) == 2:
            return f"00{date_str}"
        elif len(year_part) == 1:
            return f"000{date_str}"
        else:
            return date_str
    
    def _transform_xml_ids(self, back_element: ET.Element) -> None:
        """Transform xml:id attributes from entity__ patterns to pmb format"""
        xml_ns = '{http://www.w3.org/XML/1998/namespace}'
        
        # Transform bibl xml:id
        for bibl in back_element.findall('.//tei:listBibl/tei:bibl', self.ns_map):
            xml_id = bibl.get(f'{xml_ns}id', '')
            if 'work__' in xml_id:
                new_id = f"pmb{xml_id.replace('work__', '')}"
                bibl.set(f'{xml_ns}id', new_id)
        
        # Transform person xml:id
        for person in back_element.findall('.//tei:listPerson/tei:person', self.ns_map):
            xml_id = person.get(f'{xml_ns}id', '')
            if 'person__' in xml_id:
                new_id = f"pmb{xml_id.replace('person__', '')}"
                person.set(f'{xml_ns}id', new_id)
        
        # Transform place xml:id
        for place in back_element.findall('.//tei:listPlace/tei:place', self.ns_map):
            xml_id = place.get(f'{xml_ns}id', '')
            if 'place__' in xml_id:
                new_id = f"pmb{xml_id.replace('place__', '')}"
                place.set(f'{xml_ns}id', new_id)
        
        # Transform org xml:id
        for org in back_element.findall('.//tei:listOrg/tei:org', self.ns_map):
            xml_id = org.get(f'{xml_ns}id', '')
            if 'org__' in xml_id:
                new_id = f"pmb{xml_id.replace('org__', '')}"
                org.set(f'{xml_ns}id', new_id)
        
        # Transform event xml:id
        for event in back_element.findall('.//tei:listEvent/tei:event', self.ns_map):
            xml_id = event.get(f'{xml_ns}id', '')
            if 'event__' in xml_id:
                new_id = f"pmb{xml_id.replace('event__', '')}"
                event.set(f'{xml_ns}id', new_id)
    
    def _transform_url_elements(self, back_element: ET.Element) -> None:
        """Transform URL elements and add appropriate subtypes"""
        # Transform idno[@type='URL'] elements
        for idno in back_element.findall('.//tei:idno[@type="URL"]', self.ns_map):
            url = idno.text or ''
            subtype = self._get_url_subtype(url)
            if subtype:
                idno.set('subtype', subtype)
        
        # Transform note[@type='IDNO'] to idno elements
        notes_to_replace = []
        for note in back_element.findall('.//tei:note[@type="IDNO"]', self.ns_map):
            url = note.text or ''
            subtype = self._get_url_subtype(url)
            
            # Create new idno element
            idno = self.create_element('idno')
            idno.set('type', 'URL')
            if subtype:
                idno.set('subtype', subtype)
            idno.text = url
            
            notes_to_replace.append((note, idno))
        
        # Replace notes with idno elements
        for note, idno in notes_to_replace:
            parent = self._find_parent(back_element, note)
            if parent is not None:
                parent.insert(list(parent).index(note), idno)
                parent.remove(note)
        
        # Transform orgName[contains(@type, 'uri')] to idno elements
        org_names_to_replace = []
        for org_name in back_element.findall('.//tei:orgName', self.ns_map):
            type_attr = org_name.get('type', '')
            if 'uri' in type_attr:
                url = org_name.text or ''
                subtype = self._get_url_subtype(url)
                
                # Create new idno element
                idno = self.create_element('idno')
                idno.set('type', 'URL')
                if subtype:
                    idno.set('subtype', subtype)
                idno.text = url
                
                org_names_to_replace.append((org_name, idno))
        
        # Replace orgName elements with idno elements
        for org_name, idno in org_names_to_replace:
            parent = self._find_parent(back_element, org_name)
            if parent is not None:
                parent.insert(list(parent).index(org_name), idno)
                parent.remove(org_name)
    
    def _get_url_subtype(self, url: str) -> str:
        """Extract subtype from URL"""
        if not url:
            return ''
        
        if 'wikipedia' in url:
            return 'wikipedia'
        elif 'wikidata' in url:
            return 'wikidata'
        elif 'geonames' in url:
            return 'geonames'
        elif url.startswith('https://www.'):
            domain = url.replace('https://www.', '').split('.')[0]
            return domain
        elif url.startswith('http://www.'):
            domain = url.replace('http://www.', '').split('.')[0]
            return domain
        elif url.startswith('https://'):
            domain = url.replace('https://', '').split('.')[0]
            return domain
        elif url.startswith('http://'):
            domain = url.replace('http://', '').split('.')[0]
            return domain
        else:
            return url.split('.')[0] if '.' in url else ''
    
    def _transform_titles_and_notes(self, back_element: ET.Element) -> None:
        """Transform title elements to notes and idno elements"""
        # Remove @type='main' attribute from title elements (but keep the titles)
        for title in back_element.findall('.//tei:title[@type="main"]', self.ns_map):
            if 'type' in title.attrib:
                del title.attrib['type']
        
        # Transform title[@type='bibliografische_angabe'] to note
        titles_to_replace = []
        for title in back_element.findall('.//tei:title[@type="bibliografische_angabe"]', self.ns_map):
            note = self.create_element('note')
            note.set('type', 'bibliografische_angabe')
            note.text = title.text
            titles_to_replace.append((title, note))
        
        for title, note in titles_to_replace:
            parent = self._find_parent(back_element, title)
            if parent is not None:
                parent.insert(list(parent).index(title), note)
                parent.remove(title)
        
        # Transform title[@type='uri_worklink'] to note
        titles_to_replace = []
        for title in back_element.findall('.//tei:title[@type="uri_worklink"]', self.ns_map):
            note = self.create_element('note')
            note.set('type', 'uri_worklink')
            note.text = title.text
            titles_to_replace.append((title, note))
        
        for title, note in titles_to_replace:
            parent = self._find_parent(back_element, title)
            if parent is not None:
                parent.insert(list(parent).index(title), note)
                parent.remove(title)
        
        # Transform title[contains(@type, 'wikipedia')] to idno
        titles_to_replace = []
        for title in back_element.findall('.//tei:title', self.ns_map):
            type_attr = title.get('type', '')
            if 'wikipedia' in type_attr:
                url = title.text or ''
                subtype = self._get_url_subtype(url)
                
                idno = self.create_element('idno')
                idno.set('type', 'URL')
                if subtype:
                    idno.set('subtype', subtype)
                idno.text = url
                titles_to_replace.append((title, idno))
        
        for title, idno in titles_to_replace:
            parent = self._find_parent(back_element, title)
            if parent is not None:
                parent.insert(list(parent).index(title), idno)
                parent.remove(title)
    
    def _remove_duplicate_place_names(self, back_element: ET.Element) -> None:
        """Remove duplicate placeName elements"""
        for place in back_element.findall('.//tei:place', self.ns_map):
            seen_names = set()
            place_names = place.findall('tei:placeName', self.ns_map)
            
            for place_name in place_names:
                name_text = place_name.text or ''
                if name_text in seen_names:
                    place.remove(place_name)
                else:
                    seen_names.add(name_text)
    
    def _clean_date_elements(self, back_element: ET.Element) -> None:
        """Clean date elements containing &lt; by removing everything after it"""
        for date in back_element.findall('.//tei:date', self.ns_map):
            if date.text and '&lt;' in date.text:
                date.text = date.text.split('&lt;')[0]
    
    def _find_parent(self, root: ET.Element, target: ET.Element) -> Optional[ET.Element]:
        """Find the parent element of target element within root"""
        for elem in root.iter():
            if target in list(elem):
                return elem
        return None
    
    def _extract_processing_instructions(self, input_file: str) -> List[str]:
        """Extract processing instructions from XML file"""
        processing_instructions = []
        
        try:
            with open(input_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find all processing instructions
            import re
            pi_pattern = r'<\?[^>]+\?>'
            matches = re.findall(pi_pattern, content)
            
            for match in matches:
                # Skip XML declaration
                if not match.startswith('<?xml '):
                    processing_instructions.append(match)
                    
        except Exception as e:
            print(f"Warning: Could not extract processing instructions: {e}")
            
        return processing_instructions
    
    def _write_xml_with_processing_instructions(self, tree: ET.ElementTree, output_file: str, processing_instructions: List[str]) -> None:
        """Write XML file with processing instructions preserved and original formatting maintained"""
        # Read the original file to preserve formatting
        with open(output_file, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        # Find the back element in the modified tree
        root = tree.getroot()
        text_elem = root.find(f"tei:text", self.ns_map)
        if text_elem is not None:
            back_elem = text_elem.find(f"tei:back", self.ns_map)
            if back_elem is not None:
                # Convert only the back element to string
                back_str = ET.tostring(back_elem, encoding='unicode')
                
                # Replace the back element in the original content
                import re
                
                # Pattern to match the entire back element (including content)
                back_pattern = r'<back[^>]*>.*?</back>'
                
                # Check if back element exists in original
                if re.search(back_pattern, original_content, re.DOTALL):
                    # Replace existing back element
                    new_content = re.sub(back_pattern, back_str, original_content, flags=re.DOTALL)
                else:
                    # Insert back element before </text>
                    new_content = re.sub(r'(\s*</text>)', f'\n      {back_str}\\1', original_content)
                
                # Processing instructions are already preserved in the original content
                # so we don't need to update them again
                
                # Write to file
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                return
        
        # Fallback: if we can't find back element, write normally
        self._write_xml_fallback(tree, output_file, processing_instructions)
    
    def _update_processing_instructions(self, content: str, processing_instructions: List[str]) -> str:
        """Update processing instructions in XML content while preserving formatting"""
        lines = content.split('\n')
        new_lines = []
        i = 0
        
        # Handle XML declaration
        if i < len(lines) and lines[i].strip().startswith('<?xml'):
            new_lines.append('<?xml version="1.0" encoding="UTF-8"?>')
            i += 1
        else:
            new_lines.append('<?xml version="1.0" encoding="UTF-8"?>')
        
        # Add our processing instructions
        new_lines.extend(processing_instructions)
        
        # Skip any existing processing instructions in the original
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith('<?') and line.endswith('?>') and not line.startswith('<?xml'):
                i += 1  # Skip existing processing instruction
            else:
                break
        
        # Add all remaining lines
        new_lines.extend(lines[i:])
        
        return '\n'.join(new_lines)
    
    def _write_xml_fallback(self, tree: ET.ElementTree, output_file: str, processing_instructions: List[str]) -> None:
        """Fallback method for writing XML when original structure can't be preserved"""
        lines = ['<?xml version="1.0" encoding="UTF-8"?>']
        lines.extend(processing_instructions)
        
        xml_str = ET.tostring(tree.getroot(), encoding='unicode')
        lines.append(xml_str)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))
    
    def _remove_collection_elements(self, back_element: ET.Element) -> None:
        """Remove all elements with @type='collections' from the back element"""
        elements_to_remove = []
        
        # Find all elements with @type='collections' in the back element
        for elem in back_element.iter():
            if elem.get('type') == 'collections':
                elements_to_remove.append(elem)
        
        # Remove each element
        for elem in elements_to_remove:
            parent = self._find_parent(back_element, elem)
            if parent is not None:
                parent.remove(elem)
        
        # Also remove entire listBibl elements that only contain collections
        listbibls_to_remove = []
        for listbibl in back_element.findall('.//tei:listBibl', self.ns_map):
            # Check if all children are collection-type
            all_collections = True
            has_children = False
            for child in listbibl:
                has_children = True
                if child.get('type') != 'collections':
                    all_collections = False
                    break
            
            # Remove listBibl if it only contains collections or is now empty
            if has_children and all_collections:
                listbibls_to_remove.append(listbibl)
        
        for listbibl in listbibls_to_remove:
            parent = self._find_parent(back_element, listbibl)
            if parent is not None:
                parent.remove(listbibl)
        
        # Clean up any empty listBibl elements that resulted from collection removal
        empty_listbibls = []
        for listbibl in back_element.findall('.//tei:listBibl', self.ns_map):
            # Check if listBibl is empty or contains only whitespace
            has_non_whitespace_content = False
            for child in listbibl:
                has_non_whitespace_content = True
                break
            if not has_non_whitespace_content:
                # Check if it has any text content (excluding whitespace)
                text_content = (listbibl.text or '').strip()
                tail_content = (listbibl.tail or '').strip()
                if not text_content and not tail_content:
                    empty_listbibls.append(listbibl)
        
        for empty_listbibl in empty_listbibls:
            parent = self._find_parent(back_element, empty_listbibl)
            if parent is not None:
                parent.remove(empty_listbibl)
    
    def process_tei_file(self, input_file: str, output_file: str = None, enrich_with_pmb: bool = True, load_pmb_lists: bool = True) -> bool:
        """
        Verarbeitet eine TEI-XML-Datei und überschreibt das back-Element.
        
        Args:
            input_file: Pfad zur Eingabedatei
            output_file: Pfad zur Ausgabedatei (optional, überschreibt input_file wenn None)
            enrich_with_pmb: Ob Listen mit PMB-Daten angereichert werden sollen
            load_pmb_lists: Ob PMB-Listen vorab geladen werden sollen für bessere Performance
        
        Returns:
            True bei Erfolg, False bei Fehler
        """
        try:
            # PMB-Listen laden falls gewünscht und noch nicht geladen
            if enrich_with_pmb and load_pmb_lists and not self.pmb_lookups:
                self.load_pmb_lists()
                
            # XML-Datei laden
            tree = ET.parse(input_file)
            root = tree.getroot()
            
            # Processing Instructions aus der Original-Datei extrahieren
            processing_instructions = self._extract_processing_instructions(input_file)
            
            # Prüfe ob es ein TEI-Dokument ist
            if root.tag != f"{{{self.tei_ns}}}TEI":
                print(f"Warnung: {input_file} ist kein TEI-Dokument")
                return False
            
            # Finde text-Element
            text_elem = root.find(f"tei:text", self.ns_map)
            if text_elem is None:
                print(f"Fehler: Kein text-Element in {input_file} gefunden")
                return False
            
            # Prüfe und erstelle facsimile falls nötig
            existing_facsimile = root.find(f"tei:facsimile", self.ns_map)
            if existing_facsimile is None:
                facsimile = self.create_facsimile_element(root)
                if facsimile is not None:
                    # Füge facsimile nach teiHeader ein
                    tei_header = root.find(f"tei:teiHeader", self.ns_map)
                    if tei_header is not None:
                        tei_header_index = list(root).index(tei_header)
                        root.insert(tei_header_index + 1, facsimile)
            
            # Entferne vorhandenes back-Element
            existing_back = text_elem.find(f"tei:back", self.ns_map)
            if existing_back is not None:
                text_elem.remove(existing_back)
            
            # Erstelle neues back-Element
            new_back = self.create_back_element(root)
            
            # Anreicherung mit PMB-Daten falls gewünscht
            if enrich_with_pmb:
                print("Reichere Listen mit PMB-Daten an...")
                
                # Entferne leere Listen
                empty_lists = []
                for child in new_back:
                    if len(child) == 0:  # Keine Kinder
                        empty_lists.append(child)
                
                for empty_list in empty_lists:
                    new_back.remove(empty_list)
                
                # Reichere Listen mit Inhalt an
                enriched_back = self.create_element("back")
                
                for list_elem in new_back:
                    tag_name = list_elem.tag.split('}')[-1] if '}' in list_elem.tag else list_elem.tag
                    
                    if len(list_elem) > 0:  # Nur Listen mit Inhalt
                        if tag_name == "listPerson":
                            enriched_list = self.enrich_person_list(list_elem)
                            if enriched_list is not None:
                                enriched_back.append(enriched_list)
                        elif tag_name == "listBibl":
                            enriched_list = self.enrich_bibl_list(list_elem)
                            if enriched_list is not None:
                                enriched_back.append(enriched_list)
                        elif tag_name == "listPlace":
                            enriched_list = self.enrich_place_list(list_elem)
                            if enriched_list is not None:
                                enriched_back.append(enriched_list)
                        elif tag_name == "listOrg":
                            enriched_list = self.enrich_org_list(list_elem)
                            if enriched_list is not None:
                                enriched_back.append(enriched_list)
                        elif tag_name == "listEvent":
                            enriched_list = self.enrich_event_list(list_elem)
                            if enriched_list is not None:
                                enriched_back.append(enriched_list)
                
                new_back = enriched_back
            
            # Apply post-processing transformations (equivalent to brief_backElement-3.xsl)
            print("Applying post-processing transformations...")
            self.post_process_back_element(new_back)
            
            text_elem.append(new_back)
            
            # Ausgabedatei bestimmen
            if output_file is None:
                output_file = input_file
            
            # XML schreiben
            # Setze xml:lang attribute falls nicht vorhanden
            if 'xml' not in ET._namespace_map:
                ET.register_namespace('xml', 'http://www.w3.org/XML/1998/namespace')
            
            self._write_xml_with_processing_instructions(tree, output_file, processing_instructions)
            
            action_text = "generiert und mit PMB-Daten angereichert" if enrich_with_pmb else "generiert"
            print(f"Back-Element erfolgreich {action_text}: {output_file}")
            return True
            
        except ET.ParseError as e:
            print(f"XML-Parse-Fehler in {input_file}: {e}")
            return False
        except Exception as e:
            import traceback
            print(f"Fehler beim Verarbeiten von {input_file}: {e}")
            traceback.print_exc()
            return False


def main():
    """Hauptfunktion für Kommandozeilen-Interface."""
    parser = argparse.ArgumentParser(
        description="TEI XML Back Element Generator and PMB Enricher - Generiert back-Element und reichert mit PMB-Daten an"
    )
    parser.add_argument('input_file', help='Eingabe TEI-XML-Datei')
    parser.add_argument('-o', '--output', help='Ausgabedatei (optional, überschreibt Eingabedatei wenn nicht angegeben)')
    parser.add_argument('--no-pmb', action='store_true', help='Keine PMB-Anreicherung durchführen, nur Listen generieren')
    parser.add_argument('--no-local-lists', action='store_true', help='PMB-Listen nicht vorab laden, immer online nachschlagen')
    parser.add_argument('--clear-cache', action='store_true', help='PMB-Cache löschen und neu aufbauen')
    
    args = parser.parse_args()
    
    # Prüfe ob Eingabedatei existiert
    if not Path(args.input_file).exists():
        print(f"Fehler: Eingabedatei {args.input_file} nicht gefunden")
        sys.exit(1)
    
    # Verarbeite Datei
    generator = TEIBackGenerator()
    
    # Cache löschen falls gewünscht
    if args.clear_cache:
        generator.clear_cache()
    
    success = generator.process_tei_file(
        args.input_file, 
        args.output, 
        enrich_with_pmb=not args.no_pmb,
        load_pmb_lists=not args.no_local_lists
    )
    
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()