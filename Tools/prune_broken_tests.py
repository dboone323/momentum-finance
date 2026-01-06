import sys
import re

log_path = "/tmp/mom_test_macos_3.txt"
project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def prune():
    try:
        # 1. Parse Log for Filenames
        broken_files = set()
        with open(log_path, "r") as f:
            for line in f:
                if "error:" in line and "MomentumFinanceTests/" in line:
                    # Extract filename
                    # .../MomentumFinanceTests/Filename.swift:Line:Col: error: ...
                    match = re.search(
                        r"MomentumFinanceTests/([A-Za-z0-9_\.]+\.swift):", line
                    )
                    if match:
                        fname = match.group(1)
                        if fname != "FinancialMLModelsTests.swift":
                            broken_files.add(fname)
                        else:
                            print(
                                "Skipping prune for FinancialMLModelsTests.swift (Fixing instead)"
                            )

        print(f"Found {len(broken_files)} broken test files.")
        if not broken_files:
            return

        with open(project_path, "r") as f:
            content = f.read()

        # 2. Iterate Broken Files and Remove from Sources
        # Sources Phase regex?
        # Or just find `ID /* Name in Sources */`.
        # Remove definition and list item.

        removed_count = 0

        for filename in broken_files:
            # Find the Build File ID using filename in comment?
            # `ID /* Filename.swift in Sources */`

            # Regex for Definition
            # `\t\t([A-F0-9]{24}) /\* ` + re.escape(filename) + r' in Sources \*/ = \{isa = PBXBuildFile;`

            def_pattern = re.compile(
                r"\t\t([A-Fa-f0-9]{24}) /\* "
                + re.escape(filename)
                + r" in Sources \*/ = \{isa = PBXBuildFile;"
            )
            match = def_pattern.search(content)

            if match:
                bfid = match.group(1)
                # Remove Definition
                # Find End of dictionary };
                section_start = match.start()
                curr = section_start
                while curr < len(content) and content[curr] != ";":
                    curr += 1
                section_end = curr + 1
                if curr < len(content) and content[curr + 1] == "\n":
                    section_end += 1

                content = content[:section_start] + content[section_end:]

                # Remove from Sources List
                # `\t\t\t\tBFID /* Name in Sources */,`
                list_pattern = re.compile(r"\s*" + bfid + r" /\* .*? \*/,")
                content = list_pattern.sub("", content)

                removed_count += 1
                print(f"Removed {filename}")
            else:
                print(f"Could not find BuildFile for {filename}")

        with open(project_path, "w") as f:
            f.write(content)

        print(f"Pruned {removed_count} files from target.")

    except Exception as e:
        print(f"Error: {e}")


prune()
