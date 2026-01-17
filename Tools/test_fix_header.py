#!/usr/bin/env python3

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def wipe_header():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        # Replace line 0 with empty
        lines[0] = "\n"

        with open(project_path, "w") as f:
            f.writelines(lines)

        print("Wiped header line 1.")

    except Exception as e:
        print(f"Error: {e}")


wipe_header()
