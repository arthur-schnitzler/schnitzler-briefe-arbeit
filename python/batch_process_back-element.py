#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batch processor for TEI XML back elements
Processes all .xml files in the editions folder using add-back-element-from-pmb.py
"""

import glob
import subprocess
import sys
from pathlib import Path
import time
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import pickle
import os

def process_file(xml_file, processor_script):
    """Process a single XML file"""
    file_name = Path(xml_file).name
    
    try:
        # Run the processor script
        result = subprocess.run([
            sys.executable, 
            str(processor_script), 
            xml_file
        ], capture_output=True, text=True, timeout=300)  # 5 minute timeout per file
        
        if result.returncode == 0:
            return {"file": file_name, "status": "success", "error": None}
        else:
            return {"file": file_name, "status": "failed", "error": result.stderr}
            
    except subprocess.TimeoutExpired:
        return {"file": file_name, "status": "timeout", "error": "Timeout after 5 minutes"}
    except Exception as e:
        return {"file": file_name, "status": "exception", "error": str(e)}

def preload_pmb_cache():
    """Preload the PMB cache by running the processor once"""
    script_dir = Path(__file__).parent
    processor_script = script_dir / 'add-back-element-from-pmb.py'
    
    print("Preloading PMB cache...")
    
    # Create a dummy file to trigger cache loading
    dummy_file = script_dir / 'dummy.xml'
    dummy_content = '''<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader></teiHeader>
    <text>
        <body>
            <p>Dummy content</p>
        </body>
    </text>
</TEI>'''
    
    try:
        with open(dummy_file, 'w', encoding='utf-8') as f:
            f.write(dummy_content)
        
        # Run processor to trigger cache loading
        result = subprocess.run([
            sys.executable, 
            str(processor_script), 
            str(dummy_file)
        ], capture_output=True, text=True, timeout=600)  # 10 minute timeout for initial cache load
        
        if result.returncode == 0:
            print("PMB cache preloaded successfully")
        else:
            print(f"Warning: Cache preload had issues: {result.stderr}")
        
    except subprocess.TimeoutExpired:
        print("Warning: Cache preload timed out")
    except Exception as e:
        print(f"Warning: Cache preload failed: {e}")
    finally:
        # Clean up dummy file
        if dummy_file.exists():
            dummy_file.unlink()

def main():
    """Process all .xml files in editions folder"""
    parser = argparse.ArgumentParser(description="Batch process TEI XML back elements")
    parser.add_argument('--parallel', '-p', type=int, default=4, 
                       help='Number of parallel processes (default: 4)')
    parser.add_argument('--limit', '-l', type=int, 
                       help='Limit number of files to process (for testing)')
    parser.add_argument('--pattern', default='*.xml',
                       help='File pattern to match (default: *.xml)')
    parser.add_argument('--skip-preload', action='store_true',
                       help='Skip PMB cache preloading')
    
    args = parser.parse_args()
    
    # Define paths
    script_dir = Path(__file__).parent
    editions_dir = script_dir / '../editions'
    processor_script = script_dir / 'add-back-element-from-pmb.py'
    
    # Check if directories and script exist
    if not editions_dir.exists():
        print(f"Error: Directory {editions_dir} does not exist")
        sys.exit(1)
    
    if not processor_script.exists():
        print(f"Error: Processor script {processor_script} does not exist")
        sys.exit(1)
    
    # Preload PMB cache unless skipped
    if not args.skip_preload:
        preload_pmb_cache()
    
    # Find all .xml files
    pattern = str(editions_dir / args.pattern)
    xml_files = sorted(glob.glob(pattern))
    
    if not xml_files:
        print(f"No files matching '{args.pattern}' found in {editions_dir}")
        return
    
    # Limit files if requested
    if args.limit:
        xml_files = xml_files[:args.limit]
        print(f"Limited to first {args.limit} files")
    
    print(f"Found {len(xml_files)} files to process")
    print(f"Using {args.parallel} parallel processes")
    print("\nStarting batch processing...")
    
    # Process files
    processed = 0
    failed = 0
    start_time = time.time()
    
    with ThreadPoolExecutor(max_workers=args.parallel) as executor:
        # Submit all jobs
        future_to_file = {
            executor.submit(process_file, xml_file, processor_script): xml_file 
            for xml_file in xml_files
        }
        
        # Process results as they complete
        for future in as_completed(future_to_file):
            result = future.result()
            
            if result["status"] == "success":
                print(f"✅ Successfully processed {result['file']}")
                processed += 1
            else:
                print(f"❌ Failed to process {result['file']}: {result['error']}")
                failed += 1
            
            # Progress indicator
            total_done = processed + failed
            if total_done % 50 == 0 or total_done == len(xml_files):
                print(f"Progress: {total_done}/{len(xml_files)} ({100*total_done/len(xml_files):.1f}%)")
    
    # Summary
    end_time = time.time()
    duration = end_time - start_time
    
    print(f"\n{'='*50}")
    print(f"Batch processing completed!")
    print(f"Total files: {len(xml_files)}")
    print(f"Successfully processed: {processed}")
    print(f"Failed: {failed}")
    print(f"Duration: {duration:.1f} seconds")
    print(f"Average: {duration/len(xml_files):.1f} seconds per file")
    print(f"{'='*50}")
    
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()