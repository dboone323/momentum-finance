
project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def cleanup():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        new_lines = []
        removed = 0
        for line in lines:
            # Check for orphaned fileRef lines
            # usually ` fileRef = ... };`
            if line.strip().startswith("fileRef = ") and line.strip().endswith("};"):
                removed += 1
                continue
            new_lines.append(line)

        print(f"Removed {removed} broken lines.")

        with open(project_path, "w") as f:
            f.writelines(new_lines)

    except Exception as e:
        print(f"Error: {e}")


cleanup()
