import XCTest
@testable import MomentumFinance

class AccountsListViewTests: XCTestCase {
    var accounts: [FinancialAccount] = [
        FinancialAccount(name: "Checking", balance: 1000.50, iconName: "account.circle.fill"),
        FinancialAccount(name: "Savings", balance: -200.75, iconName: "bank.circle.fill"),
    ]
    var categories: [ExpenseCategory] = [
        ExpenseCategory(name: "Food", color: .red),
        ExpenseCategory(name: "Transportation", color: .blue),
    ]

    func testTotalBalance() {
        let view = AccountsListView(categories: categories, accounts: accounts)
        XCTAssertEqual(view.totalBalance, 800.75) // Total balance should be the sum of all balances
    }

    func testAccountCard() throws {
        let view = AccountsListView(categories: categories, accounts: accounts)
        let account = try XCTUnwrap(accounts.first)
        let expectedTitle = "Checking"
        let expectedLastUpdated = "Last updated 1 day ago" // Example last updated date
        let expectedBalance = "$1000.50"

        XCTAssertEqual(view.accountCard(for: account).title, expectedTitle)
        XCTAssertEqual(view.accountCard(for: account).lastUpdatedText, expectedLastUpdated)
        XCTAssertEqual(view.accountCard(for: account).balanceText, expectedBalance)
    }

    func testBackgroundColorForPlatform() {
        let view = AccountsListView(categories: categories, accounts: accounts)
        XCTAssertEqual(view.backgroundColorForPlatform(), Color(UIColor.systemBackground)) // Test for iOS
        // Add more tests for macOS if needed
    }

    func testFormattedCurrency() {
        let view = AccountsListView(categories: categories, accounts: accounts)
        let expectedBalanceString = "$1000.50"
        XCTAssertEqual(view.formattedCurrency(1000.50), expectedBalanceString) // Test with positive balance
        XCTAssertEqual(view.formattedCurrency(-200.75), "-$200.75") // Test with negative balance
    }

    func testFormatDate() {
        let view = AccountsListView(categories: categories, accounts: accounts)
        let date = Date()
        let expectedLastUpdated = "Last updated 1 day ago" // Example last updated date
        XCTAssertEqual(view.formatDate(date), expectedLastUpdated) // Test with current date
    }
}
