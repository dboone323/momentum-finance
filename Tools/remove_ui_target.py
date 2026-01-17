#!/usr/bin/env python3
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
ui_target_native_id = "19735777653E1DD174AA3D92"  # From Step 2651
ui_target_dependency_id = ""  # Need to find PBXTargetDependency ID pointing to it?
# Or just remove NativeTarget definition and references.


def remove_ui():
    try:
        with open(project_path) as f:
            content = f.read()

        # 1. Remove NativeTarget Definition
        # ID /* Name */ = { ... };
        # Regex block removal

        # Native ID might vary if I didn't grep it fresh.
        # But grep 2651 showed it as dependency of UI Config List?
        # No, Config List is dependency OF Target.
        # Target ID is KEY for Config List usage.

        # Step 2651 output:
        # dependencies = ( 19735777653E1DD174AA3D92 /* PBXTargetDependency */, );
        # This is dependency of WHAT?
        # Typically App depends on UI Tests? No.
        # Tests depend on App? Yes.

        # Let's find UI Target ID by name.
        pattern = re.compile(
            r"([A-Fa-f0-9]{24}) /\* MomentumFinanceUITests \*/ = \{.*?isa = PBXNativeTarget;",
            re.DOTALL,
        )
        match = pattern.search(content)
        if not match:
            print("UI Target not found by name.")
            return

        target_id = match.group(1)
        print(f"UI Target ID: {target_id}")

        # Remove Definition block
        # Scan braces
        start = match.start()
        # Find ending `};`;
        # Simple scan
        curr = start
        braces = 0
        end = -1
        while curr < len(content):
            if content[curr] == "{":
                braces += 1
            if content[curr] == "}":
                braces -= 1
                if braces == 0:
                    end = curr + 1  # Include ;
                    # Checks for ;
                    if curr + 1 < len(content) and content[curr + 1] == ";":
                        end += 1
                    break
            curr += 1

        if end != -1:
            # Remove
            content = content[:start] + content[end:]
            print("Removed Target Definition.")
        else:
            print("Failed to find end of target definition.")

        # 2. Remove Reference from Project `targets` list.
        # Find `targets = ( ... ID ... );`
        # Regex replace `ID ,` or `ID`
        content = re.sub(re.escape(target_id) + r" /\*.*?\*/,", "", content)
        content = re.sub(re.escape(target_id) + r" /\*.*?\*/", "", content)  # Last item

        print("Removed from targets list.")

        with open(project_path, "w") as f:
            f.write(content)

        print("UI Target Removed.")

    except Exception as e:
        print(f"Error: {e}")


remove_ui()
