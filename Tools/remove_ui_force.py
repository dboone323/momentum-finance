import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_id = "63292F885ECCB953E9ABA700"


def remove_force():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Remove Definition
        # ID /* Name */ = { ... };

        # Regex finding start
        start_pattern = re.compile(re.escape(target_id) + r" /\*.*?\*/ = \{")
        match = start_pattern.search(content)
        if not match:
            print("Target Definition not found.")
            return

        start = match.start()
        # Scan for balanced brace end.
        curr = start
        braces = 0
        end = -1
        while curr < len(content):
            if content[curr] == "{":
                braces += 1
            if content[curr] == "}":
                braces -= 1
                if braces == 0:
                    # found end brace.
                    # check for ;
                    idx = curr + 1
                    while idx < len(content) and content[idx] in [" ", "\t", "\n"]:
                        idx += 1  # skip ws
                    if idx < len(content) and content[idx] == ";":
                        end = idx + 1
                    else:
                        end = curr + 1
                    break
            curr += 1

        if end != -1:
            content = content[:start] + content[end:]
            print("Removed Definition.")
        else:
            print("End of definition not found.")

        # 2. Remove List Item
        # targets = (
        #    ID /* Name */,
        # );

        # Regex match the ID line
        # Use simple string match if possible, or regex for whitespace.
        # Line usually: `\t\t\t\tID /* Name */,`

        pattern_list = re.compile(r"\s*" + re.escape(target_id) + r" /\*.*?\*/,")
        # Note: `.*` is greedy in line? No `re.DOTALL` unless specified.
        # But allow matches.

        matches = list(pattern_list.finditer(content))
        print(f"Found {len(matches)} list items.")

        # Remove them (iterate matches in reverse to preserved indices or just re-match).
        # Re-match loop
        while True:
            m = pattern_list.search(content)
            if not m:
                break
            content = content[: m.start()] + content[m.end() :]

        with open(project_path, "w") as f:
            f.write(content)

        print("Removed List Items.")

    except Exception as e:
        print(f"Error: {e}")


remove_force()
