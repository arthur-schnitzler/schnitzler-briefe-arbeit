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

# Ensure unbuffered output for GitHub Actions
sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)

def commit_progress(processed, total, batch_num):
    """Create intermediate commit and push current progress"""
    try:
        # Check if there are any changes to commit
        result = subprocess.run(['git', 'status', '--porcelain'], 
                              capture_output=True, text=True)
        
        if not result.stdout.strip():
            print(f"📝 No changes to commit at batch {batch_num}")
            return True
            
        # Add all changes
        subprocess.run(['git', 'add', '-A'], check=True)
        
        # Create commit message
        commit_msg = f"Intermediate commit: processed {processed}/{total} files (batch {batch_num})\n\n🤖 Automated batch processing checkpoint"
        
        # Commit changes
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
        
        print(f"✅ Committed progress: {processed}/{total} files (batch {batch_num})")
        
        # Push immediately to avoid conflicts later
        print(f"🚀 Pushing intermediate commit...")
        sys.stdout.flush()
        
        subprocess.run(['git', 'push'], check=True)
        
        print(f"✅ Successfully pushed batch {batch_num} to remote")
        sys.stdout.flush()
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"⚠️ Failed to commit/push progress: {e}")
        # Try to recover by pulling latest changes
        try:
            print(f"🔄 Attempting to pull latest changes and retry...")
            subprocess.run(['git', 'pull', '--rebase'], check=True)
            subprocess.run(['git', 'push'], check=True)
            print(f"✅ Successfully recovered and pushed batch {batch_num}")
            return True
        except subprocess.CalledProcessError as e2:
            print(f"❌ Recovery failed: {e2}")
            sys.stdout.flush()
            return False

def process_file(xml_file, processor_script):
    """Process a single XML file"""
    file_name = Path(xml_file).name
    
    print(f"🔄 About to process {file_name}")
    sys.stdout.flush()
    
    # Check if files exist
    if not Path(xml_file).exists():
        print(f"❌ Input file does not exist: {xml_file}")
        sys.stdout.flush()
        return {"file": file_name, "status": "failed", "error": "Input file not found"}
    
    if not Path(processor_script).exists():
        print(f"❌ Processor script does not exist: {processor_script}")
        sys.stdout.flush()
        return {"file": file_name, "status": "failed", "error": "Processor script not found"}
    
    print(f"📂 Input file: {xml_file} ({Path(xml_file).stat().st_size:,} bytes)")
    print(f"🐍 Processor: {processor_script}")
    print(f"🚀 Launching subprocess...")
    sys.stdout.flush()
    
    try:
        # Run the processor script
        result = subprocess.run([
            sys.executable, 
            str(processor_script), 
            xml_file
        ], capture_output=True, text=True, timeout=600)  # 10 minute timeout per file
        
        print(f"📤 Subprocess completed for {file_name}")
        sys.stdout.flush()
        
        if result.returncode == 0:
            print(f"✅ {file_name} processed successfully")
            sys.stdout.flush()
            return {"file": file_name, "status": "success", "error": None}
        else:
            print(f"❌ {file_name} failed with return code {result.returncode}")
            print(f"   STDOUT: {result.stdout[:500]}...")
            print(f"   STDERR: {result.stderr[:500]}...")
            sys.stdout.flush()
            return {"file": file_name, "status": "failed", "error": result.stderr}
            
    except subprocess.TimeoutExpired:
        print(f"⏰ {file_name} timed out after 10 minutes")
        sys.stdout.flush()
        return {"file": file_name, "status": "timeout", "error": "Timeout after 10 minutes"}
    except Exception as e:
        return {"file": file_name, "status": "exception", "error": str(e)}

def download_pmb_lists():
    """Download and transform PMB lists"""
    script_dir = Path(__file__).parent
    download_script = script_dir / 'download-and-transform-pmb-lists.py'
    
    if not download_script.exists():
        print(f"Error: Download script {download_script} does not exist")
        return False
    
    print("📥 Downloading and transforming PMB lists...")
    
    try:
        result = subprocess.run([
            sys.executable, 
            str(download_script)
        ], capture_output=True, text=True, timeout=600)  # 10 minute timeout
        
        if result.returncode == 0:
            print("✅ PMB lists downloaded and transformed successfully")
            return True
        else:
            print(f"Error downloading PMB lists: {result.stderr}")
            return False
        
    except subprocess.TimeoutExpired:
        print("Error: PMB download timed out")
        return False
    except Exception as e:
        print(f"Error downloading PMB lists: {e}")
        return False

def main():
    """Process all .xml files in editions folder"""
    parser = argparse.ArgumentParser(description="Batch process TEI XML back elements")
    parser.add_argument('--parallel', '-p', type=int, default=4, 
                       help='Number of parallel processes (default: 4)')
    parser.add_argument('--limit', '-l', type=int, 
                       help='Limit number of files to process (for testing)')
    parser.add_argument('--pattern', default='L*.xml',
                       help='File pattern to match (default: L*.xml)')
    parser.add_argument('--skip-download', action='store_true',
                       help='Skip PMB lists download')
    parser.add_argument('--commit-interval', type=int, default=100,
                       help='Create intermediate commit every N successfully processed files (default: 100, 0 to disable)')
    
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
    
    # Download PMB lists unless skipped
    if not args.skip_download:
        if not download_pmb_lists():
            print("Failed to download PMB lists. Exiting.")
            sys.exit(1)
    
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
    
    print(f"📊 Found {len(xml_files)} files to process")
    print(f"⚙️ Using {args.parallel} parallel processes")
    print(f"📋 Processing files matching: {args.pattern}")
    print("\n🔄 Starting batch processing of XML files...")
    sys.stdout.flush()
    
    # Process files
    processed = 0
    failed = 0
    start_time = time.time()
    
    print(f"🚀 Submitting {len(xml_files)} jobs to thread pool...")
    sys.stdout.flush()
    
    with ThreadPoolExecutor(max_workers=args.parallel) as executor:
        # Submit all jobs
        future_to_file = {
            executor.submit(process_file, xml_file, processor_script): xml_file 
            for xml_file in xml_files
        }
        
        print(f"✅ All jobs submitted! Waiting for results...")
        sys.stdout.flush()
        
        # Process results as they complete
        for future in as_completed(future_to_file):
            result = future.result()
            
            if result["status"] == "success":
                processed += 1
            else:
                print(f"❌ Failed to process {result['file']}: {result['error']}")
                failed += 1
            
            # Progress indicator and intermediate commits
            total_done = processed + failed
            
            # Regular progress updates
            if total_done % 10 == 0 or total_done == len(xml_files):
                elapsed = time.time() - start_time
                avg_time = elapsed / total_done if total_done > 0 else 0
                remaining_files = len(xml_files) - total_done
                eta = remaining_files * avg_time if avg_time > 0 else 0
                
                print(f"📊 Progress: {total_done}/{len(xml_files)} ({100*total_done/len(xml_files):.1f}%) | "
                      f"✅ {processed} success | ❌ {failed} failed | "
                      f"⏱️  {avg_time:.1f}s/file | ETA: {eta/60:.1f}min")
                sys.stdout.flush()
            
            # Intermediate commits based on commit-interval setting
            if args.commit_interval > 0 and processed > 0 and processed % args.commit_interval == 0:
                batch_num = processed // args.commit_interval
                print(f"\n💾 Creating intermediate commit after {processed} successfully processed files...")
                sys.stdout.flush()
                commit_progress(processed, len(xml_files), batch_num)
                print("🔄 Continuing with batch processing...\n")
                sys.stdout.flush()
    
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