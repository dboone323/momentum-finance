import XCTest
@testable import MomentumFinance

class AccountDetailViewTests: XCTestCase {
    var account: FinancialAccount!
    var categories: [ExpenseCategory]!
    var accounts: [FinancialAccount]!

    override func setUp() {
        super.setUp()
        
        // Create mock data for testing
        let expenseCategory1 = ExpenseCategory(name: "Groceries", color: .green)
        let expenseCategory2 = ExpenseCategory(name: "Entertainment", color: .red)
        categories = [expenseCategory1, expenseCategory2]
        
        let financialAccount1 = FinancialAccount(
            name: "Checking Account",
            icon: "account.circle",
            balance: 500.0,
            transactions: [
                FinancialTransaction(date: Date(), category: expenseCategory1, amount: 300.0),
                FinancialTransaction(date: Date().addingTimeInterval(7 * 24 * 60 * 60), category: expenseCategory2, amount: 200.0)
            ]
        )
        
        let financialAccount2 = FinancialAccount(
            name: "Savings Account",
            icon: "account.circle.fill",
            balance: 1500.0,
            transactions: [
                FinancialTransaction(date: Date(), category: expenseCategory1, amount: 400.0),
                FinancialTransaction(date: Date().addingTimeInterval(7 * 24 * 60 * 60), category: expenseCategory2, amount: 300.0)
            ]
        )
        
        accounts = [financialAccount1, financialAccount2]
    }

    override func tearDown() {
        super.tearDown()
    }
    
    // Test the AccountDetailView constructor
    func testAccountDetailViewInitialization() {
        let accountDetailView = AccountDetailView(account: self.account, categories: self.categories, accounts: self.accounts)
        
        XCTAssertEqual(accountDetailView.account, self.account)
        XCTAssertEqual(accountDetailView.categories, self.categories)
        XCTAssertEqual(accountDetailView.accounts, self.accounts)
    }
    
    // Test the filteredTransactions property
    func testFilteredTransactions() {
        let accountDetailView = AccountDetailView(account: self.account, categories: self.categories, accounts: self.accounts)
        
        XCTAssertEqual(accountDetailView.filteredTransactions.count, 2)
        XCTAssertTrue(accountDetailView.filteredTransactions[0].date >= Date().addingTimeInterval(-7 * 24 * 60 * 60))
        XCTAssertTrue(accountDetailView.filteredTransactions[1].date >= Date().addingTimeInterval(-7 * 24 * 60 * 60))
    }
    
    // Test the formattedCurrency method
    func testFormattedCurrency() {
        let accountDetailView = AccountDetailView(account: self.account, categories: self.categories, accounts: self.accounts)
        
        XCTAssertEqual(accountDetailView.formattedCurrency(500.0), "$500.00")
        XCTAssertEqual(accountDetailView.formattedCurrency(-100.0), "-$100.00")
    }
    
    // Test the ActivityChartView
    func testActivityChartView() {
        let accountDetailView = AccountDetailView(account: self.account, categories: self.categories, accounts: self.accounts)
        
        XCTAssertNil(accountDetailView.filteredTransactions.isEmpty)
        XCTAssertTrue(accountDetailView.filteredTransactions.count > 1)
    }
}
