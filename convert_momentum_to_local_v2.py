import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
# remote_id = 'C5ECB746D5994E77B58BADED' - from step 822

print(f"Reading {project_path}...")
with open(project_path, "r") as f:
    content = f.read()

# 1. Replace XCRemoteSwiftPackageReference section with XCLocalSwiftPackageReference
# Find the block
remote_section = re.search(
    r"/\* Begin XCRemoteSwiftPackageReference section \*/(.*)/\*, End XCRemoteSwiftPackageReference section \*/",
    content,
    re.DOTALL,
)
if remote_section:
    print("Found Remote Section. Replacing...")
    # We want to replace the definition of C5ECB...
    # But wait, if there are other packages, we should only replace Shared-Kit.
    # The grep output showed: C5ECB... /* XCRemoteSwiftPackageReference "shared-kit" */

    # Simpler approach: Replace the specific object definition.
    pattern = r'(C5ECB746D5994E77B58BADED) /\* XCRemoteSwiftPackageReference "shared-kit" \*/ = \{[^}]+\};'
    replacement = r'\1 /* XCLocalSwiftPackageReference "../Shared-Kit" */ = {\n\t\t\tisa = XCLocalSwiftPackageReference;\n\t\t\trelativePath = "../Shared-Kit";\n\t\t};'

    new_content = re.sub(pattern, replacement, content)

    if new_content != content:
        print("Replaced object definition.")
        content = new_content
    else:
        print("Warning: Object definition not found or already replaced.")
else:
    print("Remote section not found (or maybe empty/already local?).")

# 2. Update references in packageReferences array
# The array usually lists IDs.
# "packages = ( ... )"
# references use the comment.
# C5ECB... /* XCRemoteSwiftPackageReference "shared-kit" */
# We want to change the comment too?
# Actually, comments are ignored by Xcode but good for readability.
# content = content.replace('/* XCRemoteSwiftPackageReference "shared-kit" */', '/* XCLocalSwiftPackageReference "../Shared-Kit" */')

# 3. Rename section headers if needed?
# If we change the ISA, it should move to XCLocalSwiftPackageReference section.
# But Xcode can handle it being in the "wrong" comment section as long as syntax is valid.
# Ideally, we move it. But regex moving is hard.
# Let's just change the ISA and properties in place. Xcode will re-serialize it correctly later.

# But wait, we also need to change the ISA in the object.
# The replacement above does that: `isa = XCLocalSwiftPackageReference;`

print("Updating comments...")
content = content.replace(
    '/* XCRemoteSwiftPackageReference "shared-kit" */',
    '/* XCLocalSwiftPackageReference "../Shared-Kit" */',
)

print("Writing back...")
with open(project_path, "w") as f:
    f.write(content)

print("Done.")
