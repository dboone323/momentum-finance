#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def empty_shared_children():
    try:
        with open(project_path) as f:
            content = f.read()

        # Regex for Shared group children
        # 6B1A2B3E2C0D1E9100123456 /* Shared */ = { ... children = ( ... );

        # We need to match precise block
        # We know ID: 6B1A2B3E2C0D1E9100123456

        pattern = re.compile(
            r"(6B1A2B3E2C0D1E9100123456 /\* Shared \*/ = \{.*?children = \()(.*?)(\);)",
            re.DOTALL,
        )

        match = pattern.search(content)
        if match:
            print("Found Shared children block.")
            # Replace group(2) (content) with empty

            start, end = match.span(2)
            new_content = content[:start] + "\n" + content[end:]

            with open(project_path, "w") as f:
                f.write(new_content)
            print("Emptied Shared children list.")
        else:
            print("Could not find Shared children pattern.")

    except Exception as e:
        print(f"Error: {e}")


empty_shared_children()
