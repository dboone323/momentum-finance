import sys

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
start_line = 892


def inspect():
    try:
        with open(project_path, "r") as f:
            lines = f.readlines()

        # 0-indexed
        idx = start_line - 1

        count = 0
        limit = 400

        while idx < len(lines) and count < limit:
            line = lines[idx]
            print(f"{idx+1}: {line}", end="")

            if line.strip() == "};":
                # Check indentation? Usually tab char.
                if line.startswith("\t\t};"):  # sub-object
                    pass
                elif line.startswith("\t};"):  # group object
                    print("Found Group closing brace.")
                    break

            idx += 1
            count += 1

    except Exception as e:
        print(f"Error: {e}")


inspect()
