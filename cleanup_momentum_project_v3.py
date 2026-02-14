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

ids_to_remove = set()
build_ids_to_remove = set()

print("Identifying IDs via Filename Pattern...")

for line in lines:
    if "isa = PBXFileReference" in line:
        for filename in files_to_remove:
            # Check comment /* Filename */ or path = Filename
            # Regex: ID /* Filename */
            if f"/* {filename} */" in line:
                # Found candidate
                match = re.search(r"^\s*([0-9A-F]{24})\s", line)
                if match:
                    hid = match.group(1)
                    print(f"Adding FileID {hid} for {filename}")
                    ids_to_remove.add(hid)

# Now find BuildFile IDs
for line in lines:
    if "isa = PBXBuildFile" in line and "fileRef =" in line:
        for fid in ids_to_remove:
            if fid in line:
                match = re.search(r"^\s*([0-9A-F]{24})\s", line)
                if match:
                    bid = match.group(1)
                    # verify it is one of our files (comment check)
                    # usually comment is /* Filename in Sources */
                    # but if we match fileRef ID, it IS that file.
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
