#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def validate_assignments():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        # Regex for assignment: key = value
        # Ignoring comments.
        # But verify strict structure of pbxproj lines
        # Usually: key = value;
        # Or: key = { ... };
        # Or: key = ( ... );

        # We look for lines containing ` = `

        assignment_regex = re.compile(r'^\s*([a-zA-Z0-9_"\./]+|"[^"]+")\s*=\s*(.*)')

        for _, line in enumerate(lines):
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith("//"):
                continue  # Comment line
            if stripped.startswith("/*"):
                # /* Begin ... */
                continue

            # Check for assignment
            # Note: Many lines are just `key = value;`
            # But keys can be `ID /* comment */`

            # Simplified check: if line contains ` = `
            if " = " in stripped:
                # Exclude lines that are part of a multiline definition?
                # Usually pbxproj puts `{` on same line.

                parts = stripped.split(" = ", 1)
                value_part = parts[1]

                # Check ending
                clean_end = value_part.rstrip()
                # Remove trailing comments `/* ... */`?
                # e.g. `value; /* comment */`
                # Remove `//` comments?

                if "//" in clean_end:
                    clean_end = clean_end.split("//")[0].rstrip()
                if clean_end.endswith("*/"):
                    # Remove trailing `/* */` block
                    # This is tricky without regex.
                    # But typically pbxproj comments are `key = value; /* comment */`
                    pass

                # Check strict endings
                # If it ends with `;` -> OK
                # If it ends with `{` -> OK
                # If it ends with `(` -> OK
                # If it ends with `};` -> OK (inline dict)
                # If it ends with `);` -> OK (inline list)
                # If it ends with `,` -> It's a list item assignment? No. List items don't have `=`.

                # So any line with `=` MUST end with `;` or `{` or `(`.

                # Strip comments from end
                # Try simple heuristic: last non-whitespace character (ignoring comments)

                # Remove valid comments regex
                code_only = re.sub(r"/\*.*?\*/", "", stripped)
                code_only = code_only.split("//")[0].strip()

                if not code_only:
                    continue  # Was just a comment

                if " = " not in code_only:
                    continue  # Assignment was inside comment?

                # Re-split
                # We care about the END of the line.

                if (
                    code_only.endswith(";")
                    or code_only.endswith("{")
                    or code_only.endswith("(")
                ):
                    # Valid
                    continue

                # Invalid?
                # Check for `isa = PBXGroup` without semicolon?
                print(f"Potential missing semicolon at line {i+1}: {line.strip()}")
                print(f"  Parsed code end: '{code_only[-1] if code_only else 'EMPTY'}'")

                # Attempt Fix
                if (
                    not code_only.endswith(";")
                    and not code_only.endswith("{")
                    and not code_only.endswith("(")
                ):
                    # Add semicolon
                    # BE CAREFUL: Is it a property that needs comma?
                    # Properties in dict: `key = val;`
                    # List items: `val,` (no =)
                    # So if `=` is present, it's a property -> needs `;`.

                    print(f"FIXING line {i+1}")
                    # If original line had trailing comment, insert ; before it?
                    # Or just append ; ? matches logic `val; /* comment */` matches `val /* comment */;`?
                    # No, ; must be before comment usually.

                    # Reconstruct
                    # regex to split value and comment
                    match_val = re.match(r"(.*?)(\s*/\*.*\*/.*$| \s*//.*$|$)", stripped)
                    if match_val:
                        core = match_val.group(1).rstrip()
                        comment = match_val.group(2)
                        # Add semicolon to core
                        new_line = line[: line.find(core)] + core + ";" + comment + "\n"
                        lines[i] = new_line
                    else:
                        lines[i] = stripped + ";\n"

        with open(project_path, "w") as f:
            f.writelines(lines)

        print("Assignment check passed (and fixes applied).")

    except Exception as e:
        print(f"Error: {e}")


validate_assignments()
