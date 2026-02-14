import re
import sys

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"

files_to_remove = [
    "TransactionsGenerator.swift",
    "SavingsGoalsGenerator.swift",
    "BudgetsGenerator.swift",
    "AccountsGenerator.swift",
    "CategoriesGenerator.swift",
    "ExportTypes.swift",
    "ErrorHandler.swift",
    "Logger.swift",
    "ComplexDataGenerators.swift",
    "SampleDataProviders.swift",
    "SampleDataGenerators.swift",
    "SampleData.swift",
    "SavingsGoal.swift",
    "Subscription.swift",
    "Budget.swift",
    "FinancialTransaction.swift",
    "ExpenseCategory.swift",
    "Category.swift",
    "Transaction.swift",
    "FinancialAccount.swift",
    "SearchTypes.swift",
    "SearchEngineService.swift",
    "TransactionFilter.swift",
    "FinancialInsightModels.swift",
    "ImportExport.swift",
]

with open(project_path, "r") as f:
    content = f.read()

ids_to_remove = set()
build_ids_to_remove = set()

# Step 1: Find File IDs
print("Finding File IDs...")
for filename in files_to_remove:
    # Regex to find FileRef ID for the filename, assuming it's in Shared path
    # ID /* Comment */ = {isa = PBXFileReference; ... path = "Shared/.../Filename"; ... };
    # Note: path might be relative or absolute, but error log said Shared/...
    # We look for path containing "Shared/" and ending with filename

    # Simple regex: ID followed by anything, then path = "...Shared/...filename"
    pattern = re.compile(
        r'([0-9A-F]{24})\s*/\*.*?\*/\s*=\s*\{[^}]*?path\s*=\s*"?.*Shared/.*?'
        + re.escape(filename)
        + r'"?[^}]*?\};',
        re.DOTALL,
    )

    matches = pattern.findall(content)
    for hid in matches:
        print(f"Found FileRef ID for {filename}: {hid}")
        ids_to_remove.add(hid)

# Step 2: Find BuildFile IDs referencing these File IDs
print("Finding BuildFile IDs...")
# BuildFile definition: ID /* ... */ = {isa = PBXBuildFile; fileRef = FILE_ID; ... };
for file_id in ids_to_remove:
    pattern = re.compile(
        r"([0-9A-F]{24})\s*/\*.*?\*/\s*=\s*\{[^}]*?fileRef\s*=\s*"
        + re.escape(file_id)
        + r"\b[^}]*?\};",
        re.DOTALL,
    )
    matches = pattern.findall(content)
    for hid in matches:
        print(f"Found BuildFile ID for FileID {file_id}: {hid}")
        build_ids_to_remove.add(hid)

all_ids = ids_to_remove.union(build_ids_to_remove)
print(f"Total IDs to remove: {len(all_ids)}")

if not all_ids:
    print("No IDs found. Check if files are already removed or paths differ.")
    # Fallback: Search for filenames without "Shared/" constraint but confirm with user?
    # Or strict "match filename in comment" if path logic fails?
    # Let's rely on path first.
    sys.exit(0)

# Step 3: Remove lines/sections
new_lines = []
lines = content.split("\n")
skip_until_brace = False
deleted_count = 0

# Strategy:
# 1. Remove definitions (blocks or single lines).
# 2. Remove references in lists (single lines).

# Since pbxproj is line-oriented mostly (except definitions sometimes multiline),
# we need to be careful.
# Definitions:
# ID = { ... };
# We can regex replace definitions in the whole string.

current_content = content

# Remove definitions
for hid in all_ids:
    # Regex for definition: ID ... = { ... };
    # Matches greedy up to first };
    def_pattern = re.compile(r"\s*" + re.escape(hid) + r"\s*/\*.*?\*/\s*=\s*\{[^}]*?\};", re.DOTALL)
    current_content = def_pattern.sub("", current_content)

# Remove references in lists
# List items: ID /* ... */,
for hid in all_ids:
    list_pattern = re.compile(r"\s*" + re.escape(hid) + r"\s*/\*.*?\*/,")
    current_content = list_pattern.sub("", current_content)

# Verify we verify PBXGroup "Shared" is empty?
# If we remove all children, the group remains empty. That's fine.

with open(project_path, "w") as f:
    f.write(current_content)

print("Done.")
