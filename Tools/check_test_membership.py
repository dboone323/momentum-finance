import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
file_name = "BudgetsView.swift"
target_name = "MomentumFinance"


def check_membership():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Find File Reference ID
        # 03C00A6B484F48479A15CA1B /* MacOS_UI_EnhancementsTests.swift */ = {isa = PBXFileReference; ...
        file_ref_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\s"
            + re.escape(file_name)
            + r"\s\*/\s=\s{isa = PBXFileReference"
        )
        match = file_ref_regex.search(content)
        if not match:
            print(f"Error: File reference for {file_name} not found in project.")
            return

        file_ref_id = match.group(1)
        print(f"File Ref ID: {file_ref_id}")

        # 2. Find Build File ID (this links file ref to build phase)
        # A0CORE252F0ABCDE00000001 /* FinancialTransaction.swift in Sources */ = {isa = PBXBuildFile; fileRef = 6B1A2B4B2C0D1E9100123456 ...
        build_file_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\s"
            + re.escape(file_name)
            + r"\s+in\s+Sources\s\*/\s=\s{isa = PBXBuildFile;\sfileRef\s=\s"
            + file_ref_id
        )
        build_file_match = build_file_regex.search(content)

        if not build_file_match:
            print(
                f"Error: No PBXBuildFile entry found for {file_name}. It is NOT added to any target's build phase."
            )
            return

        build_file_id = build_file_match.group(1)
        print(f"Build File ID: {build_file_id}")

        # 1. Find File Reference ID
        # ... logic ...

        # 3. Check if Build File ID is in the Sources Build Phase of the Test Target
        # Find Target (robust regex)
        target_id = None
        for line in content.split("\n"):
            if f"/* {target_name} */ = {{isa = PBXNativeTarget;" in line:
                target_id = line.strip().split(" ")[0]
                break

        if not target_id:
            # Try searching by name property
            # ...
            # Just fail for now if regex/string mismatch
            # But try to be smarter
            pass

        if not target_id:
            # Fallback: Find target that HAS name = target_name
            pass
            # Actually let's assume the string format from previous success
            # /* MomentumFinance */ = {isa = PBXNativeTarget;
            pass

        # Since simple string check failed before due to whitespace or format
        # I'll use the successful logic from add_tests

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

        if not target_found:
            print(f"Error: Target {target_name} not found.")
            return

        print(f"Target ID: {target_id}")

        # Find the buildConfigurationList to confirm it matches (optional)

        # Find the buildPhases list for this target
        # isa = PBXNativeTarget; ... buildPhases = ( ... );
        # We need to extract the section for this target
        target_section_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\s"
            + re.escape(target_name)
            + r"\s\*/\s=\s\{.*?buildPhases\s=\s\((.*?)\);",
            re.DOTALL,
        )
        target_section_match = target_section_regex.search(content)

        if not target_section_match:
            print("Could not find target definition section")
            return

        build_phases_content = target_section_match.group(2)
        # Find the Sources build phase ID in this list

        # We need to iterate over phase IDs in build_phases_content
        phase_ids = re.findall(r"([A-Fa-f0-9]{24})", build_phases_content)

        found_in_compile_sources = False

        for phase_id in phase_ids:
            # Check what type of phase this is
            phase_def_regex = re.compile(
                re.escape(phase_id)
                + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);",
                re.DOTALL,
            )
            phase_match = phase_def_regex.search(content)
            if phase_match:
                print(f"Found Sources Build Phase: {phase_id}")
                files_content = phase_match.group(1)
                if build_file_id in files_content:
                    print(
                        f"SUCCESS: {file_name} IS in Compile Sources phase of {target_name}."
                    )
                    found_in_compile_sources = True
                    break

        if not found_in_compile_sources:
            print(
                f"FAILURE: {file_name} is NOT in the Compile Sources phase of {target_name}."
            )

    except Exception as e:
        print(f"Script Error: {e}")


check_membership()
