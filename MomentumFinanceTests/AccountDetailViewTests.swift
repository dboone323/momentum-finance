@testable import MomentumFinance
import XCTest

class AccountDetailViewTests: XCTestCase {
    var account: FinancialAccount!
    var categories: [ExpenseCategory]!
    var accounts: [FinancialAccount]!

    // Test the AccountDetailView constructor
    func testAccountDetailViewInitialization() {
        let accountDetailView = AccountDetailView(
            account: self.account,
            categories: self.categories,
            accounts: self.accounts
        )

        XCTAssertEqual(accountDetailView.account, self.account)
        XCTAssertEqual(accountDetailView.categories, self.categories)
        XCTAssertEqual(accountDetailView.accounts, self.accounts)
    }

    // Test the filteredTransactions property
    func testFilteredTransactions() {
        let accountDetailView = AccountDetailView(
            account: self.account,
            categories: self.categories,
            accounts: self.accounts
        )

        XCTAssertEqual(accountDetailView.filteredTransactions.count, 2)
        XCTAssertTrue(accountDetailView.filteredTransactions[0].date >= Date().addingTimeInterval(-7 * 24 * 60 * 60))
        XCTAssertTrue(accountDetailView.filteredTransactions[1].date >= Date().addingTimeInterval(-7 * 24 * 60 * 60))
    }

    // Test the formattedCurrency method
    func testFormattedCurrency() {
        let accountDetailView = AccountDetailView(
            account: self.account,
            categories: self.categories,
            accounts: self.accounts
        )

        XCTAssertEqual(accountDetailView.formattedCurrency(500.0), "$500.00")
        XCTAssertEqual(accountDetailView.formattedCurrency(-100.0), "-$100.00")
    }

    // Test the ActivityChartView
    func testActivityChartView() {
        let accountDetailView = AccountDetailView(
            account: self.account,
            categories: self.categories,
            accounts: self.accounts
        )

        XCTAssertNil(accountDetailView.filteredTransactions.isEmpty)
        XCTAssertTrue(accountDetailView.filteredTransactions.count > 1)
    }
}
