#!/usr/bin/env python3
import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinanceTests"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def add_tests_to_target():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Find the Sources Build Phase ID for the Target
        # Find Target (robust regex)
        # Match: ID /* TargetName */ = { ... isa = PBXNativeTarget;
        target_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\s"
            + re.escape(target_name)
            + r"\s\*/\s=\s\{\s+isa\s=\sPBXNativeTarget;",
            re.DOTALL | re.VERBOSE,
        )

        # Searching line by line is safer than regex on whole file sometimes
        lines = content.split("\n")
        target_id = None
        for i, line in enumerate(lines):
            if f"/* {target_name} */ = {{" in line:
                # Check next line for isa = PBXNativeTarget
                if (
                    i + 1 < len(lines)
                    and "isa = PBXNativeTarget;" in lines[i + 1].strip()
                ):
                    target_id = line.strip().split(" ")[0]
                    break

        if not target_id:
            # Try searching for the hardcoded ID we found
            if "A0TEST112F0ABCDE00000001" in content:
                target_id = "A0TEST112F0ABCDE00000001"
            else:
                print(f"Error: Target {target_name} not found.")
                return

        print(f"Target ID: {target_id}")

        # Find buildPhases
        target_section_regex = re.compile(
            re.escape(target_id)
            + r"\s/\*\s"
            + re.escape(target_name)
            + r"\s\*/\s=\s\{.*?buildPhases\s=\s\((.*?)\);",
            re.DOTALL,
        )
        target_section_match = target_section_regex.search(content)
        if not target_section_match:
            print("Could not find target definition section")
            return

        build_phases_content = target_section_match.group(1)
        phase_ids = re.findall(r"([A-Fa-f0-9]{24})", build_phases_content)

        sources_phase_id = None
        for phase_id in phase_ids:
            phase_def_regex = re.compile(
                re.escape(phase_id)
                + r"\s/\*\sSources\s\*/\s=\s\{.*?isa = PBXSourcesBuildPhase;",
                re.DOTALL,
            )
            if phase_def_regex.search(content):
                sources_phase_id = phase_id
                print(f"Found Sources Build Phase: {sources_phase_id}")
                break

        if not sources_phase_id:
            # Try hardcoded Sources ID if discovery fails (we saw it in grep)
            if "A0TEST122F0ABCDE00000001" in content:
                sources_phase_id = "A0TEST122F0ABCDE00000001"
                print(f"Used hardcoded Sources Build Phase ID: {sources_phase_id}")
            else:
                print("Error: Could not find Sources Build Phase")
                return

        # 2. Find all Swift files in MomentumFinanceTests that have FileRefs
        # We look for FileRefs with path starting with MomentumFinanceTests/
        # AND check if they are already in build files

        # Regex to find all file refs in MomentumFinanceTests
        # 03C00A6B484F48479A15CA1B /* MacOS_UI_EnhancementsTests.swift */ = {isa = PBXFileReference; ... path = MomentumFinanceTests/MacOS_UI_EnhancementsTests.swift; ...
        file_refs = re.findall(
            r"([A-Fa-f0-9]{24})\s/\*\s(.*?)\s\*/\s=\s\{isa = PBXFileReference;.*?path = MomentumFinanceTests/(.*?);",
            content,
        )

        import os  # Ensure os is imported

        print(f"Found {len(file_refs)} file references in MomentumFinanceTests group.")

        files_to_add = []
        for file_ref_id, comment_name, file_path in file_refs:
            if not file_path.endswith(".swift"):
                continue

            # Check for file existence on disk
            # Path is relative to project or group path. Usually group path is MomentumFinanceTests
            full_path = os.path.join(
                "MomentumFinance/MomentumFinanceTests", os.path.basename(file_path)
            )
            # Note: file_path from regex might just be basename or relative path.
            # Regex was: match = re.findall(..., path = MomentumFinanceTests/(.*?);)
            # So file_path is just the filename.

            if not os.path.exists(full_path):
                print(f"Skipping ghost file: {full_path}")
                continue

            # Check if this file ref is already linked to a BuildFile
            if f"fileRef = {file_ref_id}" not in content:
                files_to_add.append((file_ref_id, comment_name))

        print(f"Found {len(files_to_add)} files that need to be added to the target.")

        if len(files_to_add) == 0:
            print("No files to add.")
            return

        # 3. Modify content
        # We need to add PBXBuildFile definitions
        # And add them to the Sources phase

        lines = content.split("\n")
        new_lines = []

        # Insert PBXBuildFile definitions before the end of PBXBuildFile section
        # Or easier: just insert them at the beginning of PBXBuildFile section
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

            # Find the Sources Build Phase files list start
            if f"{sources_phase_id} /* Sources */ =" in line:
                new_lines.append(line)
                continue

            # Add files to the phase
            # checking if we are inside the files = ( ) block of the sources phase
            # This is hard to track line by line statefully without complex logic.
            # Simpler: Detect the line "files = (" inside the phase block?
            # Actually, standard format is:
            # ID /* Sources */ = {
            #    ...
            #    files = (
            #        ID /* ... */,

            new_lines.append(line)

        # Re-processing to add to files = ()
        # Since I can't easily stream-edit the files list with simple loop above because of nesting context
        # I'll join and use regex replace for the files list

        final_content = "\n".join(new_lines)

        # Regex to find the files list of the sources phase
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

            # Replace the block
            # Be careful with regex replacement of special chars

            # Construct the replacement manually
            start_idx = phase_match.start(1)
            end_idx = phase_match.end(1)
            final_content = (
                final_content[:start_idx] + new_files_block + final_content[end_idx:]
            )

            with open(project_path, "w") as f:
                f.write(final_content)
            print("Successfully updated project.pbxproj")

        else:
            print("Error: Could not locate files list in sources phase to update.")

    except Exception as e:
        print(f"Script Error: {e}")
        import traceback

        traceback.print_exc()


add_tests_to_target()
