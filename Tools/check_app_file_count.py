import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_name = "MomentumFinance"


def check_count():
    try:
        with open(project_path) as f:
            content = f.read()

        # Find Target
        target_id = None
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if f"/* {target_name} */ = {{" in line:
                if (
                    i + 1 < len(lines)
                    and "isa = PBXNativeTarget;" in lines[i + 1].strip()
                ):
                    target_id = line.strip().split(" ")[0]
                    break

        if not target_id:
            print("Error: Target not found")
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
        if not match:
            print("Error finding phases")
            return

        build_phases_block = match.group(1)
        phase_ids = re.findall(r"([A-Fa-f0-9]{24})", build_phases_block)

        sources_phase_id = None
        for pid in phase_ids:
            if f"{pid} /* Sources */ =" in content:
                sources_phase_id = pid
                break

        if not sources_phase_id:
            print("Error: Sources phase not found")
            return

        # Count files
        phase_regex_str = (
            re.escape(sources_phase_id)
            + r"\s/\*\sSources\s\*/\s=\s\{.*?files\s=\s\((.*?)\);"
        )
        phase_match = re.search(phase_regex_str, content, re.DOTALL)

        count = 0
        if phase_match:
            block = phase_match.group(1)
            ids = re.findall(r"([A-Fa-f0-9]{24})", block)
            count = len(ids)

        print(f"App Target Source Files Count: {count}")

    except Exception as e:
        print(f"Error: {e}")


check_count()
