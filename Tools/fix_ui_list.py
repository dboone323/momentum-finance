#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
list_id = "C5629EBF403F3E1586134C6F"
new_ids = ["9A2F66387F4C492088E0091C", "C6C11F75ABD4490AA1B72114"]


def fix_list():
    try:
        with open(project_path) as f:
            content = f.read()

        # Find Definition
        # ID /* ... */ = { ... buildConfigurations = ( ... ); ... };

        # Regex to match the List Vector inside the definition
        # Use simple anchor: ID ... buildConfigurations = (

        pattern = re.compile(
            r"(" + re.escape(list_id) + r".*?buildConfigurations = \()(.*?)(\);)",
            re.DOTALL,
        )
        match = pattern.search(content)

        if not match:
            print("Definition not found via regex.")
            # Maybe comment mismatch?
            # Try searching just ID + = {
            return

        print("Found Definition.")

        # Construct new list items
        # 9A... /* Debug */,
        # C6... /* Release */,

        new_items = "\n"
        new_items += f"\t\t\t\t{new_ids[0]} /* Debug */,\n"
        new_items += f"\t\t\t\t{new_ids[1]} /* Release */,\n"

        # Replace
        new_content = content[: match.start(2)] + new_items + content[match.end(2) :]

        with open(project_path, "w") as f:
            f.write(new_content)

        print("List updated.")

    except Exception as e:
        print(f"Error: {e}")


fix_list()
