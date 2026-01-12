
project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def check():
    try:
        with open(project_path, "rb") as f:
            header = f.read(20)

        print(f"Header bytes: {header}")
        print(f"Header hex: {header.hex()}")

        if header.startswith(b"\xef\xbb\xbf"):
            print("Detected UTF-8 BOM")

        # Check for nulls
        # ...
    except Exception as e:
        print(f"Error: {e}")


check()
