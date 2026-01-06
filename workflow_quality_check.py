#!/usr/bin/env python3
"""
Workflow Quality Check - Basic Version
Scans for large files and basic syntax errors in Python files.
"""
import sys
import os
import ast

MAX_FILE_SIZE_MB = 10


def check_quality(root_dir):
    issues = 0
    print(f"Running quality check on {root_dir}...")

    for root, dirs, files in os.walk(root_dir):
        if "node_modules" in dirs:
            dirs.remove("node_modules")
        if ".venv" in dirs:
            dirs.remove(".venv")
        if ".git" in dirs:
            dirs.remove(".git")

        for file in files:
            file_path = os.path.join(root, file)

            # Check 1: File Size
            try:
                size_mb = os.path.getsize(file_path) / (1024 * 1024)
                if size_mb > MAX_FILE_SIZE_MB:
                    print(f"[WARN] Large file detected: {file_path} ({size_mb:.2f} MB)")
                    issues += 1
            except OSError:
                continue

            # Check 2: Python Syntax
            if file.endswith(".py"):
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        source = f.read()
                    ast.parse(source)
                except SyntaxError as e:
                    print(f"[ERROR] Syntax Error in {file_path}: {e}")
                    issues += 1
                except Exception:
                    pass  # Ignore read errors

    return issues


def main():
    root_dir = os.getcwd()
    issues = check_quality(root_dir)
    print(f"\nQuality check complete. Found {issues} potential issues.")
    # Return failure exit code if issues found, for CI pipeline
    return 1 if issues > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
