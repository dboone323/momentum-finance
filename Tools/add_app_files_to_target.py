#!/usr/bin/env python3
import os
import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinance"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def add_app_files():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Find Target Info
        target_id = None
        target_found = False
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if f"/* {target_name} */ = {{" in line:
                if (
                    i + 1 < len(lines)
                    and "isa = PBXNativeTarget;" in lines[i + 1].strip()
                ):
                    target_id = line.strip().split(" ")[0]
                    target_found = True
                    break

        if not target_id:
            print(f"Error: Target {target_name} not found.")
            return

        print(f"Target ID: {target_id}")

        # 2. Find Sources Phase
        target_section_regex = re.compile(
            re.escape(target_id)
            + r"\s/\*\s"
            + re.escape(target_name)
            + r"\s\*/\s=\s\{.*?buildPhases\s=\s\((.*?)\);",
            re.DOTALL,
        )
        match = target_section_regex.search(content)
        if not match:
            print("Error finding build phases")
            return

        build_phases_block = match.group(1)
        phase_ids = re.findall(r"([A-Fa-f0-9]{24})", build_phases_block)

        sources_phase_id = None

        # Determine sources phase ID by checking definitions
        for pid in phase_ids:
            if f"{pid} /* Sources */ =" in content:
                sources_phase_id = pid
                break

        if not sources_phase_id:
            print("Error: Could not find Sources Build Phase")
            return

        print(f"Sources Build Phase: {sources_phase_id}")

        # 3. Find Candidate Files
        # We look for ALL swift files in the project
        # Filter those that are inside "MomentumFinance/Shared", "MomentumFinance/App", etc.
        # Exclude "MomentumFinanceTests", "MomentumFinanceCore" (unless they belong to app?)
        # Shared SHOULD belong to App.

        file_refs = re.findall(
            r"([A-Fa-f0-9]{24})\s/\*\s(.*?)\s\*/\s=\s\{isa = PBXFileReference;.*?path = (.*?);",
            content,
        )

        files_to_add = []

        for file_ref_id, comment_name, file_path in file_refs:
            if not file_path.endswith(".swift"):
                continue

            # Simple heuristic for App files:
            # - Starts with Shared/
            # - Starts with App/
            # - Starts with Features/
            # - Or just does NOT start with MomentumFinanceTests/ or MomentumFinanceCore/

            # Note: file_path is relative to group usually.
            # Groups might be nested.
            # But let's assume we want to correct specifically KNOWN misconfigurations.
            # BudgetsView.swift is in Shared/Features/Budgets/BudgetsView.swift
            # In pbxproj, path might be just "BudgetsView.swift" if inside a group.

            # If path is just filename, we assume it belongs to the group it's in.
            # But regex doesn't capture group structure easily.

            # However, file_path usually has directory if sourceTree is SOURCE_ROOT.
            # If sourceTree is <group>, path is just filename.

            # Let's filter by checking if it's already in the BuildFile list for THIS target?
            # No, we need to know if it SHOULD be in the target.

            # If we blindly add ALL missing Swift files (except Tests/Core), we might over-add.
            # But that's better than under-adding.

            if "Tests" in comment_name or "Test" in file_path:
                continue
            if "MomentumFinanceCore" in file_path:
                continue

            # Check if likely an App file
            # BudgetsView.swift

            # Check if this file ref is already linked to a BuildFile
            # ... fileRef = ID ...
            # Wait, a fileRef can be linked to multiple targets (Core and App).
            # So just checking "if f'fileRef = {file_ref_id}' in content" is WRONG.
            # We need to checking if it is linked to a BuildFile THAT IS IN THE SOURCES PHASE of THIS target.

            # Step 3a: Get all BuildFile IDs in Sources Phase
            phase_regex_str = (
                re.escape(sources_phase_id)
                + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
            )
            phase_match = re.search(phase_regex_str, content, re.DOTALL)
            existing_build_files = []
            if phase_match:
                block = phase_match.group(1)
                existing_build_files = re.findall(r"([A-Fa-f0-9]{24})", block)

            if "BudgetsView.swift" in comment_name:
                print(f"DEBUG: Checking BudgetsView.swift. Ref: {file_ref_id}")

            # Step 3b: For each existing build file, find its fileRef
            is_already_added = False
            for bfid in existing_build_files:
                # find definition of bfid
                # bfid ... fileRef = file_ref_id
                if (
                    f"{bfid} /* {comment_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id}"
                    in content
                ):
                    is_already_added = True
                    if "BudgetsView.swift" in comment_name:
                        print("DEBUG: BudgetsView matches exact definition")
                    break
                # Relaxed check
                if f"{bfid}" in content and f"fileRef = {file_ref_id}" in content:
                    # This is risky text search.
                    if re.search(
                        re.escape(bfid) + r".*?fileRef = " + re.escape(file_ref_id),
                        content,
                    ):
                        is_already_added = True
                        if "BudgetsView.swift" in comment_name:
                            print("DEBUG: BudgetsView matches relaxed definition")
                        break

            if is_already_added:
                if "BudgetsView.swift" in comment_name:
                    print("DEBUG: BudgetsView skipped because already added")
                continue

            if "BudgetsView.swift" in comment_name:
                print("DEBUG: BudgetsView is NOT already added. Checking disk...")

            # It is NOT added. Should we add it?
            # Check file existence to avoid ghosts

            likely_path = None
            search_dirs = [
                "MomentumFinance/Shared",
                "MomentumFinance/App",
                "MomentumFinance/Features",
                "MomentumFinance/Views",
                "MomentumFinance/Models",
            ]

            fname = os.path.basename(file_path)

            found_on_disk = False
            for d in search_dirs:
                for root, _, files in os.walk(d):
                    if fname in files:
                        found_on_disk = True
                        if "BudgetsView.swift" in comment_name:
                            print(f"DEBUG: BudgetsView found on disk at {root}/{fname}")
                        break
                if found_on_disk:
                    break

            if found_on_disk:
                files_to_add.append((file_ref_id, comment_name))
                print(f"Will add missing file: {comment_name}")
            else:
                if "BudgetsView.swift" in comment_name:
                    print("DEBUG: BudgetsView NOT found on disk in search dirs")

        print(
            f"Found {len(files_to_add)} files that need to be added to the App target."
        )

        if len(files_to_add) == 0:
            print("No files to add.")
            return

        # 4. Modify Content
        # Same logic as add_tests_to_target

        lines = content.split("\n")
        new_lines = []
        in_build_file_section = False
        added_definitions = False

        build_files_to_add_to_phase = []

        for line in lines:
            if "/* Begin PBXBuildFile section */" in line:
                new_lines.append(line)
                in_build_file_section = True
                continue

            if in_build_file_section and not added_definitions:
                for file_ref_id, comment_name in files_to_add:
                    build_file_id = generate_id()
                    build_files_to_add_to_phase.append((build_file_id, comment_name))
                    definition = f"\t\t{build_file_id} /* {comment_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {comment_name} */; }};"
                    new_lines.append(definition)
                added_definitions = True

            if "/* End PBXBuildFile section */" in line:
                in_build_file_section = False

            new_lines.append(line)

        final_content = "\n".join(new_lines)

        # Add to Sources phase
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

            for build_file_id, comment_name in build_files_to_add_to_phase:
                new_files_block += (
                    f"\t\t\t\t{build_file_id} /* {comment_name} in Sources */,\n"
                )

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
        print(f"Script Error: {e}")
        import traceback

        traceback.print_exc()


add_app_files()
