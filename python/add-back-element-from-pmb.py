#!/usr/bin/env python3
"""
Python implementation of the four XSLT files in xslts/brief_back-element/:
- brief_backElement-1.xsl: Creates back element with empty placeholders
- brief_backElement-2.xsl: Populates placeholders with PMB data
- brief_backElement-3.xsl: Adds persons from bibliography authors
- brief_backElement-4.xsl: Normalizes and cleans up the data
"""

import sys
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Set, Dict, Optional
import requests
import copy


class PMBProcessor:
    def __init__(self, pmb_lists_dir: str = "python-temp"):
        print(f"🔧 Initializing PMBProcessor...")
        sys.stdout.flush()
        
        self.pmb_lists_dir = Path(pmb_lists_dir)
        self.tei_ns = "http://www.tei-c.org/ns/1.0"
        self.xml_ns = "http://www.w3.org/XML/1998/namespace"
        self.ns = {"tei": self.tei_ns, "xml": self.xml_ns}
        
        # Statistics for debugging
        self.stats = {
            "pmb_lookups": 0,
            "pmb_found": 0,
            "pmb_not_found": 0,
            "api_calls": 0,
            "api_success": 0,
            "api_failures": 0
        }
        
        print(f"📥 Initializing optimized PMB system...")
        sys.stdout.flush()
        
        # Optimized minimal loading approach
        self.pmb_cache = {}  # Small cache for recently accessed entities (max 1000)
        self.pmb_index = {}  # Minimal index: {pmb_id: entity_type}
        self.api_session = requests.Session()  # Reuse connection
        self.max_cache_size = 1000
        
        # Create minimal index only (should be very fast)
        self._create_minimal_pmb_index()
        
        print(f"✅ PMBProcessor initialized with minimal loading strategy")
        sys.stdout.flush()
        
        # Register namespaces
        ET.register_namespace("", self.tei_ns)
        ET.register_namespace("xml", self.xml_ns)

    def _create_minimal_pmb_index(self) -> None:
        """Create a minimal index of PMB IDs without loading full entity data"""
        file_types = {
            "listperson.xml": "person",
            "listplace.xml": "place", 
            "listorg.xml": "org",
            "listbibl.xml": "work",
            "listevent.xml": "event"
        }
        
        total_indexed = 0
        
        for filename, entity_type in file_types.items():
            filepath = self.pmb_lists_dir / filename
            if not filepath.exists():
                print(f"⚠️ {filename} not found, skipping index creation for {entity_type}")
                continue
                
            try:
                # Use iterparse for memory efficiency - only read ID attributes
                print(f"📋 Indexing {entity_type} IDs from {filename}...")
                sys.stdout.flush()
                
                count = 0
                for event, elem in ET.iterparse(filepath, events=('start',)):
                    # Only process the main entity elements
                    if elem.tag.endswith(entity_type) or (entity_type == "work" and elem.tag.endswith("bibl")):
                        xml_id = elem.get(f"{{{self.xml_ns}}}id")
                        if xml_id:
                            self.pmb_index[xml_id] = entity_type
                            count += 1
                        elem.clear()  # Free memory immediately
                        
                print(f"✅ Indexed {count} {entity_type} IDs")
                total_indexed += count
                sys.stdout.flush()
                
            except Exception as e:
                print(f"❌ Error indexing {filename}: {e}")
                sys.stdout.flush()
        
        print(f"📊 Total PMB entities indexed: {total_indexed}")
        sys.stdout.flush()

    def _load_pmb_entity_optimized(self, pmb_id: str) -> Optional[ET.Element]:
        """Load a specific PMB entity with optimized caching strategy"""
        # Check cache first
        if pmb_id in self.pmb_cache:
            print(f"📋 Cache hit for {pmb_id}")
            sys.stdout.flush()
            return self.pmb_cache[pmb_id]
        
        # Check if we know this entity type from our index
        entity_type = self.pmb_index.get(pmb_id)
        if not entity_type:
            print(f"❓ {pmb_id} not found in PMB index - will try API")
            sys.stdout.flush()
            return None
            
        # Load specific entity from file using targeted parsing
        return self._load_single_entity_from_file(pmb_id, entity_type)
    
    def _load_single_entity_from_file(self, pmb_id: str, entity_type: str) -> Optional[ET.Element]:
        """Load a single entity from PMB file using full tree parsing"""
        filename_map = {
            "person": "listperson.xml",
            "place": "listplace.xml", 
            "org": "listorg.xml",
            "work": "listbibl.xml",
            "event": "listevent.xml"
        }
        
        filename = filename_map.get(entity_type)
        if not filename:
            return None
            
        filepath = self.pmb_lists_dir / filename
        if not filepath.exists():
            return None
            
        try:
            print(f"🔍 Searching for {pmb_id} in {filename}...")
            sys.stdout.flush()
            
            # Load the entire tree to preserve element structure
            tree = ET.parse(filepath)
            root = tree.getroot()
            
            # Find the specific entity using xpath
            if entity_type == "work":
                entity = root.find(f".//tei:bibl[@xml:id='{pmb_id}']", self.ns)
            else:
                entity = root.find(f".//tei:{entity_type}[@xml:id='{pmb_id}']", self.ns)
            
            if entity is not None:
                # Create a deep copy to avoid reference issues
                entity_copy = copy.deepcopy(entity)
                self._add_to_cache(pmb_id, entity_copy)
                print(f"✅ Found and cached {pmb_id}")
                sys.stdout.flush()
                return entity_copy
            
            print(f"❌ {pmb_id} not found in {filename}")
            sys.stdout.flush()
            return None
            
        except Exception as e:
            print(f"❌ Error loading {pmb_id} from {filename}: {e}")
            sys.stdout.flush()
            return None
    
    def _add_to_cache(self, pmb_id: str, entity: ET.Element) -> None:
        """Add entity to cache with size management"""
        # Simple LRU: remove oldest entries if cache is full
        if len(self.pmb_cache) >= self.max_cache_size:
            # Remove first (oldest) entry
            oldest_key = next(iter(self.pmb_cache))
            del self.pmb_cache[oldest_key]
        
        self.pmb_cache[pmb_id] = entity

    def _clone_element(self, elem: ET.Element) -> ET.Element:
        """Create a deep clone of an element with all attributes, text, and children"""
        # Create new element with same tag
        new_elem = ET.Element(elem.tag, elem.attrib)
        new_elem.text = elem.text
        new_elem.tail = elem.tail
        
        # Recursively clone children
        for child in elem:
            new_elem.append(self._clone_element(child))
        
        return new_elem


    def _is_in_back_section(self, elem: ET.Element, root: ET.Element) -> bool:
        """Check if element is in the back section by checking path"""
        # Simple approach: convert element to string and check if it's in back section
        back_elements = root.findall(".//tei:back", self.ns)
        for back in back_elements:
            for descendant in back.iter():
                if descendant is elem:
                    return True
        return False

    def _extract_refs(self, root: ET.Element) -> Dict[str, Dict[str, Set[str]]]:
        """Extract all references from the TEI document (Step 1 of XSLT 1)
        Returns: Dict with entity types, each containing 'in_text', 'in_commentary', and 'implied' sets
        """
        refs = {
            "person": {"in_text": set(), "in_commentary": set(), "implied": set()},
            "bibl": {"in_text": set(), "in_commentary": set(), "implied": set()},
            "place": {"in_text": set(), "in_commentary": set(), "implied": set()},
            "org": {"in_text": set(), "in_commentary": set(), "implied": set()},
            "event": {"in_text": set(), "in_commentary": set(), "implied": set()}
        }

        # Check if document uses '#' format
        has_hash = any("#" in ref for ref in self._get_all_refs(root))

        # Helper function to check if element is in commentary
        def is_in_commentary(elem):
            """Check if element is inside a note[@type='commentary']"""
            current = elem
            while current is not None:
                if current.tag == f"{{{self.tei_ns}}}note" and current.get("type") == "commentary":
                    return True
                current = current.getparent() if hasattr(current, 'getparent') else None
            return False

        # Extract person references
        person_elements = root.findall(".//tei:*[@type='person']", self.ns) + \
                         root.findall(".//tei:persName", self.ns) + \
                         root.findall(".//tei:author", self.ns)

        for elem in person_elements:
            if not self._is_in_back_section(elem, root):
                ref = elem.get("ref") or elem.get("key")
                if ref:
                    in_commentary = is_in_commentary(elem)
                    is_implied = elem.get("subtype") == "implied"

                    # Collect references into appropriate sets
                    if in_commentary:
                        # References in commentary
                        ref_set = refs["person"]["in_commentary"]
                    elif is_implied:
                        # Implied references (only if not in commentary)
                        ref_set = refs["person"]["implied"]
                    else:
                        # Direct references in text (not implied, not in commentary)
                        ref_set = refs["person"]["in_text"]

                    if has_hash:
                        ref_set.update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())
                    else:
                        ref_set.update(token.strip() for token in ref.split() if token.strip())
        
        # Extract handShift references (always in text, not commentary)
        handshift_elements = root.findall(".//tei:handShift", self.ns)
        for elem in handshift_elements:
            scribe = elem.get("scribe")
            if scribe:
                refs["person"]["in_text"].add(scribe.replace("#", "").strip())

        # Extract handNote references (always in text, not commentary)
        handnote_elements = root.findall(".//tei:handNote", self.ns)
        for elem in handnote_elements:
            corresp = elem.get("corresp")
            if corresp and corresp != "schreibkraft":
                refs["person"]["in_text"].add(corresp.replace("#", "").strip())

        # Extract work/bibl references
        work_elements = root.findall(".//tei:rs[@type='work']", self.ns)
        for elem in work_elements:
            if not self._is_in_back_section(elem, root):
                ref = elem.get("ref") or elem.get("key")
                if ref and "#" in ref:
                    in_commentary = is_in_commentary(elem)
                    is_implied = elem.get("subtype") == "implied"

                    # Collect references into appropriate sets
                    if in_commentary:
                        ref_set = refs["bibl"]["in_commentary"]
                    elif is_implied:
                        ref_set = refs["bibl"]["implied"]
                    else:
                        ref_set = refs["bibl"]["in_text"]

                    ref_set.update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())

        # Extract title references from biblStruct (not in commentary)
        title_elements = root.findall(".//tei:biblStruct//tei:title[@ref]", self.ns)
        for elem in title_elements:
            ref = elem.get("ref")
            if ref:
                refs["bibl"]["in_text"].update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())

        # Extract title references from teiHeader (not in commentary)
        header_titles = root.findall(".//tei:teiHeader//tei:title[@ref]", self.ns)
        for elem in header_titles:
            ref = elem.get("ref")
            if ref:
                refs["bibl"]["in_text"].add(ref.replace("#", "").strip())

        # Extract place references
        place_elements = root.findall(".//tei:*[@type='place']", self.ns) + \
                        root.findall(".//tei:placeName", self.ns)

        for elem in place_elements:
            if not self._is_in_back_section(elem, root):
                ref = elem.get("ref") or elem.get("key")
                if ref:
                    in_commentary = is_in_commentary(elem)
                    is_implied = elem.get("subtype") == "implied"

                    # Collect references into appropriate sets
                    if in_commentary:
                        ref_set = refs["place"]["in_commentary"]
                    elif is_implied:
                        ref_set = refs["place"]["implied"]
                    else:
                        ref_set = refs["place"]["in_text"]

                    if has_hash:
                        ref_set.update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())
                    else:
                        ref_set.update(token.strip() for token in ref.split() if token.strip())

        # Extract org references
        org_elements = root.findall(".//tei:*[@type='org']", self.ns) + \
                      root.findall(".//tei:orgName", self.ns)

        for elem in org_elements:
            if not self._is_in_back_section(elem, root):
                ref = elem.get("ref") or elem.get("key")
                if ref:
                    in_commentary = is_in_commentary(elem)
                    is_implied = elem.get("subtype") == "implied"

                    if is_implied and not in_commentary:
                        ref_set = refs["org"]["implied"]
                    elif in_commentary:
                        ref_set = refs["org"]["in_commentary"]
                    else:
                        ref_set = refs["org"]["in_text"]

                    if has_hash:
                        ref_set.update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())
                    else:
                        ref_set.update(token.strip() for token in ref.split() if token.strip())

        # Extract event references
        event_elements = root.findall(".//tei:*[@type='event']", self.ns) + \
                        root.findall(".//tei:eventName", self.ns)

        for elem in event_elements:
            if not self._is_in_back_section(elem, root):
                ref = elem.get("ref") or elem.get("key")
                if ref:
                    in_commentary = is_in_commentary(elem)
                    is_implied = elem.get("subtype") == "implied"

                    if is_implied and not in_commentary:
                        ref_set = refs["event"]["implied"]
                    elif in_commentary:
                        ref_set = refs["event"]["in_commentary"]
                    else:
                        ref_set = refs["event"]["in_text"]

                    if has_hash:
                        ref_set.update(token.replace("#", "").strip() for token in ref.split("#") if token.strip())
                    else:
                        ref_set.update(token.strip() for token in ref.split() if token.strip())

        return refs

    def _get_all_refs(self, root: ET.Element) -> list:
        """Helper to get all ref attributes for hash detection"""
        refs = []
        for elem in root.findall(".//*[@ref]", self.ns):
            refs.append(elem.get("ref"))
        for elem in root.findall(".//*[@key]", self.ns):
            refs.append(elem.get("key"))
        return refs

    def _create_back_element(self, root: ET.Element, refs: Dict[str, Dict[str, Set[str]]]) -> ET.Element:
        """Create back element with placeholder lists (Step 1)"""
        # Find or create text element
        text_elem = root.find(".//tei:text", self.ns)
        if text_elem is None:
            return root

        # Remove existing back element
        existing_back = text_elem.find("tei:back", self.ns)
        if existing_back is not None:
            text_elem.remove(existing_back)

        # Create new back element
        back_elem = ET.SubElement(text_elem, f"{{{self.tei_ns}}}back")

        # Create list elements with empty placeholders
        for list_type, ref_dict in refs.items():
            in_text_refs = ref_dict.get("in_text", set())
            in_commentary_refs = ref_dict.get("in_commentary", set())
            implied_refs = ref_dict.get("implied", set())
            all_refs = in_text_refs | in_commentary_refs | implied_refs

            if all_refs:  # Only create if there are references
                if list_type == "person":
                    list_elem = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listPerson")
                    # First add refs from text (no ana attribute)
                    for ref_id in sorted(in_text_refs):
                        if ref_id.strip():
                            person_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}person")
                            person_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                    # Then add refs only in commentary (with ana="comment")
                    for ref_id in sorted(in_commentary_refs - in_text_refs):
                        if ref_id.strip():
                            person_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}person")
                            person_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            person_elem.set("ana", "comment")
                    # Then add refs only implied (with ana="implied", but not if also in in_text)
                    for ref_id in sorted(implied_refs - in_text_refs - in_commentary_refs):
                        if ref_id.strip():
                            person_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}person")
                            person_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            person_elem.set("ana", "implied")

                elif list_type == "bibl":
                    list_elem = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listBibl")
                    # First add refs from text (no ana attribute)
                    for ref_id in sorted(in_text_refs):
                        if ref_id.strip():
                            bibl_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}bibl")
                            bibl_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                    # Then add refs only in commentary (with ana="comment")
                    for ref_id in sorted(in_commentary_refs - in_text_refs):
                        if ref_id.strip():
                            bibl_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}bibl")
                            bibl_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            bibl_elem.set("ana", "comment")
                    # Then add refs only implied (with ana="implied", but not if also in in_text)
                    for ref_id in sorted(implied_refs - in_text_refs - in_commentary_refs):
                        if ref_id.strip():
                            bibl_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}bibl")
                            bibl_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            bibl_elem.set("ana", "implied")

                elif list_type == "place":
                    list_elem = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listPlace")
                    # First add refs from text (no ana attribute)
                    for ref_id in sorted(in_text_refs):
                        if ref_id.strip():
                            place_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}place")
                            place_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                    # Then add refs only in commentary (with ana="comment")
                    for ref_id in sorted(in_commentary_refs - in_text_refs):
                        if ref_id.strip():
                            place_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}place")
                            place_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            place_elem.set("ana", "comment")
                    # Then add refs only implied (with ana="implied", but not if also in in_text)
                    for ref_id in sorted(implied_refs - in_text_refs - in_commentary_refs):
                        if ref_id.strip():
                            place_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}place")
                            place_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            place_elem.set("ana", "implied")

                elif list_type == "org":
                    list_elem = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listOrg")
                    # First add refs from text (no ana attribute)
                    for ref_id in sorted(in_text_refs):
                        if ref_id.strip():
                            org_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}org")
                            org_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                    # Then add refs only in commentary (with ana="comment")
                    for ref_id in sorted(in_commentary_refs - in_text_refs):
                        if ref_id.strip():
                            org_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}org")
                            org_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            org_elem.set("ana", "comment")
                    # Then add refs only implied (with ana="implied", but not if also in in_text)
                    for ref_id in sorted(implied_refs - in_text_refs - in_commentary_refs):
                        if ref_id.strip():
                            org_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}org")
                            org_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            org_elem.set("ana", "implied")

                elif list_type == "event":
                    list_elem = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listEvent")
                    # First add refs from text (no ana attribute)
                    for ref_id in sorted(in_text_refs):
                        if ref_id.strip():
                            event_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}event")
                            event_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                    # Then add refs only in commentary (with ana="comment")
                    for ref_id in sorted(in_commentary_refs - in_text_refs):
                        if ref_id.strip():
                            event_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}event")
                            event_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            event_elem.set("ana", "comment")
                    # Then add refs only implied (with ana="implied", but not if also in in_text)
                    for ref_id in sorted(implied_refs - in_text_refs - in_commentary_refs):
                        if ref_id.strip():
                            event_elem = ET.SubElement(list_elem, f"{{{self.tei_ns}}}event")
                            event_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref_id.replace("#", ""))
                            event_elem.set("ana", "implied")

        return root

    def _populate_from_pmb(self, root: ET.Element) -> ET.Element:
        """Populate placeholders with PMB data (Step 2)"""
        back_elem = root.find(".//tei:back", self.ns)
        if back_elem is None:
            return root
        
        # Process each list type
        for list_type in ["Person", "Bibl", "Place", "Org", "Event"]:
            list_elem = back_elem.find(f"tei:list{list_type}", self.ns)
            if list_elem is not None:
                self._populate_list(list_elem, list_type.lower())
        
        return root

    def _populate_list(self, list_elem: ET.Element, entity_type: str):
        """Populate a specific list with PMB data"""
        for entity in list_elem.findall(f"tei:{entity_type}", self.ns):
            xml_id = entity.get("{http://www.w3.org/XML/1998/namespace}id")
            if not xml_id:
                continue

            # Save ana attribute if it exists
            ana_attribute = entity.get("ana")

            # Clean the ID to match PMB format
            original_id = xml_id
            clean_id = re.sub(r'^.*__', 'pmb', xml_id)
            if not clean_id.startswith('pmb'):
                clean_id = f'pmb{clean_id}'

            print(f"🔍 Looking up: {original_id} -> {clean_id} (entity_type: {entity_type})")

            # Special case for Arthur Schnitzler
            if clean_id == 'pmb2121' and entity_type == 'person':
                self._add_schnitzler_data(entity, ana_attribute)
                continue

            # Try to find with lazy loading
            self.stats["pmb_lookups"] += 1
            print(f"🔍 Looking up: {original_id} -> {clean_id} (entity_type: {entity_type})")
            sys.stdout.flush()

            pmb_entity = self._load_pmb_entity_optimized(clean_id)

            if pmb_entity is not None:
                # Copy data from PMB
                self.stats["pmb_found"] += 1
                print(f"✅ Found {clean_id} in local PMB data")
                sys.stdout.flush()
                entity.clear()
                entity.set("{http://www.w3.org/XML/1998/namespace}id", clean_id)
                # Restore ana attribute if it existed
                if ana_attribute:
                    entity.set("ana", ana_attribute)
                copied_children = 0
                # Copy children directly from PMB entity
                for child in pmb_entity:
                    # Create a deep copy to avoid reference issues
                    child_copy = copy.deepcopy(child)
                    entity.append(child_copy)
                    copied_children += 1
                print(f"✅ Copied {copied_children} children to entity")
                sys.stdout.flush()
            else:
                # Entity not found in local PMB data
                self.stats["pmb_not_found"] += 1
                print(f"❌ {clean_id} NOT FOUND in local PMB data - making API call")
                sys.stdout.flush()

                # Try to fetch from PMB API
                self._fetch_from_api(entity, clean_id, entity_type, ana_attribute)

    def _add_schnitzler_data(self, person_elem: ET.Element, ana_attribute: Optional[str] = None):
        """Add hardcoded Arthur Schnitzler data"""
        person_elem.clear()
        person_elem.set("{http://www.w3.org/XML/1998/namespace}id", "pmb2121")
        # Restore ana attribute if it existed
        if ana_attribute:
            person_elem.set("ana", ana_attribute)
        
        # Add persName
        persname = ET.SubElement(person_elem, f"{{{self.tei_ns}}}persName")
        surname = ET.SubElement(persname, f"{{{self.tei_ns}}}surname")
        surname.text = "Schnitzler"
        forename = ET.SubElement(persname, f"{{{self.tei_ns}}}forename")
        forename.text = "Arthur"
        
        # Add birth
        birth = ET.SubElement(person_elem, f"{{{self.tei_ns}}}birth")
        birth_date = ET.SubElement(birth, f"{{{self.tei_ns}}}date")
        birth_date.set("when", "1862-05-15")
        birth_date.text = "15. 5. 1862"
        settlement = ET.SubElement(birth, f"{{{self.tei_ns}}}settlement")
        settlement.set("key", "pmb50")
        placename = ET.SubElement(settlement, f"{{{self.tei_ns}}}placeName")
        placename.set("type", "pref")
        placename.text = "Wien"
        location = ET.SubElement(settlement, f"{{{self.tei_ns}}}location")
        geo = ET.SubElement(location, f"{{{self.tei_ns}}}geo")
        geo.text = "48,208333 16,373056"
        
        # Add death
        death = ET.SubElement(person_elem, f"{{{self.tei_ns}}}death")
        death_date = ET.SubElement(death, f"{{{self.tei_ns}}}date")
        death_date.set("when", "1931-10-21")
        death_date.text = "21. 10. 1931"
        settlement2 = ET.SubElement(death, f"{{{self.tei_ns}}}settlement")
        settlement2.set("key", "pmb50")
        placename2 = ET.SubElement(settlement2, f"{{{self.tei_ns}}}placeName")
        placename2.set("type", "pref")
        placename2.text = "Wien"
        location2 = ET.SubElement(settlement2, f"{{{self.tei_ns}}}location")
        geo2 = ET.SubElement(location2, f"{{{self.tei_ns}}}geo")
        geo2.text = "48,208333 16,373056"
        
        # Add sex
        sex = ET.SubElement(person_elem, f"{{{self.tei_ns}}}sex")
        sex.set("value", "male")
        
        # Add occupations
        occ1 = ET.SubElement(person_elem, f"{{{self.tei_ns}}}occupation")
        occ1.set("ref", "pmb90")
        occ1.text = "Schriftsteller/Schriftstellerin"
        occ2 = ET.SubElement(person_elem, f"{{{self.tei_ns}}}occupation")
        occ2.set("ref", "pmb97")
        occ2.text = "Mediziner/Medizinerin"
        
        # Add GND
        idno = ET.SubElement(person_elem, f"{{{self.tei_ns}}}idno")
        idno.set("type", "gnd")
        idno.text = "https://d-nb.info/gnd/118609807/"

    def _fetch_from_api(self, entity: ET.Element, pmb_id: str, entity_type: str, ana_attribute: Optional[str] = None):
        """Fetch entity data from PMB API"""
        number = pmb_id.replace('pmb', '')
        url = f"https://pmb.acdh.oeaw.ac.at/apis/tei/{entity_type}/{number}"

        self.stats["api_calls"] += 1
        print(f"🌐 Making API call for {pmb_id}: {url}")

        try:
            response = requests.get(url, timeout=5)  # Reduced timeout
            if response.status_code == 200:
                self.stats["api_success"] += 1
                print(f"✅ API success for {pmb_id}")
            else:
                self.stats["api_failures"] += 1
                print(f"❌ API failed for {pmb_id}: HTTP {response.status_code}")

            if response.status_code == 200:
                # Parse the response and add to entity
                api_root = ET.fromstring(response.content)
                entity.clear()
                entity.set("{http://www.w3.org/XML/1998/namespace}id", pmb_id)
                # Restore ana attribute if it existed
                if ana_attribute:
                    entity.set("ana", ana_attribute)
                
                # Copy relevant children based on entity type
                if entity_type == "person":
                    for child in api_root.findall(".//*"):
                        if child.tag.endswith(('persName', 'birth', 'death', 'sex', 'occupation', 'idno')):
                            if not (child.tag.endswith('persName') and child.get('type') == 'loschen'):
                                entity.append(child)
                elif entity_type == "bibl":
                    for child in api_root.findall(".//*"):
                        if child.tag.endswith(('title', 'author', 'date', 'note', 'idno')):
                            if not (child.tag.endswith('title') and child.get('type') == 'loschen'):
                                entity.append(child)
                else:
                    # For place, org, event - copy all children
                    for child in api_root:
                        entity.append(child)
            else:
                # Add error element
                error = ET.SubElement(entity, "error")
                error.set("type", entity_type)
                error.text = number
        except Exception as e:
            # Add error element
            error = ET.SubElement(entity, "error")
            error.set("type", entity_type)
            error.text = f"{number} - {str(e)}"

    def _add_persons_from_bibliography(self, root: ET.Element) -> ET.Element:
        """Add persons from bibliography authors to listPerson (Step 3 - brief_backElement-3.xsl)"""
        back_elem = root.find(".//tei:back", self.ns)
        if back_elem is None:
            return root

        listbibl = back_elem.find("tei:listBibl", self.ns)
        if listbibl is None:
            return root

        # Check if listBibl has bibl elements with author elements
        bibl_authors = listbibl.findall(".//tei:bibl/tei:author[@ref]", self.ns)
        if not bibl_authors:
            print("No author elements with @ref found in listBibl")
            return root

        # Get or create listPerson
        listperson = back_elem.find("tei:listPerson", self.ns)
        if listperson is None:
            listperson = ET.SubElement(back_elem, f"{{{self.tei_ns}}}listPerson")

        # Get existing person IDs (excluding pmb2121)
        existing_person_ids = set()
        for person in listperson.findall("tei:person", self.ns):
            xml_id = person.get("{http://www.w3.org/XML/1998/namespace}id")
            if xml_id and xml_id != "pmb2121":
                existing_person_ids.add(xml_id)

        # Get unique author refs from bibliography
        author_refs = set()
        for author in bibl_authors:
            ref = author.get("ref")
            if ref and ref != "pmb2121":
                # Clean the reference
                clean_ref = ref.replace("#", "")
                if not clean_ref.startswith("pmb"):
                    clean_ref = f"pmb{clean_ref}"
                author_refs.add(clean_ref)

        print(f"Found {len(author_refs)} unique author references")
        print(f"Existing persons: {len(existing_person_ids)}")

        # Add missing persons
        added_count = 0
        for ref in author_refs:
            if ref not in existing_person_ids:
                print(f"Adding person: {ref}")

                # Try to load from local PMB data first
                pmb_person = self._load_pmb_entity_optimized(ref)

                if pmb_person is not None:
                    # Clone the PMB person and add to listPerson
                    person_copy = copy.deepcopy(pmb_person)
                    person_copy.set("{http://www.w3.org/XML/1998/namespace}id", ref)
                    listperson.append(person_copy)
                    added_count += 1
                    print(f"✅ Added {ref} from local PMB data")
                else:
                    # Try to fetch from API
                    print(f"🌐 Fetching {ref} from PMB API...")
                    person_elem = ET.SubElement(listperson, f"{{{self.tei_ns}}}person")
                    person_elem.set("{http://www.w3.org/XML/1998/namespace}id", ref)
                    self._fetch_from_api(person_elem, ref, "person")
                    added_count += 1

        print(f"Added {added_count} persons to listPerson")
        return root

    def _normalize_data(self, root: ET.Element) -> ET.Element:
        """Apply normalizations (Step 4)"""
        # Convert when-iso to when attributes
        for elem in root.findall(".//*[@when-iso]"):
            when_iso = elem.get("when-iso")
            elem.set("when", self._normalize_date(when_iso))
            del elem.attrib["when-iso"]
        
        # Convert notAfter-iso to notAfter
        for elem in root.findall(".//*[@notAfter-iso]"):
            notafter_iso = elem.get("notAfter-iso")
            elem.set("notAfter", self._normalize_date(notafter_iso))
            del elem.attrib["notAfter-iso"]
        
        # Convert notBefore-iso to notBefore
        for elem in root.findall(".//*[@notBefore-iso]"):
            notbefore_iso = elem.get("notBefore-iso")
            elem.set("notBefore", self._normalize_date(notbefore_iso))
            del elem.attrib["notBefore-iso"]
        
        # Convert from-iso to from
        for elem in root.findall(".//*[@from-iso]"):
            from_iso = elem.get("from-iso")
            elem.set("from", from_iso)
            del elem.attrib["from-iso"]
        
        # Convert to-iso to to
        for elem in root.findall(".//*[@to-iso]"):
            to_iso = elem.get("to-iso")
            elem.set("to", to_iso)
            del elem.attrib["to-iso"]
        
        # Convert key to ref attributes
        for elem in root.findall(".//*[@key]"):
            key = elem.get("key")
            if not key.startswith('pmb'):
                if key.startswith('pmbperson__'):
                    key = f'pmb{key[11:]}'  # Remove 'pmbperson__' prefix
                elif key.startswith('person__'):
                    key = f'pmb{key[8:]}'   # Remove 'person__' prefix
                else:
                    key = f'pmb{key}'
            elem.set("ref", key)
            del elem.attrib["key"]
        
        # Normalize XML IDs in back section
        back_elem = root.find(".//tei:back", self.ns)
        if back_elem is not None:
            for entity_type in ["person", "bibl", "place", "org", "event"]:
                for entity in back_elem.findall(f".//tei:{entity_type}[@xml:id]", self.ns):
                    xml_id = entity.get("{http://www.w3.org/XML/1998/namespace}id")
                    if xml_id and "__" in xml_id:
                        new_id = re.sub(r'^.*__', 'pmb', xml_id)
                        entity.set("{http://www.w3.org/XML/1998/namespace}id", new_id)
        
        # Handle special URL conversions and cleanups
        self._normalize_urls(root)
        self._cleanup_duplicates(root)
        
        return root

    def _normalize_date(self, date_str: str) -> str:
        """Normalize date format by padding year"""
        if not date_str or '-' not in date_str:
            return date_str
        
        year = date_str.split('-')[0]
        if len(year) == 4:
            return date_str
        elif len(year) == 3:
            return f"0{date_str}"
        elif len(year) == 2:
            return f"00{date_str}"
        elif len(year) == 1:
            return f"000{date_str}"
        
        return date_str

    def _normalize_urls(self, root: ET.Element):
        """Convert various URL elements to proper idno elements"""
        back_elem = root.find(".//tei:back", self.ns)
        if back_elem is None:
            return
        
        # Convert note[@type='IDNO'] to idno elements
        for note in back_elem.findall(".//tei:note[@type='IDNO']", self.ns):
            # Find parent and replace
            for parent in back_elem.iter():
                if note in parent:
                    idno = ET.Element(f"{{{self.tei_ns}}}idno")
                    idno.set("type", "URL")
                    idno.set("subtype", self._get_url_subtype(note.text or ""))
                    idno.text = note.text
                    parent.remove(note)
                    parent.append(idno)
                    break

    def _get_url_subtype(self, url: str) -> str:
        """Determine URL subtype based on domain"""
        if "wikipedia" in url:
            return "wikipedia"
        elif "wikidata" in url:
            return "wikidata"
        elif "geonames" in url:
            return "geonames"
        elif url.startswith("https://www."):
            return url.split("https://www.")[1].split(".")[0]
        elif url.startswith("http://www."):
            return url.split("http://www.")[1].split(".")[0]
        elif url.startswith("https://"):
            return url.split("https://")[1].split(".")[0]
        elif url.startswith("http://"):
            return url.split("http://")[1].split(".")[0]
        else:
            return url.split(".")[0] if "." in url else "unknown"

    def _cleanup_duplicates(self, root: ET.Element):
        """Remove duplicate placeName elements and empty lists"""
        back_elem = root.find(".//tei:back", self.ns)
        if back_elem is None:
            return
        
        # Remove listBibl elements with bibl[@type='collections'] and note[@type='collections']
        elements_to_remove = []
        
        # Find all listBibl elements that contain bibl[@type='collections']
        for listbibl in back_elem.findall(".//tei:listBibl", self.ns):
            bibls_with_collections = listbibl.findall("tei:bibl[@type='collections']", self.ns)
            if bibls_with_collections:
                elements_to_remove.append(listbibl)
        
        # Find all note[@type='collections'] elements
        for note in back_elem.findall(".//tei:note[@type='collections']", self.ns):
            elements_to_remove.append(note)
        
        # Remove found elements
        for element in elements_to_remove:
            parent = None
            for potential_parent in back_elem.iter():
                if element in potential_parent:
                    parent = potential_parent
                    break
            if parent is not None:
                parent.remove(element)
        
        # Remove empty lists
        for list_elem in back_elem.findall("tei:list*", self.ns):
            if len(list_elem) == 0:
                back_elem.remove(list_elem)

    def process_file(self, input_file: str, output_file: Optional[str] = None) -> str:
        """Process a TEI XML file through all three steps"""
        try:
            print(f"🔄 Starting processing of {Path(input_file).name}")
            sys.stdout.flush()
            
            # Read original file to preserve processing instructions
            print(f"📖 Reading file: {Path(input_file).name}")
            sys.stdout.flush()
            with open(input_file, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            print(f"📝 File size: {len(original_content):,} characters")
            sys.stdout.flush()
            
            # Extract processing instructions from original file
            print(f"🔍 Extracting processing instructions...")
            processing_instructions = []
            lines = original_content.split('\n')
            for line in lines:
                line = line.strip()
                if line.startswith('<?') and line.endswith('?>') and not line.startswith('<?xml '):
                    processing_instructions.append(line)
                elif line.startswith('<') and not line.startswith('<?'):
                    break  # Stop at first actual XML element
            
            print(f"⚙️ Parsing XML...")
            sys.stdout.flush()
            tree = ET.parse(input_file)
            root = tree.getroot()
            print(f"✅ XML parsed successfully")
            sys.stdout.flush()
            
            # Step 1: Extract references and create back element
            print(f"🔍 Step 1: Extracting references...")
            sys.stdout.flush()
            refs = self._extract_refs(root)
            print(f"📊 Found references: {sum(len(v) for v in refs.values())} total")
            sys.stdout.flush()
            root = self._create_back_element(root, refs)
            print(f"✅ Step 1 completed")
            sys.stdout.flush()
            
            # Step 2: Populate with PMB data
            print(f"🌐 Step 2: Populating from PMB data...")
            sys.stdout.flush()
            root = self._populate_from_pmb(root)
            print(f"✅ Step 2 completed")
            sys.stdout.flush()

            # Step 3: Add persons from bibliography authors
            print(f"👤 Step 3: Adding persons from bibliography authors...")
            sys.stdout.flush()
            root = self._add_persons_from_bibliography(root)
            print(f"✅ Step 3 completed")
            sys.stdout.flush()

            # Step 4: Normalize data
            print(f"⚙️ Step 4: Normalizing data...")
            sys.stdout.flush()
            root = self._normalize_data(root)
            print(f"✅ Step 4 completed")
            sys.stdout.flush()
            
            # Write output
            if output_file is None:
                output_file = input_file
            
            # Write with preserved processing instructions, preserving element structure
            tree.write(output_file, encoding="utf-8", xml_declaration=True, short_empty_elements=False)
            
            # Print statistics
            print(f"\n📊 PMB Processing Statistics:")
            print(f"   Total lookups: {self.stats['pmb_lookups']}")
            print(f"   Found locally: {self.stats['pmb_found']}")
            print(f"   Not found locally: {self.stats['pmb_not_found']}")
            print(f"   API calls made: {self.stats['api_calls']}")
            print(f"   API successes: {self.stats['api_success']}")
            print(f"   API failures: {self.stats['api_failures']}")
            if self.stats['pmb_lookups'] > 0:
                print(f"   Hit rate: {100 * self.stats['pmb_found'] / self.stats['pmb_lookups']:.1f}%")
            
            # Re-read the written file and insert processing instructions
            with open(output_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Insert processing instructions after XML declaration
            lines = content.split('\n')
            if lines[0].startswith('<?xml '):
                # Insert processing instructions after XML declaration
                new_lines = [lines[0]] + processing_instructions + lines[1:]
                content = '\n'.join(new_lines)
            else:
                # Insert at beginning if no XML declaration found
                content = '\n'.join(processing_instructions + lines)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            return output_file
            
        except Exception as e:
            print(f"Error processing {input_file}: {e}")
            return ""


def main():
    print(f"🚀 Starting add-back-element-from-pmb.py")
    sys.stdout.flush()
    
    if len(sys.argv) < 2:
        print("Usage: python add-back-element-from-pmb.py <input_file> [output_file]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    print(f"📝 Processing file: {input_file}")
    sys.stdout.flush()
    
    print(f"🔧 Creating PMBProcessor instance...")
    sys.stdout.flush()
    
    processor = PMBProcessor()
    
    print(f"▶️ Starting file processing...")
    sys.stdout.flush()
    
    result = processor.process_file(input_file, output_file)
    
    print(f"✅ Script completed: {result}")
    sys.stdout.flush()
    
    if result:
        print(f"Successfully processed: {result}")
    else:
        print("Processing failed")
        sys.exit(1)


if __name__ == "__main__":
    main()