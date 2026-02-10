import SwiftData
import XCTest
@testable import MomentumFinance

class SimpleDashboardViewTests: XCTestCase {
    var sut: SimpleDashboardView!
    var mockModelContext: MockModelContext!

    /// Test that the view displays a welcome message
    func test_welcomeMessage() {
        let welcomeText = "Good Morning"
        XCTAssertEqual(sut.body.description, "Welcome to your Dashboard")
    }

    /// Test that the account balances section displays the correct data
    func test_accountBalances() {
        let accounts = [
            FinancialAccount(name: "Checking", balance: 1000.50),
            FinancialAccount(name: "Savings", balance: -200.75),
        ]
        mockModelContext.accounts = accounts

        XCTAssertEqual(sut.body.description, "Account Balances\nChecking: $1,000.50\nSavings: -$200.75")
    }

    /// Test that the subscriptions section displays the correct data
    func test_subscriptions() {
        let subscriptions = [
            Subscription(name: "Monthly Rent", amount: 1500.00),
            Subscription(name: "Electricity Bill", amount: 300.00),
        ]
        mockModelContext.subscriptions = subscriptions

        XCTAssertEqual(
            sut.body.description,
            "Upcoming Subscriptions\nMonthly Rent: $1,500.00\nElectricity Bill: $300.00"
        )
    }

    /// Test that the budget progress section displays the correct data
    func test_budgetProgress() {
        let budgets = [
            Budget(name: "Rent", spentAmount: 800.00, limitAmount: 1200.00),
            Budget(name: "Groceries", spentAmount: 300.00, limitAmount: 500.00),
        ]
        mockModelContext.budgets = budgets

        XCTAssertEqual(sut.body.description, "Budget Progress\nRent: $800.00 / $1,200.00\nGroceries: $300.00 / $500.00")
    }

    /// Test that the view displays a message when no accounts are found
    func test_noAccountsFound() {
        mockModelContext.accounts = []

        XCTAssertEqual(sut.body.description, "No accounts found")
    }

    /// Test that the view displays a message when no subscriptions are found
    func test_noSubscriptionsFound() {
        mockModelContext.subscriptions = []

        XCTAssertEqual(sut.body.description, "No subscriptions found")
    }

    /// Test that the view displays a message when no budgets are found
    func test_noBudgetsFound() {
        mockModelContext.budgets = []

        XCTAssertEqual(sut.body.description, "No budgets found")
    }
}
