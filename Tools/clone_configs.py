import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
ui_list_id = "C5629EBF403F3E1586134C6F"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def clone_configs():
    try:
        with open(project_path) as f:
            content = f.read()

        # Get existing config IDs from UI List
        pattern = re.compile(
            re.escape(ui_list_id) + r".*?buildConfigurations = \((.*?)\);", re.DOTALL
        )
        match = pattern.search(content)
        if not match:
            print("UI List not found.")
            return

        old_config_ids = re.findall(r"([A-Fa-f0-9]{24})", match.group(1))
        print(f"Old Configs: {old_config_ids}")

        new_config_ids = []
        new_definitions = []

        for old_id in old_config_ids:
            # Find definition
            # ID /* Name */ = { ... };
            def_pattern = re.compile(
                re.escape(old_id) + r" (/\*.*?\*/) = (\{.*?\};)", re.DOTALL
            )
            def_match = def_pattern.search(content)

            if not def_match:
                print(f"Definition for {old_id} not found.")
                continue  # Should fail

            comment = def_match.group(1)
            body = def_match.group(2)

            new_id = generate_id()
            new_config_ids.append(new_id)

            # Modify body to remove TEST_HOST / BUNDLE_LOADER
            # Remove lines with TEST_HOST
            # Regex sub inside body
            new_body = re.sub(r'TEST_HOST = ".*?";', "", body)
            new_body = re.sub(r'BUNDLE_LOADER = ".*?";', "", new_body)
            # Cleanup empty lines? or semicolons?
            # Regex sub might leave empty lines. That's fine.

            new_def = f"\t\t{new_id} {comment} = {new_body}"
            new_definitions.append(new_def)
            print(f"Cloned {old_id} -> {new_id}")

        # Insert New Definitions
        # Look for "/* End XCBuildConfiguration section */"
        insert_idx = content.find("/* End XCBuildConfiguration section */")
        if insert_idx == -1:
            raise Exception("End Section not found")

        chunk = "\n".join(new_definitions) + "\n"
        content = content[:insert_idx] + chunk + content[insert_idx:]

        # Update UI List to use New IDs
        # Replace `buildConfigurations = ( ID1, ID2, );` with New IDs.
        # We need to replace the content inside the UI List ONLY.

        # Find UI List Block
        list_pattern = re.compile(
            r"(" + re.escape(ui_list_id) + r".*?buildConfigurations = \()(.*?)(\);)",
            re.DOTALL,
        )
        list_match = list_pattern.search(content)
        if not list_match:
            raise Exception("UI List block not found")

        start = list_match.start(2)
        end = list_match.end(2)

        # Build new list string
        # ID /* Name */,
        # We invoke original names? Or comments?
        # Standard format: "\nID1 /* Name1 */,\nID2 /* Name2 */,\n"

        new_list_str = "\n"
        for i, nid in enumerate(new_config_ids):
            # Try to get comment from old ones?
            # Or assume Debug/Release order matches?
            # Old IDs list order matches.
            # We assume comment matches logic.
            # We just reused comment from definition lookup.
            # But here we need to insert comment in list item?
            # Definition lookup regex `(/\*.*?\*/)`.
            # We can reuse that string.
            pass

        # Actually, simpler: Just list of IDs. Comments are optional/nice.
        # But for correctness, pbxproj loves comments.
        # I'll try to keep comments from original list items if possible?
        # Or just append Comments from definitions I parsed.

        # Wait, I didn't store comments per ID.
        # Let's rebuild list with comments logic.

        list_content = ""
        for i, nid in enumerate(new_config_ids):
            # Find comment for old_id[i]
            old_id = old_config_ids[i]
            # Parse comment from definition again? Or reuse
            # Definition: `old_id /* Comment */ = ...`
            # I captured `comment` group(1) in loop.
            # I should have stored it.

            # Re-parse quickly
            def_pattern = re.compile(re.escape(old_id) + r" (/\*.*?\*/) =")
            m = def_pattern.search(content)  # Use OLD content (before insertion)
            # Wait, `content` variable modified.
            # But I modified insertion point (near end). definition section unchanged?
            # Yes.

            comm = m.group(1) if m else "/* Cloned Config */"
            list_content += f"\t\t\t\t{nid} {comm},\n"

        content = content[:start] + list_content + content[end:]

        with open(project_path, "w") as f:
            f.write(content)

        print("Cloning complete.")

    except Exception as e:
        print(f"Error: {e}")


clone_configs()
