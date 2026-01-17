#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix_settings():
    try:
        with open(project_path) as f:
            content = f.read()

        # We need to find the XCBuildConfiguration blocks for MomentumFinanceTests.
        # This is hard without parsing graph.
        # But we know the target name "MomentumFinanceTests".
        # We can look for `buildSettings = { ... TEST_HOST = ""; ... }`?

        # Regex to match build settings block containing "MomentumFinanceTests" (maybe in comment?)
        # Or look for known Test Configuration IDs if available.
        # Step 2572 grep showed `TEST_HOST = "";`.

        # We can verify replace ALL `TEST_HOST = "";` with correct value?
        # But we must be careful not to break other targets (if they have empty HOST).
        # MomentumFinance (App) doesn't use TEST_HOST.
        # MomentumFinanceCore doesn't.
        # Only Tests should have it.
        # So replacing ALL occurrences is reasonably safe IF they are the only ones.

        # Value:
        # TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/MomentumFinance";
        # BUNDLE_LOADER = "$(TEST_HOST)";

        # Also need to add BUNDLE_LOADER if missing.

        # Let's replace `TEST_HOST = "";` with the 2 lines.

        new_val = 'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/MomentumFinance";\n\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";'

        # Regex replacement
        new_content = re.sub(r'TEST_HOST = "";', new_val, content)

        if new_content == content:
            print("No TEST_HOST found to replace.")
        else:
            print("Replaced TEST_HOST.")

        with open(project_path, "w") as f:
            f.write(new_content)

    except Exception as e:
        print(f"Error: {e}")


fix_settings()
