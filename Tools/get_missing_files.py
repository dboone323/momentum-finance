import sys
import os
import re
import json

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
shared_dir = "MomentumFinance/Shared"


def get_missing():
    try:
        with open(project_path, "r") as f:
            content = f.read()

        existing_filenames = set()
        file_refs = re.findall(r"path = (.*?);", content)
        for p in file_refs:
            existing_filenames.add(os.path.basename(p.replace('"', "")))

        files_on_disk = []
        for root, dirs, files in os.walk(shared_dir):
            for file in files:
                if file.endswith(".swift"):
                    rel_dir = os.path.relpath(root, shared_dir)
                    if rel_dir == ".":
                        rel_dir = ""

                    files_on_disk.append(
                        {
                            "name": file,
                            "path": os.path.join(rel_dir, file),
                            "full_path": os.path.join(root, file),
                        }
                    )

        missing = []
        for item in files_on_disk:
            if item["name"] not in existing_filenames:
                missing.append(item)

        print(f"Found {len(missing)} missing files.")

        with open("missing_files.json", "w") as f:
            json.dump(missing, f, indent=2)

    except Exception as e:
        print(f"Error: {e}")


get_missing()
