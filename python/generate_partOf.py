#!/usr/bin/env python3
"""
Standalone script to generate partOf.xml from PMB relations data.

This script:
1. Downloads relations.csv from PMB
2. Extracts "gehört zu" and "enthält" relationships
3. Transforms the data using XSLT to create the final partOf.xml

Usage:
    python3 generate_partOf.py [--output-dir OUTPUT_DIR] [--saxon-jar SAXON_JAR]

Requirements:
    - requests library (pip install requests)
    - Saxon XSLT processor JAR file
    - Java runtime
"""

import os
import sys
import argparse
import re
import csv
import xml.etree.ElementTree as ET
from xml.dom import minidom
import requests
from io import StringIO
import subprocess

# Default URLs and paths
DEFAULT_CSV_URL = 'https://pmb.acdh.oeaw.ac.at/media/relations.csv'
DEFAULT_SAXON_JAR = './saxon/saxon-he-9.9.1-7.jar'
DEFAULT_OUTPUT_DIR = './indices/utils'

def remove_angle_brackets(content):
    """Remove content in angle brackets from text."""
    return re.sub(r'<.*?>', '', content)

def prettify_xml(elem):
    """Format XML with nice indentation."""
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="    ")

def load_csv_from_url(url):
    """Download CSV from URL and return as StringIO object."""
    print(f"Downloading relations data from {url}...")
    response = requests.get(url)
    response.raise_for_status()
    print("✓ Download successful.")
    return StringIO(response.text)

def extract_part_of_and_contains(csv_url, output_xml):
    """Extract 'gehört zu' and 'enthält' relationships and save as XML."""
    print("Extracting 'gehört zu' and 'enthält' relationships...")
    root = ET.Element('root')
    csv_data = load_csv_from_url(csv_url)
    reader = csv.reader(csv_data)
    headers = next(reader)

    count = 0
    for row in reader:
        if len(row) > 1:
            relation_type = row[1].strip()
            if relation_type == "gehört zu" or relation_type == "enthält":
                item = ET.Element('row')
                temp_fields = {}

                for header, cell in zip(headers, row):
                    cleaned_cell = remove_angle_brackets(cell)

                    # For "enthält" relations, swap source and target
                    if relation_type == "enthält" and (header.startswith("source") or header.startswith("target")):
                        if header.startswith("source"):
                            temp_fields[header.replace("source", "target")] = cleaned_cell
                        elif header.startswith("target"):
                            temp_fields[header.replace("target", "source")] = cleaned_cell
                    else:
                        field = ET.SubElement(item, header)
                        field.text = cleaned_cell

                # Add swapped source/target fields for "enthält" relations
                if relation_type == "enthält":
                    for key, value in temp_fields.items():
                        field = ET.SubElement(item, key)
                        field.text = value

                root.append(item)
                count += 1

    # Save intermediate XML
    pretty_xml = prettify_xml(root)
    with open(output_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
    print(f"✓ Extracted {count} relationships and saved to {output_xml}")
    return output_xml

def create_xslt_file(xslt_path):
    """Create the XSLT transformation file."""
    xslt_content = '''<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Transform PMB partOf relations into clean hierarchical structure -->
    <xsl:template match="root">
        <root>
            <p>This file contains partOf-relations of places, i.e. Vienna is in Austria. It is used
                to always use the geographically most accurate position. Example: On a certain day
                Schnitzler was in Vienna and in the Café Central. As the Café Central is a more
                exact position within Vienna than "Vienna" itself, the latter information is
                redundant and can be omitted.</p>
            <list>
                <!-- Group relationships by target -->
                <xsl:for-each-group select="row" group-by="target_id">
                    <xsl:if test="current-grouping-key() != source_id">
                        <!-- Rule out self-relations, i.e. Vienna is located in Vienna -->
                        <item>
                            <xsl:attribute name="id">
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:attribute>
                            <xsl:for-each select="current-group()">
                                <contains>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="source_id"/>
                                    </xsl:attribute>
                                </contains>
                            </xsl:for-each>
                        </item>
                    </xsl:if>
                </xsl:for-each-group>
            </list>
        </root>
    </xsl:template>
</xsl:stylesheet>'''

    with open(xslt_path, 'w', encoding='utf-8') as f:
        f.write(xslt_content)
    print(f"✓ XSLT transformation file created: {xslt_path}")

def run_xslt_transformation(saxon_jar, input_xml, xslt_file, output_xml):
    """Run XSLT transformation using Saxon processor."""
    print("Running XSLT transformation...")

    if not os.path.exists(saxon_jar):
        raise FileNotFoundError(f"Saxon JAR file not found: {saxon_jar}")

    cmd = [
        'java', '-jar', saxon_jar,
        f'-s:{input_xml}',
        f'-xsl:{xslt_file}',
        f'-o:{output_xml}'
    ]

    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("✓ XSLT transformation completed successfully.")
        if result.stdout:
            print("XSLT output:", result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"✗ XSLT transformation failed: {e}")
        print(f"Error output: {e.stderr}")
        raise

def main():
    parser = argparse.ArgumentParser(
        description='Generate partOf.xml from PMB relations data',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
    python3 generate_partOf.py
    python3 generate_partOf.py --output-dir ./my-output
    python3 generate_partOf.py --saxon-jar ./saxon-he-12.5.jar --output-dir ./results
        '''
    )

    parser.add_argument('--csv-url', default=DEFAULT_CSV_URL,
                        help='URL to PMB relations.csv file')
    parser.add_argument('--output-dir', default=DEFAULT_OUTPUT_DIR,
                        help='Output directory for generated files')
    parser.add_argument('--saxon-jar', default=DEFAULT_SAXON_JAR,
                        help='Path to Saxon XSLT processor JAR file')
    parser.add_argument('--keep-temp', action='store_true',
                        help='Keep temporary files after processing')

    args = parser.parse_args()

    # Ensure output directory exists
    os.makedirs(args.output_dir, exist_ok=True)

    # File paths
    temp_xml = os.path.join(args.output_dir, 'partOf_temp.xml')
    xslt_file = os.path.join(args.output_dir, 'partOf_transform.xsl')
    final_xml = os.path.join(args.output_dir, 'partOf.xml')

    try:
        # Step 1: Extract relations and create intermediate XML
        extract_part_of_and_contains(args.csv_url, temp_xml)

        # Step 2: Create XSLT transformation file
        create_xslt_file(xslt_file)

        # Step 3: Run XSLT transformation
        run_xslt_transformation(args.saxon_jar, temp_xml, xslt_file, final_xml)

        # Cleanup temporary files unless requested to keep them
        if not args.keep_temp:
            if os.path.exists(temp_xml):
                os.remove(temp_xml)
            if os.path.exists(xslt_file):
                os.remove(xslt_file)
            print("✓ Temporary files cleaned up.")

        print(f"\n🎉 partOf.xml successfully generated: {final_xml}")
        print(f"File size: {os.path.getsize(final_xml)} bytes")

    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()