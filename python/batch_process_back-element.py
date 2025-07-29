#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import glob
import sys
from pathlib import Path

# Import our TEI transformation functions
import importlib.util
spec = importlib.util.spec_from_file_location("tei_transform", 
                                               os.path.join(os.path.dirname(__file__), "add-back-element-from-pmb.py"))
tei_transform = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tei_transform)
transform_tei_document = tei_transform.transform_tei_document

def process_tei_files(input_dir="./editions", output_dir=None, pattern="L0*.xml", 
                     enrich_data=False, clean_pmb_data=False, backup=True):
    """
    Process all TEI files matching the pattern in the input directory.
    
    Args:
        input_dir: Directory containing the XML files
        output_dir: Directory to save processed files (if None, overwrites originals)
        pattern: File pattern to match (default: "L0*.xml")
        enrich_data: Whether to enrich with PMB data
        clean_pmb_data: Whether to apply PMB cleaning
        backup: Whether to create backup copies
    """
    
    # Convert to Path objects
    input_path = Path(input_dir)
    if not input_path.exists():
        print(f"Error: Input directory '{input_dir}' does not exist.")
        return
    
    # Find all matching files
    pattern_path = input_path / pattern
    xml_files = glob.glob(str(pattern_path))
    
    if not xml_files:
        print(f"No files matching pattern '{pattern}' found in '{input_dir}'")
        return
    
    print(f"Found {len(xml_files)} files matching pattern '{pattern}'")
    
    # Setup output directory
    if output_dir:
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        print(f"Output directory: {output_path}")
    else:
        output_path = input_path
        print("Overwriting original files")
    
    # Process files
    processed = 0
    errors = 0
    
    for xml_file in sorted(xml_files):
        file_path = Path(xml_file)
        filename = file_path.name
        
        try:
            print(f"Processing: {filename}")
            
            # Read the file
            with open(file_path, 'rb') as f:
                xml_content = f.read()
            
            # Create backup if requested
            if backup and not output_dir:
                backup_path = file_path.with_suffix('.xml.backup')
                if not backup_path.exists():
                    with open(backup_path, 'wb') as f:
                        f.write(xml_content)
                    print(f"  Backup created: {backup_path.name}")
            
            # Transform the document
            result = transform_tei_document(xml_content, 
                                          enrich_data=enrich_data, 
                                          clean_pmb_data=clean_pmb_data)
            
            # Determine output file path
            if output_dir:
                output_file = output_path / filename
            else:
                output_file = file_path
            
            # Write the result
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(result)
            
            processed += 1
            print(f"  ✓ Successfully processed")
            
        except Exception as e:
            errors += 1
            print(f"  ✗ Error processing {filename}: {str(e)}")
    
    print(f"\nProcessing complete:")
    print(f"  Successfully processed: {processed}")
    print(f"  Errors: {errors}")
    print(f"  Total files: {len(xml_files)}")

def main():
    """Main function for command line usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Process TEI XML files with back element transformation')
    parser.add_argument('--input', '-i', default='./editions', 
                       help='Input directory (default: ./editions)')
    parser.add_argument('--output', '-o', 
                       help='Output directory (default: overwrite originals)')
    parser.add_argument('--pattern', '-p', default='L0*.xml',
                       help='File pattern to match (default: L0*.xml)')
    parser.add_argument('--enrich', action='store_true',
                       help='Enrich with PMB data')
    parser.add_argument('--clean', action='store_true',
                       help='Apply PMB data cleaning')
    parser.add_argument('--no-backup', action='store_true',
                       help='Skip creating backup files')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what files would be processed without actually processing them')
    
    args = parser.parse_args()
    
    if args.dry_run:
        # Just show what files would be processed
        input_path = Path(args.input)
        pattern_path = input_path / args.pattern
        xml_files = glob.glob(str(pattern_path))
        
        print(f"Dry run - would process {len(xml_files)} files:")
        for xml_file in sorted(xml_files):
            print(f"  {Path(xml_file).name}")
        
        print(f"\nSettings:")
        print(f"  Input directory: {args.input}")
        print(f"  Output directory: {args.output or 'overwrite originals'}")
        print(f"  Pattern: {args.pattern}")
        print(f"  Enrich data: {args.enrich}")
        print(f"  Clean PMB data: {args.clean}")
        print(f"  Create backups: {not args.no_backup}")
    else:
        # Actually process files
        process_tei_files(
            input_dir=args.input,
            output_dir=args.output,
            pattern=args.pattern,
            enrich_data=args.enrich,
            clean_pmb_data=args.clean,
            backup=not args.no_backup
        )

if __name__ == "__main__":
    # If run directly, you can also call specific functions
    if len(sys.argv) == 1:
        # No command line arguments - run with defaults
        print("Running with default settings...")
        print("Use --help for command line options")
        print()
        
        # Basic processing of L0*.xml files
        process_tei_files(
            input_dir="./editions",
            pattern="L0*.xml",
            enrich_data=False,
            clean_pmb_data=False,
            backup=True
        )
    else:
        # Use command line interface
        main()