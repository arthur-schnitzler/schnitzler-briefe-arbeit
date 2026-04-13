#!/usr/bin/env python3
"""
Cleanup script to remove duplicate processing instructions from XML files.
This script removes duplicate <?xml-model ...?> processing instructions
that may have been added multiple times.
"""

import glob
import sys
import re
from pathlib import Path


def cleanup_duplicate_pis(file_path):
    """Remove duplicate processing instructions from an XML file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    seen_pis = set()
    cleaned_lines = []
    changes_made = False

    for line in lines:
        # Handle case where multiple PIs are on the same line
        # Find all processing instructions on this line
        pi_pattern = r'<\?[^>]+\?>'
        pis_with_positions = [
            (m.group(), m.start(), m.end())
            for m in re.finditer(pi_pattern, line)
        ]

        if pis_with_positions and not line.strip().startswith('<?xml '):
            # Check if any PIs are duplicated (both across files and within)
            keep_ranges = []
            line_modified = False
            pis_in_this_line = set()

            for pi, start, end in pis_with_positions:
                is_model_or_style = (
                    pi.startswith('<?xml-model') or
                    pi.startswith('<?xml-stylesheet')
                )
                if is_model_or_style:
                    # Check if duplicate across files OR within this line
                    if pi in seen_pis or pi in pis_in_this_line:
                        changes_made = True
                        line_modified = True
                        print(f"  Removing duplicate: {pi}")
                        # Don't keep this range
                    else:
                        seen_pis.add(pi)
                        pis_in_this_line.add(pi)
                        keep_ranges.append((start, end))
                else:
                    # Keep non-model/stylesheet PIs
                    keep_ranges.append((start, end))

            if line_modified:
                # Reconstruct the line keeping only non-duplicate PIs
                # and any text that's not part of PIs
                result_parts = []
                last_end = 0

                # Sort all PI positions (both keep and remove)
                all_pis_sorted = sorted(pis_with_positions, key=lambda x: x[1])
                keep_set = set(keep_ranges)

                for pi, start, end in all_pis_sorted:
                    # Add text before this PI
                    if start > last_end:
                        result_parts.append(line[last_end:start])

                    # Add the PI only if it should be kept
                    if (start, end) in keep_set:
                        result_parts.append(line[start:end])

                    last_end = end

                # Add any remaining text after the last PI
                if last_end < len(line):
                    result_parts.append(line[last_end:])

                rebuilt = ''.join(result_parts)
                # If removing the duplicate PI leaves the line empty (or
                # whitespace-only), drop the line entirely instead of leaving
                # a blank line between the xml decl / remaining PIs and root.
                if rebuilt.strip():
                    cleaned_lines.append(rebuilt)
                continue

        cleaned_lines.append(line)

    if changes_made:
        # Write back the cleaned content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(cleaned_lines))
        return True

    return False


def main():
    """Process all XML files in editions directory."""
    editions_dir = Path("editions")

    if not editions_dir.exists():
        print(f"Error: {editions_dir} directory not found")
        sys.exit(1)

    xml_files = sorted(glob.glob(str(editions_dir / "L*.xml")))

    if not xml_files:
        print(f"No L*.xml files found in {editions_dir}")
        return

    print(
        f"🔍 Checking {len(xml_files)} XML files for duplicate "
        "processing instructions..."
    )

    cleaned_count = 0

    for xml_file in xml_files:
        file_name = Path(xml_file).name

        if cleanup_duplicate_pis(xml_file):
            print(f"✅ Cleaned {file_name}")
            cleaned_count += 1

    print("\n" + "="*50)
    print("Cleanup completed!")
    print(f"Files processed: {len(xml_files)}")
    print(f"Files cleaned: {cleaned_count}")
    print(f"Files unchanged: {len(xml_files) - cleaned_count}")
    print("="*50)


if __name__ == "__main__":
    main()
