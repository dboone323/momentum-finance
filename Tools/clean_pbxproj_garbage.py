#!/usr/bin/env python3

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def clean_garbage():
    try:
        with open(project_path, "rb") as f:
            content = f.read()

        # Check for non-printable, non-whitespace
        # Allowed: 0x09 (tab), 0x0A (LF), 0x0D (CR), 0x20-0x7E (printable ASCII)
        # Plus UTF-8 chars?
        # pbxproj is usually ASCII. UTF-8 if needed for filenames.

        # Let's count bad bytes
        bad_indices = []
        clean_bytes = bytearray()

        for i, b in enumerate(content):
            if b < 0x20 and b not in [0x09, 0x0A, 0x0D]:
                bad_indices.append(i)
                # Skip
            elif b == 0x7F:  # DEL
                bad_indices.append(i)
                # Skip
            else:
                clean_bytes.append(b)

        if bad_indices:
            print(
                f"Found {len(bad_indices)} garbage bytes. First 10 at: {bad_indices[:10]}"
            )

            with open(project_path, "wb") as f:
                f.write(clean_bytes)
            print("Cleaned garbage bytes.")
        else:
            print("No garbage bytes found.")

    except Exception as e:
        print(f"Error: {e}")


clean_garbage()
