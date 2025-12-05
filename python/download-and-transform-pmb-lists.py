import requests
import re
from pathlib import Path
import time
import os
import sys
from lxml import etree as ET

# Ensure unbuffered output
sys.stdout.reconfigure(line_buffering=True)

def normalize_xml_content(content):
    # Replace patterns with "__" in xml:id and key attributes with "pmb"
    # Example: work__296327 -> pmb296327
    content = re.sub(r'(xml:id=")[^"]*__([^"]*")', r'\1pmb\2', content)
    content = re.sub(r'(key=")[^"]*__([^"]*")', r'\1pmb\2', content)
    
    return content

def is_file_fresh(filepath, max_age_hours=24):
    """Check if file exists and is younger than max_age_hours"""
    if not filepath.exists():
        return False
    
    file_age = time.time() - filepath.stat().st_mtime
    max_age_seconds = max_age_hours * 3600
    return file_age < max_age_seconds

def download_pmb_files():
    urls = [
        "https://pmb.acdh.oeaw.ac.at/media/listperson.xml",
        "https://pmb.acdh.oeaw.ac.at/media/listbibl.xml",
        "https://pmb.acdh.oeaw.ac.at/media/listevent.xml",
        "https://pmb.acdh.oeaw.ac.at/media/listplace.xml",
        "https://pmb.acdh.oeaw.ac.at/media/listorg.xml"
    ]
    
    # Create python-temp directory if it doesn't exist
    output_dir = Path("python-temp")
    output_dir.mkdir(exist_ok=True)
    
    # Check if all files are fresh (less than 24 hours old)
    all_files_fresh = True
    for url in urls:
        filename = url.split("/")[-1]
        filepath = output_dir / filename
        if not is_file_fresh(filepath):
            all_files_fresh = False
            break
    
    if all_files_fresh:
        print("✅ All PMB files are fresh (less than 24 hours old), skipping download")
        sys.stdout.flush()
        return
    
    print("🔄 PMB files are stale or missing, downloading...")
    sys.stdout.flush()
    
    for url in urls:
        filename = url.split("/")[-1]
        filepath = output_dir / filename
        
        # Skip download if this specific file is fresh
        if is_file_fresh(filepath):
            print(f"Skipping {filename} (file is fresh)")
            continue
            
        print(f"📥 Downloading {filename}...")
        sys.stdout.flush()  # Immediate output
        
        try:
            headers = {
                "Content-type": "application/xml; charset=utf-8",
                "Accept-Charset": "utf-8",
            }
            response = requests.get(url, headers=headers, timeout=60)  # Add timeout and headers
            response.raise_for_status()

            print(f"📄 Processing {filename} ({len(response.content):,} bytes)...")
            sys.stdout.flush()

            # Parse and normalize the XML content
            source_tree = ET.ElementTree(ET.fromstring(response.content.decode("utf-8")))

            # Convert tree back to string and normalize
            xml_string = ET.tostring(source_tree.getroot(), encoding='utf-8').decode('utf-8')
            normalized_content = normalize_xml_content(xml_string)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
                f.write(normalized_content)

            print(f"✅ Successfully saved and normalized {filename}")
            sys.stdout.flush()

        except requests.exceptions.RequestException as e:
            print(f"❌ Error downloading {filename}: {e}")
            # If download fails but we have an old version, continue
            if filepath.exists():
                print(f"📋 Using existing (potentially outdated) version of {filename}")
            else:
                print(f"⚠️  No fallback available for {filename}")
            sys.stdout.flush()

if __name__ == "__main__":
    download_pmb_files()