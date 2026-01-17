#!/usr/bin/env python3
"""
Add macOS source files to the MomentumFinance App target.
These files are in MomentumFinance/macOS/ but missing from project.pbxproj.
"""
import os
import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
macos_dir = "MomentumFinance/macOS"

# Known App Target Sources Build Phase ID
APP_SOURCES_PHASE_ID = "22DC814540EEC1C8E020CE47"


def generate_id():
    """Generate a 24-character hex ID like Xcode uses."""
    return uuid.uuid4().hex[:24].upper()


def add_macos_files():
    # Find all Swift files in macOS directory (not subdirectories for now)
    swift_files = []
    for f in os.listdir(macos_dir):
        if f.endswith(".swift"):
            swift_files.append(f)

    print(f"Found {len(swift_files)} Swift files in macOS folder:")
    for f in swift_files:
        print(f"  - {f}")

    with open(project_path) as f:
        content = f.read()

    # Check which files are already in project
    files_to_add = []
    for filename in swift_files:
        if filename not in content:
            files_to_add.append(filename)
        else:
            print(f"  [SKIP] {filename} already in project")

    if not files_to_add:
        print("All files already in project!")
        return

    print(f"\nAdding {len(files_to_add)} files to project...")

    # For each file, we need to:
    # 1. Add PBXFileReference
    # 2. Add PBXBuildFile
    # 3. Add to Sources build phase files list
    # 4. Add to a group (create macOS group if needed)

    file_refs = []  # (id, filename)
    build_files = []  # (id, fileref_id, filename)

    for filename in files_to_add:
        file_ref_id = generate_id()
        build_file_id = generate_id()
        file_refs.append((file_ref_id, filename))
        build_files.append((build_file_id, file_ref_id, filename))

    # 1. Add PBXFileReference entries
    # Find end of PBXFileReference section
    file_ref_section_end = content.find("/* End PBXFileReference section */")
    if file_ref_section_end == -1:
        print("ERROR: Could not find PBXFileReference section")
        return

    file_ref_entries = ""
    for fid, fname in file_refs:
        file_ref_entries += f'\t\t{fid} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "macOS/{fname}"; sourceTree = "<group>"; }};\n'

    content = (
        content[:file_ref_section_end]
        + file_ref_entries
        + content[file_ref_section_end:]
    )

    # 2. Add PBXBuildFile entries
    build_file_section_end = content.find("/* End PBXBuildFile section */")
    if build_file_section_end == -1:
        print("ERROR: Could not find PBXBuildFile section")
        return

    build_file_entries = ""
    for bfid, frid, fname in build_files:
        build_file_entries += f"\t\t{bfid} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {frid} /* {fname} */; }};\n"

    content = (
        content[:build_file_section_end]
        + build_file_entries
        + content[build_file_section_end:]
    )

    # 3. Add to Sources build phase
    # Find the App target's Sources build phase files list
    sources_pattern = rf"{APP_SOURCES_PHASE_ID}\s*/\*\s*Sources\s*\*/\s*=\s*\{{\s*isa\s*=\s*PBXSourcesBuildPhase;[^}}]*files\s*=\s*\("
    match = re.search(sources_pattern, content)
    if not match:
        print("ERROR: Could not find App Sources build phase")
        return

    insert_pos = match.end()
    sources_entries = ""
    for bfid, _, fname in build_files:
        sources_entries += f"\n\t\t\t\t{bfid} /* {fname} in Sources */,"

    content = content[:insert_pos] + sources_entries + content[insert_pos:]

    with open(project_path, "w") as f:
        f.write(content)

    print(f"Successfully added {len(files_to_add)} macOS files to project!")


add_macos_files()
