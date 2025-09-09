#!/usr/bin/env python3
import os
import sys
from lxml import etree
import glob

def validate_file(file_path):
    """Validate a single XML file for problematic back elements."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse XML with namespaces
        parser = etree.XMLParser(recover=True)
        tree = etree.fromstring(content.encode('utf-8'), parser)
        
        # Define TEI namespace
        namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
        
        issues = []
        
        # Check for empty birth elements: //tei:TEI/tei:text/tei:back/tei:listPerson//tei:birth[not(child::*)]
        empty_births = tree.xpath('//tei:TEI/tei:text/tei:back/tei:listPerson//tei:birth[not(child::*)]', namespaces=namespaces)
        if empty_births:
            issues.append(f"Found {len(empty_births)} empty birth element(s)")
        
        # Check for empty idno elements: //tei:TEI/tei:text/tei:back/descendant::tei:idno[not(@*) and .='']
        empty_idnos = tree.xpath("//tei:TEI/tei:text/tei:back/descendant::tei:idno[not(@*) and .='']", namespaces=namespaces)
        if empty_idnos:
            issues.append(f"Found {len(empty_idnos)} empty idno element(s) without attributes")
        
        return issues
        
    except Exception as e:
        return [f"XML parsing error: {str(e)}"]

def main():
    """Main validation function."""
    editions_path = "./editions"
    if not os.path.exists(editions_path):
        print(f"ERROR: {editions_path} directory not found")
        sys.exit(1)
    
    print(f"🔍 Validating back elements in {editions_path}...")
    
    # Find all XML files
    xml_files = glob.glob(os.path.join(editions_path, "**/*.xml"), recursive=True)
    print(f"Found {len(xml_files)} XML files to validate")
    
    problematic_files = []
    total_issues = 0
    
    for i, xml_file in enumerate(xml_files, 1):
        if i % 100 == 0:
            print(f"Progress: {i}/{len(xml_files)} files checked")
        
        issues = validate_file(xml_file)
        if issues:
            problematic_files.append((xml_file, issues))
            total_issues += len(issues)
    
    # Results
    if problematic_files:
        print(f"\n❌ Validation failed: {len(problematic_files)} files with {total_issues} issues")
        print("\nProblematic files:")
        
        # Write problematic files to output for workflow
        with open('problematic_files.txt', 'w') as f:
            for file_path, issues in problematic_files:
                rel_path = os.path.relpath(file_path, '.')
                print(f"  {rel_path}: {', '.join(issues)}")
                f.write(f"{rel_path}\n")
        
        print(f"\n📝 List of problematic files saved to problematic_files.txt")
        return len(problematic_files)
    else:
        print(f"\n✅ Validation passed: All {len(xml_files)} files are valid")
        return 0

if __name__ == "__main__":
    sys.exit(main())
