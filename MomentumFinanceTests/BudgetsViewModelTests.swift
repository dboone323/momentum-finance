import XCTest
@testable import MomentumFinance

class BudgetsViewModelTests: XCTestCase {
    var viewModel: BudgetsViewModel!
    var modelContext: ModelContext!

    // Test setModelContext method
    func testSetModelContext() {
        let context = ModelContext(inMemoryOnly: true)
        viewModel.setModelContext(context)

        XCTAssertEqual(viewModel.modelContext, context)
    }

    // Test budgetsForMonth method
    func testBudgetsForMonth() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", limitAmount: 30.0, month: Date())
        let budgets = [budget1, budget2]

        let filteredBudgets = viewModel.budgetsForMonth(budgets, month: Date())

        XCTAssertEqual(filteredBudgets.count, 2)
    }

    // Test totalBudgetedAmount method
    func testTotalBudgetedAmount() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", limitAmount: 30.0, month: Date())
        let budgets = [budget1, budget2]

        let totalBudgeted = viewModel.totalBudgetedAmount(budgets, for: Date())

        XCTAssertEqual(totalBudgeted, 80.0)
    }

    // Test totalSpentAmount method
    func testTotalSpentAmount() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", spentAmount: 20.0, month: Date())
        let budgets = [budget1, budget2]

        let totalSpent = viewModel.totalSpentAmount(budgets, for: Date())

        XCTAssertEqual(totalSpent, 20.0)
    }

    // Test remainingBudget method
    func testRemainingBudget() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", spentAmount: 30.0, month: Date())
        let budgets = [budget1, budget2]

        let remaining = viewModel.remainingBudget(budgets, for: Date())

        XCTAssertEqual(remaining, 50.0)
    }

    // Test hasOverBudgetCategories method
    func testHasOverBudgetCategories() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", spentAmount: 30.0, month: Date())
        let budgets = [budget1, budget2]

        let hasOverBudget = viewModel.hasOverBudgetCategories(budgets, for: Date())

        XCTAssertEqual(hasOverBudget, false)
    }

    // Test overBudgetCategories method
    func testOverBudgetCategories() {
        let budget1 = Budget(name: "Groceries", limitAmount: 50.0, month: Date())
        let budget2 = Budget(name: "Entertainment", spentAmount: 30.0, month: Date())
        let budgets = [budget1, budget2]

        let overBudgets = viewModel.overBudgetCategories(budgets, for: Date())

        XCTAssertEqual(overBudgets.count, 0)
    }

    // Test createBudget method
    func testCreateBudget() {
        let category = ExpenseCategory(name: "Groceries")
        let limitAmount = 50.0
        let month = Date()

        viewModel.createBudget(category, limitAmount: limitAmount, month: month)

        guard let existingBudget = try? modelContext
            .fetchFirst(FetchDescriptor<Budget>(sortDescriptors: [NSSortDescriptor(
                keyPath: \.month,
                ascending: true
            )]))
        else {
            XCTFail("Budget not created")
            return
        }

        XCTAssertEqual(existingBudget.category?.name, category.name)
        XCTAssertEqual(existingBudget.limitAmount, limitAmount)
        XCTAssertEqual(existingBudget.month, month)
    }

}
