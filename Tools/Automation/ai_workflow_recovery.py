#!/usr/bin/env python3
"""
AI Workflow Recovery System - Basic Version
Scans for .bak files and offers restoration if originals are missing.
"""
import sys
import os
import shutil
import glob

def restore_backups(root_dir, dry_run=False):
    """Restores files from .bak backups if original is missing."""
    print(f"Scanning {root_dir} for recovery opportunities...")
    restored_count = 0
    
    # Find all .bak files
    for backup_file in glob.glob(os.path.join(root_dir, '**/*.bak'), recursive=True):
        original_file = backup_file[:-4] # Remove .bak
        
        if not os.path.exists(original_file):
            print(f"[FOUND] Missing original for: {backup_file}")
            if not dry_run:
                try:
                    shutil.copy2(backup_file, original_file)
                    print(f"  [RESTORED] -> {original_file}")
                    restored_count += 1
                except Exception as e:
                    print(f"  [ERROR] Could not restore: {e}")
            else:
                print(f"  [DRY-RUN] Would restore to {original_file}")
    
    return restored_count

def main():
    root_dir = os.getcwd()
    dry_run = "--dry-run" in sys.argv
    
    count = restore_backups(root_dir, dry_run)
    print(f"\nTotal files restored: {count}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
