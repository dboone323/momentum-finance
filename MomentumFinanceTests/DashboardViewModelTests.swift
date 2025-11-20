@testable import MomentumFinance
import XCTest

class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var modelContext: ModelContext!

    /// Test setModelContext method
    func testSetModelContext() {
        let context = ModelContext()
        viewModel.setModelContext(context)
        XCTAssertEqual(viewModel.modelContext, context)
    }

    /// Test upcomingSubscriptions method
    func testUpcomingSubscriptions() {
        // Arrange
        let subscriptions = [
            Subscription(id: 1, isActive: true, nextDueDate: Date().addingTimeInterval(3600 * 24)),
            Subscription(id: 2, isActive: false, nextDueDate: Date().addingTimeInterval(-3600 * 24))
        ]
        viewModel.setModelContext(modelContext)

        // Act
        let result = viewModel.upcomingSubscriptions(subscriptions)

        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, subscriptions[0].id)
    }

    /// Test currentMonthBudgets method
    func testCurrentMonthBudgets() {
        // Arrange
        let budgets = [
            Budget(id: 1, month: Date().addingTimeInterval(3600 * 24), amount: 100.0),
            Budget(id: 2, month: Date(), amount: -50.0)
        ]
        viewModel.setModelContext(modelContext)

        // Act
        let result = viewModel.currentMonthBudgets(budgets)

        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, budgets[0].id)
    }

    /// Test totalBalance method
    func testTotalBalance() {
        // Arrange
        let accounts = [
            FinancialAccount(id: 1, balance: 500.0),
            FinancialAccount(id: 2, balance: -300.0)
        ]
        viewModel.setModelContext(modelContext)

        // Act
        let result = viewModel.totalBalance(accounts)

        // Assert
        XCTAssertEqual(result, 200.0)
    }

    /// Test recentTransactions method
    func testRecentTransactions() {
        // Arrange
        let transactions = [
            FinancialTransaction(id: 1, date: Date().addingTimeInterval(-3600 * 24), transactionType: .expense, amount: 50.0),
            FinancialTransaction(id: 2, date: Date(), transactionType: .income, amount: 100.0)
        ]
        viewModel.setModelContext(modelContext)

        // Act
        let result = viewModel.recentTransactions(transactions)

        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, transactions[0].id)
    }

    /// Test processOverdueSubscriptions method
    func testProcessOverdueSubscriptions() {
        // Arrange
        let subscriptions = [
            Subscription(id: 1, isActive: true, nextDueDate: Date().addingTimeInterval(3600 * 24)),
            Subscription(id: 2, isActive: false, nextDueDate: Date().addingTimeInterval(-3600 * 24))
        ]
        viewModel.setModelContext(modelContext)

        // Act
        do {
            try await viewModel.processOverdueSubscriptions(subscriptions)
        } catch {
            XCTFail("Failed to process overdue subscriptions")
        }

        // Assert
        let updatedSubscriptions = modelContext.fetchAll(Subscription.self)
        XCTAssertEqual(updatedSubscriptions.count, 1)
    }

    /// Test processSubscription method
    func testProcessSubscription() {
        // Arrange
        let subscription = Subscription(id: 1, isActive: true, nextDueDate: Date().addingTimeInterval(3600 * 24))
        viewModel.setModelContext(modelContext)

        // Act
        do {
            try await viewModel.processSubscription(subscription, modelContext: modelContext)
        } catch {
            XCTFail("Failed to process subscription")
        }

        // Assert
        let updatedSubscription = modelContext.fetchOne(Subscription.self, where: \.id == subscription.id)
        XCTAssertEqual(updatedSubscription?.isActive, false)
    }

}
