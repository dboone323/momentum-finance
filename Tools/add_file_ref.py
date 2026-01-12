import re
import uuid

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
file_path = "MomentumFinance/Shared/Intelligence/FinancialMLModels.swift"
file_name = "FinancialMLModels.swift"


def generate_id():
    return uuid.uuid4().hex[:24].upper()


def add_ref():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Create File Ref
        fid = generate_id()
        # path relative to group? If linked to Shared Group (path=Shared).
        # File is at Shared/Intelligence/File.
        # If we put in Shared Group. Path should be Intelligence/File?
        # Or if Shared Group has path="MomentumFinance/Shared"?
        # Then path="Intelligence/FinancialMLModels.swift".

        # Determine Shared Group Path
        # ID /* Shared */ = { ... path = Shared; ... };
        # Assume path is "Shared" (Relative to project root "MomentumFinance"? No, project file is in MomentumFinance.xcodeproj).
        # Source Root is "MomentumFinance".
        # Shared is "MomentumFinance/Shared".

        # Let's set path relative to PROJECT ROOT (SOURCE_ROOT).
        # path = MomentumFinance/Shared/Intelligence/FinancialMLModels.swift;
        # sourceTree = SOURCE_ROOT;

        ref_def = f"\t\t{fid} /* {file_name} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = {file_path}; sourceTree = SOURCE_ROOT; }};\n"

        # Insert into PBXFileReference section
        if "/* Begin PBXFileReference section */" not in content:
            print("Error: FileRef section not found.")
            return

        insert_idx = (
            content.find("/* Begin PBXFileReference section */")
            + len("/* Begin PBXFileReference section */")
            + 1
        )
        content = content[:insert_idx] + ref_def + content[insert_idx:]

        # 2. Add to Shared Group
        # Find Shared Group ID
        # ID /* Shared */ = { ... children = ( ... );

        group_regex = re.compile(
            r"([A-Fa-f0-9]{24})\s/\*\sShared\s\*/\s=\s\{.*?children\s=\s\((.*?)\);",
            re.DOTALL,
        )
        match = group_regex.search(content)
        if not match:
            print("Shared Group not found.")
            return

        group_id = match.group(1)
        children_block = match.group(2)

        # Add FID to children
        new_children = children_block
        if not new_children.endswith("\n"):
            new_children += "\n"
        new_children += f"\t\t\t\t{fid} /* {file_name} */,\n"

        start = match.start(2)
        end = match.end(2)

        content = content[:start] + new_children + content[end:]

        with open(project_path, "w") as f:
            f.write(content)

        print("Added File Reference.")

    except Exception as e:
        print(f"Error: {e}")


add_ref()
