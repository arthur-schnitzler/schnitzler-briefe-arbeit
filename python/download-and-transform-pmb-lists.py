import requests
import re
from pathlib import Path

def normalize_xml_content(content):
    # Replace patterns with "__" in xml:id and key attributes with "pmb"
    # Example: work__296327 -> pmb296327
    content = re.sub(r'(xml:id=")[^"]*__([^"]*")', r'\1pmb\2', content)
    content = re.sub(r'(key=")[^"]*__([^"]*")', r'\1pmb\2', content)
    
    return content

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
    
    for url in urls:
        filename = url.split("/")[-1]
        filepath = output_dir / filename
        
        print(f"Downloading {filename}...")
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            
            # Normalize the XML content
            normalized_content = normalize_xml_content(response.text)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(normalized_content)
            
            print(f"Successfully saved and normalized {filename}")
            
        except requests.exceptions.RequestException as e:
            print(f"Error downloading {filename}: {e}")

if __name__ == "__main__":
    download_pmb_files()