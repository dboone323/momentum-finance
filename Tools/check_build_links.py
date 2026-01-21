#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
phase_id = "6B1A2B242C0D1E8F00123456"  # App Sources

files_to_check = {
    "CategoriesGenerator": "CategoriesGenerator.swift",
    "SampleData": "SampleData.swift",
}


def check_links():
    try:
        with open(project_path) as f:
            content = f.read()

        # Extract Phase Block
        pattern = re.compile(
            re.escape(phase_id) + r" /\* Sources \*/ = \{.*?files = \((.*?)\);",
            re.DOTALL,
        )
        match = pattern.search(content)
        if not match:
            print("Phase not found.")
            return

        block = match.group(1)

        # Check files from logic
        # First find BuildID for the files
        for _, fname in files_to_check.items():
            # Find BuildID
            # Search for: ID /* fname in Sources */ = { isa = PBXBuildFile ...
            # Regex for definition
            # We want check if ANY BuildID for this file is in the block.

            # Find FileRef first?
            # Find BuildFile pointing to fname?

            # Simple check: Is fname in block?
            # List items usually: ID /* fname in Sources */,
            if f"/* {fname} in Sources */" in block:
                print(f"PASS: {fname} IS in Source Phase.")
            else:
                print(f"FAIL: {fname} IS NOT in Source Phase.")

            # Deep verification via ID
            # find IDs in file
            # grep ID location
            pass

    except Exception as e:
        print(f"Error: {e}")


check_links()
