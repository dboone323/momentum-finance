@testable import MomentumFinance
import XCTest

class ReportsSectionTests: XCTestCase {
    var reportsSection: ReportsSection!

    // Test filteredTransactions method
    func testFilteredTransactions() {
        let expectedTransactions = [
            FinancialTransaction(date: Date(), transactionType: .income, amount: 100.0),
            FinancialTransaction(date: Date(), transactionType: .expense, amount: -50.0)
        ]

        XCTAssertEqual(reportsSection.filteredTransactions, expectedTransactions)
    }

    // Test currentPeriodBudgets method
    func testCurrentPeriodBudgets() {
        let expectedBudgets = [
            Budget(month: "January", totalAmount: 1000.0),
            Budget(month: "February", totalAmount: 800.0)
        ]

        XCTAssertEqual(reportsSection.currentPeriodBudgets, expectedBudgets)
    }

    // Test FinancialSummaryCard
    func testFinancialSummaryCard() {
        let expectedTitle = "Financial Summary - This Month"
        let expectedIncomeText = "$150.00"
        let expectedExpenseText = "-$50.00"
        let expectedNetIncomeText = "$100.00"

        XCTAssertEqual(reportsSection.title, expectedTitle)
        XCTAssertEqual(reportsSection.incomeText, expectedIncomeText)
        XCTAssertEqual(reportsSection.expenseText, expectedExpenseText)
        XCTAssertEqual(reportsSection.netIncomeText, expectedNetIncomeText)
    }

    // Test SpendingByCategoryCard
    func testSpendingByCategoryCard() {
        let expectedCategories = [
            ExpenseCategory(name: "Food", amountSpent: 300.0),
            ExpenseCategory(name: "Transportation", amountSpent: 200.0)
        ]

        XCTAssertEqual(reportsSection.categories, expectedCategories)
    }

    // Test BudgetPerformanceCard
    func testBudgetPerformanceCard() {
        let expectedBudgets = [
            Budget(month: "January", totalAmount: 1000.0),
            Budget(month: "February", totalAmount: 800.0)
        ]

        XCTAssertEqual(reportsSection.budgets, expectedBudgets)
    }
}
