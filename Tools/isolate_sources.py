import sys
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def empty_sources_files():
    try:
        with open(project_path, "r") as f:
            content = f.read()

        # Regex for Sources phase files
        # 6B1A2B242C0D1E8F00123456 /* Sources */ = { ... files = ( ... );

        pattern = re.compile(
            r"(6B1A2B242C0D1E8F00123456 /\* Sources \*/ = \{.*?files = \()(.*?)(\);)",
            re.DOTALL,
        )

        match = pattern.search(content)
        if match:
            print("Found Sources files block.")
            start, end = match.span(2)
            new_content = content[:start] + "\n" + content[end:]

            with open(project_path, "w") as f:
                f.write(new_content)
            print("Emptied Sources files list.")
        else:
            print("Could not find Sources files pattern.")

    except Exception as e:
        print(f"Error: {e}")


empty_sources_files()
