#!/usr/bin/env python3
import os
import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinance"
shared_dir = "MomentumFinance/Shared"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def import_missing_files():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Find Target Info (Sources Phase) - Reuse previous logic
        target_id = "6B1A2B272C0D1E8F00123456"  # Hardcoded fallback
        sources_phase_id = "6B1A2B242C0D1E8F00123456"

        # Verify
        if target_id not in content:
            # Find by regex
            # ... simplified reuse ...
            pass

        # 2. Find "Shared" Group ID
        # path = Shared;
        group_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\sShared\s\*/\s=\s\{.*?isa = PBXGroup;", re.DOTALL
        )
        group_match = group_regex.search(content)
        shared_group_id = None
        if group_match:
            shared_group_id = group_match.group(1)

        if not shared_group_id:
            # Maybe path = MomentumFinance/Shared ?
            # Try searching for a file IN Shared that we know exists
            # e.g. defined file "AppLogger.swift"
            # find FileRef, then find who references it
            print("Warning: Shared Group ID not found via regex. Trying fallback.")
            # Search for isa = PBXGroup; ... children = ( ... ); ... path = Shared;
            # Simple grep of lines
            lines = content.split("\n")
            for i, line in enumerate(lines):
                if "path = Shared;" in line:
                    # Look backwards for ID
                    for j in range(i, i - 20, -1):
                        if "isa = PBXGroup;" in lines[j]:
                            # The ID is usually on line j-2 or j-1
                            # ID = {
                            # isa = PBXGroup;
                            prev = lines[j - 1]
                            if "=" in prev and "{" in prev:
                                shared_group_id = prev.strip().split(" ")[0]
                            break
                    if shared_group_id:
                        break

        if not shared_group_id:
            print("Error: Could not find Shared Group ID. Cannot add files.")
            return

        print(f"Shared Group ID: {shared_group_id}")

        # 3. Scan Disk for Files
        files_on_disk = []  # (filename, full_path, relative_to_shared)

        for root, _, files in os.walk(shared_dir):
            for file in files:
                if file.endswith(".swift"):
                    # relative path involves subdirectories
                    rel_dir = os.path.relpath(root, shared_dir)
                    if rel_dir == ".":
                        rel_dir = ""

                    # Note: Adding files recursively to a FLAT group (Shared) in Xcode is messy but works for compilation.
                    # Ideally we match the folder structure with Groups, but that's hard script.
                    # We will add ALL new files to the "Shared" group directly, even if they are in subfolders.
                    # Xcode handles the path references.

                    files_on_disk.append(
                        (file, os.path.join(root, file), os.path.join(rel_dir, file))
                    )

        print(f"Found {len(files_on_disk)} Swift files on disk in Shared.")

        # 4. Check which files overlap with existing FileRefs
        # We check by PATH or NAME

        existing_filenames = set()
        # Find all FileRefs and their paths
        file_refs = re.findall(r"path = (.*?);", content)
        for p in file_refs:
            existing_filenames.add(os.path.basename(p.replace('"', "")))

        files_to_import = []
        for fname, fpath, relpath in files_on_disk:
            if fname in existing_filenames:
                continue

            # Not in project. Add it.
            files_to_import.append((fname, fpath, relpath))

        print(f"Found {len(files_to_import)} files missing from project.")

        if len(files_to_import) == 0:
            print("No files to import.")
            return

        # 5. Modify Project
        new_filerefs = []
        new_buildfiles = []

        for fname, fpath, relpath in files_to_import:
            fid = generate_id()
            bid = generate_id()

            # Create FileRef
            # ID /* fname */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "relpath"; sourceTree = "<group>"; };
            # path should be relative to group location (Shared).
            # relpath variable holds "Subdir/File.swift" presumably
            escaped_path = f'"{relpath}"' if " " in relpath else relpath

            ref_def = f'\t\t{fid} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {escaped_path}; sourceTree = "<group>"; }};'
            new_filerefs.append(ref_def)

            # Create BuildFile
            bf_def = f"\t\t{bid} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {fname} */; }};"
            new_buildfiles.append(bf_def)

        # Insertion points
        lines = content.split("\n")
        new_lines = []

        in_fr_section = False
        fr_added = False
        in_bf_section = False
        bf_added = False

        for line in lines:
            # PBXFileReference
            if "/* Begin PBXFileReference section */" in line:
                new_lines.append(line)
                in_fr_section = True
                continue
            if in_fr_section and not fr_added:
                for item in new_filerefs:
                    new_lines.append(item)
                fr_added = True
            if "/* End PBXFileReference section */" in line:
                in_fr_section = False

            # PBXBuildFile
            if "/* Begin PBXBuildFile section */" in line:
                new_lines.append(line)
                in_bf_section = True
                continue
            if in_bf_section and not bf_added:
                for item in new_buildfiles:
                    new_lines.append(item)
                bf_added = True
            if "/* End PBXBuildFile section */" in line:
                in_bf_section = False

            new_lines.append(line)

        final_content = "\n".join(new_lines)

        # Update Shared Group Children
        # ID /* Shared */ = { ... children = ( ... );
        group_regex_str = (
            re.escape(shared_group_id)
            + r"\s/\*\sShared\s\*/\s=\s\{.*?children\s=\s\((.*?)\);"
        )
        group_match = re.search(group_regex_str, final_content, re.DOTALL)

        if group_match:
            children_block = group_match.group(1)
            new_children = children_block
            if not new_children.endswith("\n"):
                new_children += "\n"

            for item in new_filerefs:
                # Extract ID and Name from def
                # ID /* fname */ ...
                fid = item.strip().split(" ")[0]
                fname = item.split("/* ")[1].split(" */")[0]
                new_children += f"\t\t\t\t{fid} /* {fname} */,\n"

            start = group_match.start(1)
            end = group_match.end(1)
            final_content = final_content[:start] + new_children + final_content[end:]
        else:
            print("Error: Could not update Shared group children.")
            return

        # Update Sources Phase Files
        phase_regex_str = (
            re.escape(sources_phase_id)
            + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
        )
        phase_match = re.search(phase_regex_str, final_content, re.DOTALL)

        if phase_match:
            files_block = phase_match.group(1)
            new_files = files_block
            if not new_files.endswith("\n"):
                new_files += "\n"

            for item in new_buildfiles:
                # ID /* fname in Sources */ ...
                bid = item.strip().split(" ")[0]
                name = item.split("/* ")[1].split(" */")[0]
                new_files += f"\t\t\t\t{bid} /* {name} */,\n"

            start = phase_match.start(1)
            end = phase_match.end(1)
            final_content = final_content[:start] + new_files + final_content[end:]
        else:
            print("Error: Could not update Sources phase.")
            return

        with open(project_path, "w") as f:
            f.write(final_content)

        print("Successfully imported missing files.")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()


import_missing_files()
