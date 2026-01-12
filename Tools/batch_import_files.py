import json
import os
import re
import shutil
import subprocess
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
backup_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj.import_backup"
missing_json = "missing_files.json"
limit = 20


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def run_plutil():
    try:
        subprocess.check_call(
            ["plutil", "-lint", project_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except subprocess.CalledProcessError:
        return False


def batch_import():
    # 1. Load missing
    if not os.path.exists(missing_json):
        print("missing_files.json not found.")
        return

    with open(missing_json) as f:
        all_missing = json.load(f)

    # Check current project state to filter valid "missing"
    with open(project_path) as f:
        current_content = f.read()

    existing_refs = set(re.findall(r"/\* (.*?) \*/", current_content))

    candidates = []
    for item in all_missing:
        # Check by name.
        # Note: comment matching is fuzzy but generally works for unique filenames.
        if item["name"] not in existing_refs:
            candidates.append(item)

    if not candidates:
        print("No more missing files to import.")
        return

    to_add = candidates[:limit]
    print(f"Attempting to add {len(to_add)} files...")

    # 2. Backup
    shutil.copyfile(project_path, backup_path)

    try:
        # Prepare content
        new_filerefs = []
        new_buildfiles = []
        new_shared_children = []
        new_sources_files = []

        # Build Data
        for item in to_add:
            fid = generate_id()
            bid = generate_id()
            name = item["name"]
            path = item["path"]  # relative
            escaped_path = f'"{path}"'

            # PBXFileReference
            # ID /* name */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "path"; sourceTree = "<group>"; };
            fr = f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {escaped_path}; sourceTree = "<group>"; }};'
            new_filerefs.append(fr)

            # PBXBuildFile
            # ID /* name in Sources */ = {isa = PBXBuildFile; fileRef = ID /* name */; };
            bf = f"\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};"
            new_buildfiles.append(bf)

            # Shared Group Child
            # ID /* name */,
            sg = f"\t\t\t\t{fid} /* {name} */,"
            new_shared_children.append(sg)

            # Sources Phase File
            # ID /* name in Sources */,
            sp = f"\t\t\t\t{bid} /* {name} in Sources */,"
            new_sources_files.append(sp)

        # 3. Apply changes (String manipulation)
        content = current_content

        # Insert FileRefs
        # Search for /* End PBXFileReference section */
        # Insert BEFORE
        idx = content.find("/* End PBXFileReference section */")
        if idx == -1:
            raise Exception("End PBXFileReference not found")
        content = content[:idx] + "\n".join(new_filerefs) + "\n" + content[idx:]

        # Insert BuildFiles
        # Search for /* End PBXBuildFile section */
        idx = content.find("/* End PBXBuildFile section */")
        if idx == -1:
            raise Exception("End PBXBuildFile not found")
        content = content[:idx] + "\n".join(new_buildfiles) + "\n" + content[idx:]

        # Insert Shared Children
        # Find 6B1A2B3E2C0D1E9100123456 then children = (
        match = re.search(
            r"(6B1A2B3E2C0D1E9100123456 /\* Shared \*/ = \{.*?children = \()",
            content,
            re.DOTALL,
        )
        if not match:
            raise Exception("Shared group children start not found")
        end_idx = match.end()  # Just after `(`
        # Insert newline and items
        chunk = "\n" + "\n".join(new_shared_children)
        content = content[:end_idx] + chunk + content[end_idx:]

        # Insert Sources Phase Files
        # Find 6B1A2B242C0D1E8F00123456 then files = (
        match = re.search(
            r"(6B1A2B242C0D1E8F00123456 /\* Sources \*/ = \{.*?files = \()(.*?)(\);)",
            content,
            re.DOTALL,
        )
        if not match:
            raise Exception("Sources phase files pattern not found")
        # We replace the content to be safe regarding commas?
        # No, just insert at Start (after `(`) similar to Shared

        # Wait, if previous files list was empty `( )`?
        # `files = (` -> invalid? `files = ( )`
        # regex above `files = \(` matches `(`.

        end_idx = match.start(2)  # Start of inner content
        # Note: regex group 2 matches inner content. end_idx is index after `(`

        # Insert
        chunk = "\n" + "\n".join(new_sources_files)
        content = content[:end_idx] + chunk + content[end_idx:]

        # 4. Write
        with open(project_path, "w") as f:
            f.write(content)

        print("Written changes.")

        # 5. Verify
        if run_plutil():
            print("Integrity check passed.")
        else:
            print("Integrity check FAILED. Rolling back.")
            shutil.copyfile(backup_path, project_path)

    except Exception as e:
        print(f"Error during import: {e}")
        print("Rolling back.")
        shutil.copyfile(backup_path, project_path)


batch_import()
