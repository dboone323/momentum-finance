#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_ids = ["9A2F66387F4C492088E0091C", "C6C11F75ABD4490AA1B72114"]


def repair():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        new_lines = []
        for _, line in enumerate(lines):
            new_lines.append(line)
            # Check if this line is the END of one of our target definitions.
            # My logic in clone_configs wrote `new_def` as a single string?
            # No, `chunk = "\n".join(new_definitions)`.
            # But `new_body` contained newlines.
            # So `f.write` wrote multiple lines.

            # The regex capture ended at `};`.
            # So the last line of the block ends with `};`.

            # How to identify it's the last line of OUR block?
            # We can scan backwards from line to find ID? Hard.

            # Better: Read file into string.
            # Search for ID.
            # Scan chars.
            pass

        # String approach
        with open(project_path) as f:
            content = f.read()

        for tid in target_ids:
            # Find start index
            start_marker = f"{tid} /*"
            start_idx = content.find(start_marker)
            if start_idx == -1:
                print(f"ID {tid} not found.")
                continue

            # Scan forward counting braces
            # Count starts at 0.
            # Found `{` -> count=1.
            # Found inner `{` -> count=2.
            # Found inner `}` -> count=1.
            # Found outer `}` -> count=0. (Should be end)

            curr = start_idx
            brace_count = 0
            found_start = False

            # We scan until we hit "/* End XCBuildConfiguration section */" or something?
            # Or just enough to see unbalance.

            while curr < len(content):
                c = content[curr]
                if c == "{":
                    brace_count += 1
                    found_start = True
                elif c == "}":
                    brace_count -= 1

                curr += 1

                if found_start and brace_count == 0:
                    # Balanced.
                    # Verify if this is truly the end?
                    # If my regex stopped early, it stopped at inner `}`.
                    # So brace_count reaches 0 (because we started after outer `{`?)
                    # No, we start scan from `ID = `.
                    # First char we find is `{`. Count=1.
                    # Inner `buildSettings = {`. Count=2.
                    # Inner `... };`. Count=1.
                    # Regex STOPPED here.
                    # So text content ends here?
                    # Resulting text in file: `... };\n` (Next ID).

                    # So if text ends at }; and brace_count is 1.
                    # Then we are missing a brace.

                    # But how do I know "Text ends"?
                    # Look at next chars.
                    # likely newline, then tab, then Next ID or End Section.

                    # Scan ahead looking for next ID or End Section.
                    pass

                if c == "\n":
                    # Check if next line looks like new definition?
                    remaining = content[curr:].lstrip()
                    if remaining.startswith("/* End") or re.match(
                        r"[A-Fa-f0-9]{24} /\*", remaining
                    ):
                        # We hit end of block.
                        # Check balance.
                        if brace_count > 0:
                            print(
                                f"ID {tid} unbalanced (Count {brace_count}). Appending diff."
                            )
                            # insert braces
                            insertion = "};" * brace_count
                            content = content[:curr] + insertion + content[curr:]
                            break
                        else:
                            print(f"ID {tid} seems balanced.")
                            break

        with open(project_path, "w") as f:
            f.write(content)

        print("Repair complete.")

    except Exception as e:
        print(f"Error: {e}")


repair()
