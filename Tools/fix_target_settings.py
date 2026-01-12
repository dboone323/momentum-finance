import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix_settings():
    try:
        with open(project_path) as f:
            content = f.read()

        # Helper to find target by name
        # PBXNativeTarget section
        # ID /* Name */ = { ... name = Name; ... buildConfigurationList = ListID; ... };

        # Hardcoded ID from grep (Step 2594)
        unit_test_list_id = "A0TEST192F0ABCDE00000001"

        # UI Test ID from previous run (Step 2591)
        ui_test_list_id = "C5629EBF403F3E1586134C6F"

        print(f"Unit Test List: {unit_test_list_id}")
        print(f"UI Test List: {ui_test_list_id}")

        if not unit_test_list_id:
            print("Unit Test Target not found.")
            return

        # Helper to get configs from list
        def get_configs(list_id):
            # ID /* Build configuration list ... */ = { ... buildConfigurations = ( ID1, ID2, );
            pattern = re.compile(
                re.escape(list_id) + r".*?buildConfigurations = \((.*?)\);", re.DOTALL
            )
            match = pattern.search(content)
            if match:
                return re.findall(r"([A-Fa-f0-9]{24})", match.group(1))
            return []

        unit_configs = get_configs(unit_test_list_id)
        ui_configs = get_configs(ui_test_list_id) if ui_test_list_id else []

        print(f"Unit Configs: {unit_configs}")
        print(f"UI Configs: {ui_configs}")

        # Modify Content
        # We process line by line or replace by ID block?
        # Replace by ID is safer.

        new_content = content

        # For Unit Tests: Set TEST_HOST
        host_val = '"$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/MomentumFinance"'
        loader_val = '"$(TEST_HOST)"'

        for cid in unit_configs:
            # Find the block for this config
            # ID /* ... */ = { ... buildSettings = { ... };
            # We want to INSERT or REPLACE TEST_HOST inside buildSettings.

            # Regex to find buildSettings block for this ID
            # pattern: ID ... buildSettings = {(.*?)};
            # We replace content of buildSettings? No, partial update.

            # Easier: Find `TEST_HOST = ...;` inside the block?
            # Or just replace `TEST_HOST = ...` if we correspond to the ID.

            # Let's verify finding the line `TEST_HOST = ...` that belongs to cid.
            # Only if we can identify the block range.

            # Hack: `fix_test_host.py` set ALL to `host_val`.
            # So currently Unit Tests match `host_val`.
            # UI Tests match `host_val`.

            # So checks are "Update to Empty" for UI, "Update to Value" for Unit.
            # If current is Value, Unit is fine.
            # We must fix UI.
            pass

        # For UI Tests: Clear TEST_HOST
        for cid in ui_configs:
            # Find block
            # Regex: `CID .*? buildSettings = \{`
            # Then Scan until `};`
            # Replace `TEST_HOST = "...";` with `TEST_HOST = "";`? Or remove line?
            # Remove `BUNDLE_LOADER` too.

            # We use a loop over regex matches of Config Definitions?
            pass

        # Implementation:
        # 1. Create mapping of ConfigID -> TargetType (Unit/UI/Other).
        # 2. Iterate all definitions in file.
        # 3. If definition ID matches mapping, modify content.

        mapping = {}
        for cid in unit_configs:
            mapping[cid] = "UNIT"
        for cid in ui_configs:
            mapping[cid] = "UI"

        lines = content.split("\n")
        final_lines = []

        current_config = None
        in_build_settings = False

        for line in lines:
            # Check if line starts definition `ID /* ... */ = {`
            match = re.search(r"^\s*([A-Fa-f0-9]{24}) /\*.*?\*/ = \{", line)
            if match:
                current_config = mapping.get(match.group(1))
                in_build_settings = False  # Reset

            if "buildSettings = {" in line:
                in_build_settings = True

            if current_config == "UI" and in_build_settings:
                # Remove TEST_HOST / BUNDLE_LOADER
                if "TEST_HOST =" in line:
                    continue  # Skip line (Delete)
                if "BUNDLE_LOADER =" in line:
                    continue

            if current_config == "UNIT" and in_build_settings:
                # Check if TEST_HOST present.
                # If `fix_test_host` ran, it is present.
                # If duplicate?
                pass

            if "};" in line and in_build_settings:
                in_build_settings = False
                current_config = None

            final_lines.append(line)

        # Wait. For UNIT tests, if I removed `TEST_HOST` lines (like with UI logic), I need to ADD them?
        # But `fix_test_host.py` added them (replaced empty).
        # So they exist.
        # But if `fix_test_host.py` made duplicates? No, replace.

        # So Unit Tests are fine (Assuming `fix_test_host` worked).
        # UI Tests have WRONG value.
        # So removing lines from UI config is correct.

        # Also need to remove BUNDLE_LOADER from UI.

        final_content = "\n".join(final_lines)

        with open(project_path, "w") as f:
            f.write(final_content)

        print("Fixed target settings.")

    except Exception as e:
        print(f"Error: {e}")


fix_settings()
