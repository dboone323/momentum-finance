
project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix_path():
    try:
        with open(project_path) as f:
            content = f.read()

        old_path = "MomentumFinance/Shared/Intelligence/FinancialMLModels.swift"
        new_path = "Shared/Intelligence/FinancialMLModels.swift"

        if old_path in content:
            content = content.replace(old_path, new_path)
            with open(project_path, "w") as f:
                f.write(content)
            print("Path fixed.")
        else:
            print("Old path not found.")

    except Exception as e:
        print(f"Error: {e}")


fix_path()
