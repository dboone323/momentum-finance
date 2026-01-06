import sys
import re
import os
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinance"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def force_add_app_files():
    try:
        with open(project_path, "r") as f:
            content = f.read()

        # 1. Find Target ID and Sources Phase ID
        # Reuse robust logic from add_app_files_to_target.py (simplified here for brevity)
        lines = content.split("\n")
        target_id = None
        for i, line in enumerate(lines):
            if f"/* {target_name} */ = {{" in line:
                if (
                    i + 1 < len(lines)
                    and "isa = PBXNativeTarget;" in lines[i + 1].strip()
                ):
                    target_id = line.strip().split(" ")[0]
                    break
        if not target_id:
            # Fallback
            target_id = "6B1A2B272C0D1E8F00123456"  # Hardcoded from previous checks
            if target_id not in content:
                print("Error: Target ID not found")
                return

        # Find Sources Phase
        target_section_regex = re.compile(
            re.escape(target_id)
            + r"\s/\*\s"
            + re.escape(target_name)
            + r"\s\*/\s=\s\{.*?buildPhases\s=\s\((.*?)\);",
            re.DOTALL,
        )
        match = target_section_regex.search(content)
        sources_phase_id = None
        if match:
            phase_ids = re.findall(r"([A-Fa-f0-9]{24})", match.group(1))
            for pid in phase_ids:
                if f"{pid} /* Sources */ =" in content:
                    sources_phase_id = pid
                    break

        if not sources_phase_id:
            # Fallback
            sources_phase_id = "6B1A2B242C0D1E8F00123456"
            if sources_phase_id not in content:
                print("Error: Sources ID not found")
                return

        print(f"Target: {target_id}, Sources: {sources_phase_id}")

        # 2. Get existing build file IDs in Sources Phase
        phase_regex_str = (
            re.escape(sources_phase_id)
            + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
        )
        phase_match = re.search(phase_regex_str, content, re.DOTALL)
        existing_bf_ids = set()
        if phase_match:
            block = phase_match.group(1)
            ids = re.findall(r"([A-Fa-f0-9]{24})", block)
            existing_bf_ids = set(ids)

        # 3. Find candidates
        file_refs = re.findall(
            r"([A-Fa-f0-9]{24})\s/\*\s(.*?)\s\*/\s=\s\{isa = PBXFileReference;.*?path = (.*?);",
            content,
        )

        files_to_add = []

        # Cache existing REF associations
        # Map [BuildFileID] -> FileRefID
        # We need to construct this mapping to assume 'is_already_added' accurately

        bf_to_ref = {}
        # Parse all PBXBuildFile definitions
        # ID ... fileRef = FID
        bf_defs = re.findall(
            r"([A-Fa-f0-9]{24}).*?fileRef\s=\s([A-Fa-f0-9]{24})", content
        )
        for bfid, fid in bf_defs:
            bf_to_ref[bfid] = fid

        # Set of already added Refs
        added_ref_ids = set()
        for bfid in existing_bf_ids:
            if bfid in bf_to_ref:
                added_ref_ids.add(bf_to_ref[bfid])

        for file_ref_id, comment_name, file_path in file_refs:
            # Derive filename and rel_path for debug prints
            filename = os.path.basename(file_path)
            rel_path = file_path  # Using file_path as rel_path for this context

            if filename == "FinancialMLModels.swift":
                print(f"DEBUG: Found FinancialMLModels.swift at {rel_path}")
                # Note: paths_in_project is not defined in the provided code.
                # This check will cause a NameError if uncommented without defining paths_in_project.
                # if rel_path in paths_in_project:
                #      print("DEBUG: Already in paths_in_project")
                # else:
                #      print("DEBUG: NOT in paths_in_project. Should ADD.")

            if not file_path.endswith(".swift"):
                continue

            # Filter: Must be in MomentumFinance/Shared or App or Features
            # But path in pbxproj for Shared files usually is relative to group.
            # Groups are weird.
            # But assume we want to include ALMOST EVERYTHING from the main source tree that isn't Tests or Core.

            if "Tests" in comment_name or "MomentumFinanceTests" in file_path:
                continue
            if "MomentumFinanceCore" in file_path:
                continue

            # Check if likely an App file?
            # If verify file existence?
            # We can skip verification if we trust FileRefs are generally valid (Project compiles 58 files so paths likely OK).
            # But let's verify existence to avoid ghosts

            name = os.path.basename(file_path)

            # Is it already added?
            if file_ref_id in added_ref_ids:
                continue

            # If not added, ADD IT.
            # No sophisticated existence check other than "matches name".
            files_to_add.append((file_ref_id, comment_name))

        print(f"Found {len(files_to_add)} files to FORCE ADD.")

        if len(files_to_add) == 0:
            print("No files to add.")
            return

        # 4. Modify Content (Add PBXBuildFile definitions and add to Phase)

        new_lines = []
        lines = content.split("\n")
        in_bf_section = False
        defs_added = False
        new_bf_entries = []

        for line in lines:
            if "/* Begin PBXBuildFile section */" in line:
                new_lines.append(line)
                in_bf_section = True
                continue

            if in_bf_section and not defs_added:
                for fid, name in files_to_add:
                    bid = generate_id()
                    new_bf_entries.append((bid, name))
                    new_lines.append(
                        f"\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};"
                    )
                defs_added = True

            if "/* End PBXBuildFile section */" in line:
                in_bf_section = False

            new_lines.append(line)

        final_content = "\n".join(new_lines)

        # Add to Sources Phase
        phase_regex_str = (
            re.escape(sources_phase_id)
            + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
        )
        phase_match = re.search(phase_regex_str, final_content, re.DOTALL)

        if phase_match:
            existing_files_block = phase_match.group(1)
            new_files_block = existing_files_block
            if not new_files_block.endswith("\n"):
                new_files_block += "\n"

            for bid, name in new_bf_entries:
                new_files_block += f"\t\t\t\t{bid} /* {name} in Sources */,\n"

            start_idx = phase_match.start(1)
            end_idx = phase_match.end(1)
            final_content = (
                final_content[:start_idx] + new_files_block + final_content[end_idx:]
            )

            with open(project_path, "w") as f:
                f.write(final_content)
            print("Successfully updated project.pbxproj")
        else:
            print("Error: Could not locate files list in sources phase.")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()


force_add_app_files()
