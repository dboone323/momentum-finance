import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
app_sources_id = "6B1A2B242C0D1E8F00123456"
core_sources_id = "A0CORE142F0ABCDE00000001"


def deduplicate():
    try:
        with open(project_path) as f:
            content = f.read()

        # Helper to get file refs from sources block
        def get_files(params_id):
            pattern = re.compile(
                re.escape(params_id) + r" /\* Sources \*/ = \{.*?files = \((.*?)\);",
                re.DOTALL,
            )
            match = pattern.search(content)
            if not match:
                return set()
            block = match.group(1)
            # Find definitions: ID /* Name in Sources */
            # We want to match by NAME or FILE_REF ID?
            # BuildFile ID is unique. FileRef ID is shared.
            # We need FileRef ID.

            # Regex to find: BuildID /* Name in Sources */ = {isa = PBXBuildFile; fileRef = THIS_ID ...

            build_ids = re.findall(r"([A-Fa-f0-9]{24})", block)
            file_ref_ids = set()
            for bid in build_ids:
                # Find definition
                def_match = re.search(
                    re.escape(bid) + r".*?fileRef = ([A-Fa-f0-9]{24})", content
                )
                if def_match:
                    file_ref_ids.add(def_match.group(1))
            return file_ref_ids

        app_refs = get_files(app_sources_id)
        core_refs = get_files(core_sources_id)

        print(f"App Sources: {len(app_refs)}")
        print(f"Core Sources: {len(core_refs)}")

        intersection = app_refs.intersection(core_refs)
        print(f"Intersection: {len(intersection)}")

        if not intersection:
            print("No duplicates found.")
            return

        # Remove BuildFiles from App Sources that verify to intersection refs
        lines = content.split("\n")
        new_lines = []

        # We need to identify BuildFile IDs in App Sources that point to intersection refs.

        # 1. Find App Sources BuildFiles
        pattern = re.compile(
            re.escape(app_sources_id) + r" /\* Sources \*/ = \{.*?files = \((.*?)\);",
            re.DOTALL,
        )
        match = pattern.search(content)
        files_block = match.group(1)
        app_build_ids = re.findall(r"([A-Fa-f0-9]{24})", files_block)

        ids_to_remove = set()
        for bid in app_build_ids:
            def_match = re.search(
                re.escape(bid) + r".*?fileRef = ([A-Fa-f0-9]{24})", content
            )
            if def_match and def_match.group(1) in intersection:
                ids_to_remove.add(bid)

        print(f"Removing {len(ids_to_remove)} duplicate build files from App Target.")

        # Remove lines
        for line in lines:
            should_remove = False
            for bid in ids_to_remove:
                if bid in line:
                    should_remove = True
                    break

            if not should_remove:
                new_lines.append(line)

        with open(project_path, "w") as f:
            f.write("\n".join(new_lines))

        print("Deduplication complete.")

    except Exception as e:
        print(f"Error: {e}")


deduplicate()
