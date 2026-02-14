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

print(f"Reading {project_path}...")
with open(project_path, "r") as f:
    lines = f.readlines()

content = "".join(lines)

ids_to_remove = set()
build_ids_to_remove = set()

print("Identifying IDs via Regex...")
# Similar regex to before but careful
# FileRefs: ID /* Comment */ = {isa = PBXFileReference; ... path = "...Shared/...Filename"; ... };
# We look for path containing "Shared/" (or just "Shared") and the filename.
# Note: pbxproj paths often use quotes: path = "Shared/Models/Transaction.swift"
for filename in files_to_remove:
    # Safely escape filename for regex
    esc_filename = re.escape(filename)
    # Looking for a File ID that points to a path ending with filename AND containing Shared/
    # This ensures we don't pick up local files with same name.
    # Pattern explanation:
    # ([0-9A-F]{24})       Capture ID (24 hex chars)
    # .*?                  Anything (non-greedy)
    # path\s*=\s*"?        path key, equals, optional quote
    # [^";]*               Anything except quote or semicolon
    # Shared/              Specific directory constraint
    # [^";]*               Anything
    # {esc_filename}       The filename
    # "?                   Optional quote

    # Actually simpler: Look for the whole line in content?
    # No, FileRef might be single line.

    # Let's iterate lines to find IDs.
    pass

for line in lines:
    if "isa = PBXFileReference" in line and "path =" in line:
        for filename in files_to_remove:
            if f"Shared/" in line and filename in line:
                # Found a candidate line. Extract ID.
                # ID is at start of line (trimmed)
                match = re.search(r"^\s*([0-9A-F]{24})\s", line)
                if match:
                    hid = match.group(1)
                    # Double check path constraint
                    if f'/{filename}"' in line or f"/{filename};" in line:
                        print(f"Adding FileID {hid} for {filename}")
                        ids_to_remove.add(hid)

# Now find BuildFile IDs
# BuildFile: ID /* ... */ = {isa = PBXBuildFile; fileRef = FILE_ID; ... };
for line in lines:
    if "isa = PBXBuildFile" in line and "fileRef =" in line:
        for fid in ids_to_remove:
            if fid in line:
                match = re.search(r"^\s*([0-9A-F]{24})\s", line)
                if match:
                    bid = match.group(1)
                    print(f"Adding BuildID {bid} for FileID {fid}")
                    build_ids_to_remove.add(bid)

all_bad_ids = ids_to_remove.union(build_ids_to_remove)
print(f"Total IDs to remove: {len(all_bad_ids)}")

if not all_bad_ids:
    print("No IDs found. Exiting.")
    sys.exit(0)

print("Filtering lines...")
new_lines = []
removed_lines = 0

for line in lines:
    should_remove = False
    for bad_id in all_bad_ids:
        if bad_id in line:
            should_remove = True
            break

    if should_remove:
        removed_lines += 1
        # Skip this line
        continue

    new_lines.append(line)

print(f"Removed {removed_lines} lines.")
print("Writing back to file...")

with open(project_path, "w") as f:
    f.writelines(new_lines)

print("Done.")
