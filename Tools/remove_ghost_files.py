import sys
import re
import os

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinanceTests"


def remove_ghost_files():
    try:
        with open(project_path, "r") as f:
            content = f.read()

        # 1. Find Sources Build Phase ID
        # MomentumFinance App Sources Phase: 6B1A2B242C0D1E8F00123456
        # MomentumFinanceTests Sources Phase: A0TEST122F0ABCDE00000001
        sources_phase_id = "A0TEST122F0ABCDE00000001"  # Changed to Test Sources ID
        target_sources_ids = ["6B1A2B242C0D1E8F00123456", "A0TEST122F0ABCDE00000001"]
        if sources_phase_id + " /* Sources */ =" not in content:
            # Try to find it again regex
            # ... regex search ...
            pass  # Assume for now or fail

        print(f"Checking Sources Build Phase: {sources_phase_id}")

        # Extract files block
        phase_regex_str = (
            re.escape(sources_phase_id)
            + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
        )
        phase_match = re.search(phase_regex_str, content, re.DOTALL)

        if not phase_match:
            print("Error: Could not find files block in sources phase.")
            return

        files_block = phase_match.group(1)
        # Extract all build file IDs: ID /* Name in Sources */
        build_file_ids = re.findall(r"([A-Fa-f0-9]{24})", files_block)

        print(f"Found {len(build_file_ids)} build files in sources phase.")

        ghost_build_ids = []

        for build_id in build_file_ids:
            # Find definition: build_id ... fileRef = file_ref_id
            build_def_regex = re.compile(
                re.escape(build_id) + r".*?fileRef\s=\s([A-Fa-f0-9]{24})"
            )
            build_match = build_def_regex.search(content)

            if not build_match:
                # Might be a proxy or something else
                continue

            file_ref_id = build_match.group(1)

            # Find FileRef definition: file_ref_id ... path = PATH
            file_ref_regex = re.compile(re.escape(file_ref_id) + r".*?path\s=\s(.*?);")
            file_ref_match = file_ref_regex.search(content)

            if file_ref_match:
                path = file_ref_match.group(1).replace('"', "")  # Clean quotes

                # Resolving path relative to project group structure is hard purely from pbxproj
                # But typically MomentumFinanceTests files are in "MomentumFinanceTests/"
                # If path doesn't start with /, check relative

                full_path = path
                if not os.path.isabs(path):
                    # Try assuming it's in MomentumFinance/MomentumFinanceTests/ path logic
                    # Or check relative to "MomentumFinance" root
                    potential_paths = [
                        os.path.join("MomentumFinance", path),
                        os.path.join(
                            "MomentumFinance/MomentumFinanceTests",
                            os.path.basename(path),
                        ),
                    ]

                    found = False
                    for p in potential_paths:
                        if os.path.exists(p):
                            found = True
                            full_path = p
                            break

                    if not found:
                        # It might be ghost
                        # Double check simple path
                        if os.path.exists(path):
                            found = True
                            full_path = path

                    if not found:
                        print(
                            f"Found Ghost File: {path} (ID: {build_id}, Ref: {file_ref_id})"
                        )
                        ghost_build_ids.append(build_id)

        print(f"Identified {len(ghost_build_ids)} ghost files to remove.")

        if len(ghost_build_ids) == 0:
            print("No ghost files found.")
            return

        # Removing ghost files
        new_content = content

        # 1. Remove from files = () block
        # We replace the specific lines
        # Regex replacement could be dangerous globaly, so target the phase block

        # Simpler: Read content into lines, filter lines out
        lines = content.split("\n")
        new_lines = []

        # Also need to remove the PBXBuildFile definition lines

        for line in lines:
            # Check if line contains a ghost build ID
            is_ghost_line = False
            for ghost_id in ghost_build_ids:
                if ghost_id in line:
                    # Be careful not to verify too broadly
                    # Delete definition: ghost_id ... = {isa = PBXBuildFile...
                    # Delete reference in files: ghost_id /* ... */,

                    if f"{ghost_id} /*" in line:  # Reference with comment
                        is_ghost_line = True
                        break

            if not is_ghost_line:
                new_lines.append(line)

        final_content = "\n".join(new_lines)

        with open(project_path, "w") as f:
            f.write(final_content)

        print("Successfully removed ghost files from project.pbxproj")

    except Exception as e:
        print(f"Error: {e}")


remove_ghost_files()
