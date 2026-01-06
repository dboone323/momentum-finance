#!/usr/bin/env python3
"""
Fix TEST_HOST for macOS by adding platform-specific override.
On macOS: .app/Contents/MacOS/ExecutableName
On iOS: .app/ExecutableName
"""
import re

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def fix():
    with open(project_path, "r") as f:
        content = f.read()

    # Find TEST_HOST lines and add macOS-specific override after each one
    # We need to add: TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/Contents/MacOS/MomentumFinance";
    # But only for sdk=macosx

    # Replace the iOS-style TEST_HOST with a conditional version
    ios_test_host = (
        'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/MomentumFinance";'
    )
    macos_test_host = 'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/Contents/MacOS/MomentumFinance";'

    # Actually, the proper Xcode way is to use build setting conditions
    # But that's complex in pbxproj. Simpler solution: use $(TEST_HOST) variable
    # that Xcode will resolve correctly if we use the standard path.

    # The real issue: Xcode uses different bundle structures.
    # Best approach: Use $(BUILT_PRODUCTS_DIR)/$(BUNDLE_LOADER_BASENAME).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/$(BUNDLE_LOADER_BASENAME)
    # Or use: "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MomentumFinance"

    # Actually simplest: just use the variable that Xcode understands:
    # "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/$(EXECUTABLE_FOLDER_PATH)/MomentumFinance"
    # But EXECUTABLE_FOLDER_PATH may not exist...

    # Let's try a different approach - remove the explicit path and use automatic resolution
    # by setting TEST_HOST to empty and letting Xcode derive it from TEST_TARGET_NAME

    # Actually the real fix: on macOS the app bundle has Contents/MacOS/
    # So we need: "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/$(CONTENTS_FOLDER_PATH)/MacOS/MomentumFinance"
    # Where CONTENTS_FOLDER_PATH is "Contents" on macOS or empty on iOS

    # Simplest pragmatic fix for a multi-platform app:
    # TEST_HOST = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/$(EXECUTABLE_PATH:dir)/MomentumFinance";
    # Hmm that's complex too.

    # Best solution: Add conditional build setting
    # "TEST_HOST[sdk=iphoneos*]" = ...iOS path...
    # "TEST_HOST[sdk=iphonesimulator*]" = ...iOS path...
    # "TEST_HOST[sdk=macosx*]" = ...macOS path...

    # Let's add the macOS conditional after each TEST_HOST line
    pattern = r'(\s+)(TEST_HOST = "\$\(BUILT_PRODUCTS_DIR\)/MomentumFinance\.app/MomentumFinance";)'

    def add_macos_override(match):
        indent = match.group(1)
        ios_line = match.group(2)
        # Add macOS conditional on the next line
        macos_line = f'"TEST_HOST[sdk=macosx*]" = "$(BUILT_PRODUCTS_DIR)/MomentumFinance.app/Contents/MacOS/MomentumFinance";'
        return f"{indent}{ios_line}\n{indent}{macos_line}"

    new_content = re.sub(pattern, add_macos_override, content)

    # Count replacements
    count = len(re.findall(pattern, content))

    with open(project_path, "w") as f:
        f.write(new_content)

    print(f"Added {count} macOS TEST_HOST overrides")


fix()
