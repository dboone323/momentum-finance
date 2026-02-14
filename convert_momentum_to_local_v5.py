import sys

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_id = "C5ECB746D5994E77B58BADED"

print(f"Reading {project_path}...")
with open(project_path, "r") as f:
    lines = f.readlines()

new_lines = []
skip_mode = False
brace_depth = 0
replaced = False

local_swift_package_ref_template = """\t\tC5ECB746D5994E77B58BADED /* XCLocalSwiftPackageReference "../Shared-Kit" */ = {
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = "../Shared-Kit";
\t\t};
"""

for line in lines:
    if target_id in line and " = {" in line and not skip_mode:
        if "isa = XCLocalSwiftPackageReference;" in lines[lines.index(line) + 1]:
            print("Already local.")
            new_lines.append(line)
            continue

        print(f"Found target definition: {line.strip()}")
        # Start skipping
        skip_mode = True
        brace_depth = 1  # We found one open brace '{'

        # If the line ends with '};' (single line definition?), depth becomes 0.
        # But project files are usually multiline.
        # Let's count braces in this line.
        brace_depth += (
            line.count("{") - 1
        )  # Already counted one for ' = {' logic? No, let's be strict.
        brace_depth -= line.count("}")

        if brace_depth == 0:
            # Single line definition
            skip_mode = False
            new_lines.append(local_swift_package_ref_template)
            replaced = True
        else:
            new_lines.append(local_swift_package_ref_template)
            replaced = True

    elif skip_mode:
        brace_depth += line.count("{")
        brace_depth -= line.count("}")

        if brace_depth == 0:
            skip_mode = False
            # We finished skipping the block.
            # We already appended the template.
        else:
            # Still inside block, skip line
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
