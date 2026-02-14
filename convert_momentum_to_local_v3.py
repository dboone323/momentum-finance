import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
# remote_id = 'C5ECB746D5994E77B58BADED'

print(f"Reading {project_path}...")
with open(project_path, "r") as f:
    content = f.read()

# Debug: Print the section if found manually
start_marker = "/* Begin XCRemoteSwiftPackageReference section */"
end_marker = "/* End XCRemoteSwiftPackageReference section */"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    print(f"Found section at {start_idx} to {end_idx}")
    section_content = content[start_idx : end_idx + len(end_marker)]
    print(f"Section content:\n{section_content}")

    # Construct replacement
    # We want exactly:
    # /* Begin XCLocalSwiftPackageReference section */
    # C5ECB746D5994E77B58BADED /* XCLocalSwiftPackageReference "../Shared-Kit" */ = {
    #     isa = XCLocalSwiftPackageReference;
    #     relativePath = "../Shared-Kit";
    # };
    # /* End XCLocalSwiftPackageReference section */

    # We will invoke a REPLACE on the whole block.
    # Note: If XCLocalSwiftPackageReference section ALREADY exists, we should merge.
    # But usually it doesn't default exist if only remote packages were used.
    # Let's check if XCLocalSwiftPackageReference exists.

    local_marker = "/* Begin XCLocalSwiftPackageReference section */"
    if local_marker in content:
        print("XCLocalSwiftPackageReference section already exists. Appending to it.")
        # Logic to append is harder.
        # simpler: just change the remote definition to local definition IN PLACE,
        # but keep it in the "Remote" commented section (Xcode will fix it later).
        # OR rename the section headers if we are replacing the ONLY item.
        pass
    else:
        print("Creating XCLocalSwiftPackageReference section by renaming Remote section headers.")

    replacement = section_content.replace(
        "XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference"
    )
    replacement = replacement.replace(
        'repositoryURL = "https://github.com/dboone323/Shared-Kit.git";',
        'relativePath = "../Shared-Kit";',
    )
    replacement = replacement.replace("requirement = {", "")
    replacement = replacement.replace("kind = upToNextMajorVersion;", "")
    replacement = replacement.replace("minimumVersion = 1.0.0;", "")
    replacement = replacement.replace("};", "};")  # Cleanup closing brace if needed?
    # Actually, the structure of Remote is:
    # {
    #   isa = XCRemoteSwiftPackageReference;
    #   repositoryURL = "...";
    #   requirement = {
    #      kind = ...;
    #      minimumVersion = ...;
    #   };
    # };

    # Local structure:
    # {
    #   isa = XCLocalSwiftPackageReference;
    #   relativePath = "...";
    # };

    # Let's just Regex replace the INSIDE of the definition.
    # Pattern to match the object body.
    # C5ECB... = { ... };

    pattern = r'(C5ECB746D5994E77B58BADED) /\* XCRemoteSwiftPackageReference "shared-kit" \*/ = \{[^}]+\};'
    obj_replacement = r'\1 /* XCLocalSwiftPackageReference "../Shared-Kit" */ = {\n\t\t\tisa = XCLocalSwiftPackageReference;\n\t\t\trelativePath = "../Shared-Kit";\n\t\t};'

    new_section_content = re.sub(pattern, obj_replacement, section_content)

    # Rename headers
    new_section_content = new_section_content.replace(
        "Begin XCRemoteSwiftPackageReference section", "Begin XCLocalSwiftPackageReference section"
    )
    new_section_content = new_section_content.replace(
        "End XCRemoteSwiftPackageReference section", "End XCLocalSwiftPackageReference section"
    )

    content = content.replace(section_content, new_section_content)
    print("Replaced section.")

else:
    print("Section markers not found.")

# Update references
print("Updating references...")
content = content.replace(
    '/* XCRemoteSwiftPackageReference "shared-kit" */',
    '/* XCLocalSwiftPackageReference "../Shared-Kit" */',
)

print("Writing back...")
with open(project_path, "w") as f:
    f.write(content)

print("Done.")
