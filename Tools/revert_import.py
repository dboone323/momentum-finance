import os

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
shared_dir = "MomentumFinance/Shared"


def revert_import():
    try:
        with open(project_path) as f:
            content = f.read()
            lines = content.split("\n")

        # Identify files we likely added
        # We scanned Shared dir.
        # heuristic: any PBXFileReference with path matching file in Shared/

        files_on_disk = []
        for root, dirs, files in os.walk(shared_dir):
            for file in files:
                if file.endswith(".swift"):
                    files_on_disk.append(file)

        files_to_remove = set(files_on_disk)

        # We need to be careful not to remove ORIGINAL files.
        # But wait, original files HAD FileRefs.
        # My import script only added files that DID NOT match existing FileRefs.
        # How do I distinguish?
        # I can't easily.

        # Alternative: Revert based on invalid syntax?
        # Or revert only if I can confirm duplicates?

        # If I remove ALL references to these files, I might remove valid ones too if name collisions exist.
        # But 147 files were "missing". So removing them returns to "missing" state.

        # Let's remove lines containing "RootSearchEngineService.swift" etc.
        # Filter content.

        # BUT identifying exact lines is risky.

        # Strategy:
        # 1. Back up current corruption.
        # 2. Filter out lines that look like:
        #    ID /* fname */ = {isa = PBXFileReference ... }
        #    ID /* fname in Sources */ = {isa = PBXBuildFile ... }
        #    ID /* fname */,  (in children list)
        #    ID /* fname in Sources */, (in sources list)

        # Only for fnames that were in my "missing" list?
        # I don't recall the exact missing list.

        # Let's try aggressive filtering of KNOWN missing files from previous run log?
        # "CategoriesGenerator.swift", "AccountsGenerator.swift"... (Step 2133).
        # Those were App files added.
        # Step 2190 added 147 files.

        # If I filter out lines containing matches for `files_to_remove`?
        # This will remove valid files too if they exist.
        # This is destructive.

        # Better: Try to verify syntax again.
        # validate_pbxproj said structure is valid.

        # Maybe I just delete the last 500 lines?
        # No, file is structured by sections.

        print("Revert strategy is too risky without accurate history. Aborting revert.")

    except Exception as e:
        print(f"Error: {e}")


revert_import()
