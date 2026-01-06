import os
import re

test_dir = "MomentumFinance/MomentumFinanceTests"


def fix_tests():
    files = [f for f in os.listdir(test_dir) if f.endswith(".swift")]

    class_definitions = {}  # class_name -> [files]

    for f in files:
        path = os.path.join(test_dir, f)
        with open(path, "r") as file:
            content = file.read()

        # 1. Fix Missing SwiftData import
        if "ModelContext" in content or "@Model" in content:
            if "import SwiftData" not in content:
                print(f"Adding import SwiftData to {f}")
                # Add after import XCTest or first import
                lines = content.split("\n")
                new_lines = []
                imported = False
                for line in lines:
                    new_lines.append(line)
                    if line.startswith("import ") and not imported:
                        new_lines.append("import SwiftData")
                        imported = True

                with open(path, "w") as file:
                    file.write("\n".join(new_lines))
                content = "\n".join(new_lines)  # Update content for next check

        # 2. Check for duplicate class names
        class_regex = re.compile(r"class\s+([A-Za-z0-9_]+)\s*:")
        match = class_regex.search(content)
        if match:
            class_name = match.group(1)
            if class_name not in class_definitions:
                class_definitions[class_name] = []
            class_definitions[class_name].append(f)

    # Resolve duplicates
    for class_name, file_list in class_definitions.items():
        if len(file_list) > 1:
            print(f"Duplicate class {class_name} found in: {file_list}")
            # Rename class in the second/third files
            for i in range(1, len(file_list)):
                duplicate_file = file_list[i]
                new_class_name = f"{class_name}_Duplicate{i}"
                if "SpendingTests" in duplicate_file:
                    new_class_name = f"{class_name}Spending"

                print(f"Renaming {class_name} to {new_class_name} in {duplicate_file}")

                path = os.path.join(test_dir, duplicate_file)
                with open(path, "r") as file:
                    content = file.read()

                new_content = re.sub(
                    r"class\s+" + class_name + r"\s*:",
                    f"class {new_class_name}:",
                    content,
                )

                with open(path, "w") as file:
                    file.write(new_content)


fix_tests()
