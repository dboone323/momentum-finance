#!/usr/bin/env python3
import os

test_dir = "MomentumFinance/MomentumFinanceTests"


def wrap_files():
    for root, dirs, files in os.walk(test_dir):
        for file in files:
            if "MacOS" in file and file.endswith(".swift"):
                path = os.path.join(root, file)
                try:
                    with open(path) as f:
                        content = f.read()

                    if "#if os(macOS)" in content:
                        print(f"Skipping {file} (already wrapped)")
                        continue

                    print(f"Wrapping {file}")
                    new_content = "#if os(macOS)\n" + content + "\n#endif\n"

                    with open(path, "w") as f:
                        f.write(new_content)
                except Exception as e:
                    print(f"Error processing {file}: {e}")


wrap_files()
