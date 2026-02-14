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

print("Filtering lines via filename substring match...")
new_lines = []
removed_count = 0

for line in lines:
    should_remove = False
    for filename in files_to_remove:
        # Match matches /* Filename */ or path = Filename or /* Filename in Sources */
        # We want to be sure it's the file reference, not a comment in a script?
        # But pbxproj control lines usually use standard formatting.
        if filename in line:
            # check if it looks like a pbxproj reference line
            if "/*" in line and "*/" in line:
                should_remove = True
                break
            if "path =" in line:
                should_remove = True
                break
            # potentially Dangerous: what if "import Transaction.swift" is in a shell script phase?
            # Shell script phases in pbxproj are escaped strings.
            # But normally we don't import swift files in shell scripts inside pbxproj.

    if should_remove:
        removed_count += 1
        continue

    new_lines.append(line)

print(f"Removed {removed_count} lines.")
print("Writing back to file...")

with open(project_path, "w") as f:
    f.writelines(new_lines)

print("Done.")
