import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
class TransactionsViewModelTests: XCTestCase {
    var viewModel: Features.Transactions.TransactionsViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: FinancialTransaction.self,
            ExpenseCategory.self,
            FinancialAccount.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
        viewModel = Features.Transactions.TransactionsViewModel()
        viewModel.setModelContext(modelContext)
    }

    func testFilterTransactions() {
        // Arrange
        let t1 = FinancialTransaction(title: "Income", amount: 100.0, date: Date(), transactionType: .income)
        let t2 = FinancialTransaction(title: "Expense", amount: 50.0, date: Date(), transactionType: .expense)
        let transactions = [t1, t2]

        // Act
        let income = viewModel.filterTransactions(transactions, by: .income)
        let expense = viewModel.filterTransactions(transactions, by: .expense)

        // Assert
        XCTAssertEqual(income.count, 1)
        XCTAssertEqual(income.first?.title, "Income")
        XCTAssertEqual(expense.count, 1)
        XCTAssertEqual(expense.first?.title, "Expense")
    }

    func testSearchTransactions() {
        // Arrange
        let t1 = FinancialTransaction(title: "Grocery Shopping", amount: 50.0, date: Date(), transactionType: .expense)
        let t2 = FinancialTransaction(title: "Salary", amount: 2000.0, date: Date(), transactionType: .income)
        let transactions = [t1, t2]

        // Act
        let result = viewModel.searchTransactions(transactions, query: "Grocery")

        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Grocery Shopping")
    }

    func testTotalIncomeAndExpenses() {
        // Arrange
        let t1 = FinancialTransaction(title: "Income", amount: 100.0, date: Date(), transactionType: .income)
        let t2 = FinancialTransaction(title: "Expense", amount: 40.0, date: Date(), transactionType: .expense)
        let transactions = [t1, t2]

        // Act
        let income = viewModel.totalIncome(transactions)
        let expenses = viewModel.totalExpenses(transactions)
        let net = viewModel.netIncome(transactions)

        // Assert
        XCTAssertEqual(income, 100.0)
        XCTAssertEqual(expenses, 40.0)
        XCTAssertEqual(net, 60.0)
    }
}
