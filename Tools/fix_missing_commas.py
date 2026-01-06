import sys
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix_commas():
    try:
        with open(project_path, "r") as f:
            lines = f.readlines()

        new_lines = []
        in_list = False

        # Heuristic: Lists start with ` = (` and end with `);`
        # But nested lists exist?
        # project.pbxproj lists are usually simple or indented.
        # We can track parens count.

        # However, checking every line for ID pattern is safer.
        # Pattern: Whitespace + HexID(24) + Comment + Optional Comma + Whitespace

        id_regex = re.compile(r"^(\s*[A-Fa-f0-9]{24}\s/\*.*?\*/\s*)")

        for i, line in enumerate(lines):
            # Clean line ending
            stripped = line.rstrip()

            # Check if it looks like an ID line
            match = id_regex.match(stripped)
            if match:
                # It matches ID + Comment
                # Check suffix
                rest = stripped[match.end() :]
                if not rest.strip().endswith(",") and not rest.strip().endswith(";"):
                    # Missing comma or semicolon!
                    # Usually semicolon is for Definitions: ID = { ... };
                    # Comma is for List Items: ID,

                    # If it's a definition (contains =), it should end with ;
                    if "=" in rest:
                        # assume it's fine or handled elsewhere (we focus on lists)
                        if not stripped.endswith(";"):
                            # Definitions MUST end with ;
                            # But let's be careful.
                            pass
                    else:
                        # List item
                        if not stripped.endswith(","):
                            print(
                                f"Fixing missing comma at line {i+1}: {stripped.strip()}"
                            )
                            line = stripped + ",\n"

            # Also fix Line 1 if it has weird chars?
            if i == 0 and line.startswith("//"):
                # Ensure standard header
                if line.strip() != "// !$*UTF8*$!":
                    print(f"Fixing header at line 1: {line.strip()} -> // !$*UTF8*$!")
                    line = "// !$*UTF8*$!\n"

            new_lines.append(line)

        with open(project_path, "w") as f:
            f.write("".join(new_lines))

        print("Comma fix pass completed.")

    except Exception as e:
        print(f"Error: {e}")


fix_commas()
