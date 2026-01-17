#!/usr/bin/env python3

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix_shared_end():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        # Locate Shared Group
        shared_start = -1
        for i, line in enumerate(lines):
            # ID /* Shared */ = {
            if "/* Shared */ = {" in line:
                shared_start = i
                break

        if shared_start == -1:
            print("Shared group not found.")
            return

        print(f"Shared group starts at line {shared_start+1}")

        # Scan for children list end
        children_end = -1
        # It should start with `children = (`
        # We assume it follows start

        current = shared_start + 1
        found_children = False

        while current < len(lines):
            line = lines[current]
            if "children = (" in line:
                found_children = True

            if found_children and line.strip().startswith(");"):
                children_end = current
                break

            # Safety: If we hit another ID = {, we went too far
            if (
                " = {" in line and "/* Shared */" not in line
            ):  # Avoid matched start line if we backtracked? No.
                print(
                    f"Hit another object at {current+1} without finding children end."
                )
                break

            current += 1

        if children_end == -1:
            print("Could not find children list end for Shared group.")
            return

        print(
            f"Children list ends at line {children_end+1}: {lines[children_end].strip()}"
        )

        # Check next lines
        # Expecting:
        # path = Shared;
        # sourceTree = "<group>";
        # };

        # Check lines[children_end + 1]
        next_idx = children_end + 1

        insertions = []

        # Check path
        if next_idx < len(lines) and "path =" in lines[next_idx]:
            pass  # Assume valid
        else:
            print("Missing path key. Adding it.")
            insertions.append("\t\t\tpath = Shared;\n")

        # Check sourceTree (might be next or next+1)
        # Scan forward a bit? No, strict order helps.
        # But if path existed, verify it's correct?

        # Let's simple check: Does `};` exist soon?

        found_close = -1
        for j in range(next_idx, next_idx + 5):  # Check next 5 lines
            if j < len(lines) and lines[j].strip() == "};":
                found_close = j
                break

        if found_close != -1:
            print(
                f"Found closing curly at line {found_close+1}. Structure might be OK unless keys missing."
            )
            # If keys missing, we insert them before };
            # But we need to check if they effectively exist.
        else:
            print("Missing closing curly };. Fixing.")
            # We insert missing keys and close it.
            insertions.append('\t\t\tsourceTree = "<group>";\n')
            insertions.append("\t\t};\n")

        if insertions:
            # Apply insertions at next_idx (after children list end)
            for item in reversed(insertions):
                lines.insert(next_idx, item)

            with open(project_path, "w") as f:
                f.writelines(lines)
            print("Fixed Shared group structure.")
        else:
            print("No fix needed (structure seems complete).")

    except Exception as e:
        print(f"Error: {e}")


fix_shared_end()
