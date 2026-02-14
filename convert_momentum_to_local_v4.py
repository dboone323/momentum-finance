import sys

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_id = "C5ECB746D5994E77B58BADED"

print(f"Reading {project_path}...")
with open(project_path, "r") as f:
    lines = f.readlines()

new_lines = []
skip_mode = False
replaced = False

local_swift_package_ref_template = """\t\tC5ECB746D5994E77B58BADED /* XCLocalSwiftPackageReference "../Shared-Kit" */ = {
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = "../Shared-Kit";
\t\t};
"""

for line in lines:
    if target_id in line and " = {" in line:
        if "isa = XCLocalSwiftPackageReference;" in lines[lines.index(line) + 1]:
            print("Already local.")
            new_lines.append(line)
            continue

        print(f"Found target definition: {line.strip()}")
        # Start skipping until };
        skip_mode = True
        new_lines.append(local_swift_package_ref_template)
        replaced = True
    elif skip_mode:
        if "};" in line:
            skip_mode = False
            # Don't append this line (block closing), as template includes it
        else:
            # Skipping content
            pass
    else:
        # Also fix section headers if we encounter them
        if "Begin XCRemoteSwiftPackageReference section" in line:
            new_lines.append(
                line.replace("XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference")
            )
        elif "End XCRemoteSwiftPackageReference section" in line:
            new_lines.append(
                line.replace("XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference")
            )
        else:
            new_lines.append(line)

print("Writing back...")
with open(project_path, "w") as f:
    f.writelines(new_lines)

if replaced:
    print("Successfully replaced remote reference with local reference.")
else:
    print("No replacement occurred (target not found or already local).")
