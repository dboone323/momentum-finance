import sys
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_id = "C5629EBF403F3E1586134C6F"


def cleanup():
    try:
        with open(project_path, "r") as f:
            content = f.read()

        # Split content into definitions
        # Hard to split accurately.
        # But we can find indices of `ID = {`.

        # Regex find iter
        pattern = re.compile(re.escape(target_id) + r" /\*.*?\*/ = \{", re.DOTALL)
        matches = list(pattern.finditer(content))

        print(f"Found {len(matches)} definitions for {target_id}")

        if len(matches) < 2:
            print("Less than 2 definitions found. Aborting.")
            return

        # Identify which one is BAD.
        # Check content after match.

        bad_match = None

        for m in matches:
            start = m.start()
            # Scan until `};`.
            end = content.find("};", start)
            block = content[start : end + 2]

            if "E391BA524FCC71844E1B6741" in block:
                print("Found BAD block (contains E39...)")
                bad_match = (start, end + 2)
            elif "9A2F66387F4C492088E0091C" in block:
                print("Found GOOD block (contains 9A2F...)")
            else:
                print("Found Unknown block.")

        if bad_match:
            print("Removing BAD block...")
            start, end = bad_match
            # Remove from content
            content = content[:start] + content[end:]

            with open(project_path, "w") as f:
                f.write(content)
            print("Cleanup complete.")
        else:
            print("No BAD block identified to remove.")

    except Exception as e:
        print(f"Error: {e}")


cleanup()
