import XCTest
@testable import MomentumFinance

class TransactionsViewTests: XCTestCase {
    var transactions: [FinancialTransaction] = []
    var categories: [ExpenseCategory] = []
    var accounts: [FinancialAccount] = []

    override func setUp() {
        super.setUp()
        
        // Initialize test data
        let transaction1 = FinancialTransaction(
            id: UUID(),
            title: "Salary",
            amount: 5000.0,
            category: ExpenseCategory(name: "Income"),
            account: FinancialAccount(name: "Payroll", balance: 20000.0)
        )
        
        let transaction2 = FinancialTransaction(
            id: UUID(),
            title: "Groceries",
            amount: 150.0,
            category: ExpenseCategory(name: "Food"),
            account: FinancialAccount(name: "Grocery Store", balance: 3000.0)
        )
        
        let transaction3 = FinancialTransaction(
            id: UUID(),
            title: "Travel",
            amount: 800.0,
            category: ExpenseCategory(name: "Transportation"),
            account: FinancialAccount(name: "Airline", balance: 12000.0)
        )
        
        self.transactions = [transaction1, transaction2, transaction3]
        self.categories = [
            ExpenseCategory(name: "Income"),
            ExpenseCategory(name: "Food"),
            ExpenseCategory(name: "Transportation")
        ]
        self.accounts = [
            FinancialAccount(name: "Payroll", balance: 20000.0),
            FinancialAccount(name: "Grocery Store", balance: 3000.0),
            FinancialAccount(name: "Airline", balance: 12000.0)
        ]
    }

    override func tearDown() {
        super.tearDown()
        
        // Clean up test data
        self.transactions.removeAll()
        self.categories.removeAll()
        self.accounts.removeAll()
    }
    
    func testHeaderSection() {
        let view = TransactionsView(
            transactions: self.transactions,
            onTransactionTapped: { _ in },
            onDeleteTransaction: { _ in }
        )
        
        // Assert that the header section displays the correct title and stats
        XCTAssertEqual(view.headerSection.title, "Transactions")
        XCTAssertEqual(view.headerSection.stats.balance, 20000.0)
    }
    
    func testSearchAndFilterSection() {
        let view = TransactionsView(
            transactions: self.transactions,
            onTransactionTapped: { _ in },
            onDeleteTransaction: { _ in }
        )
        
        // Assert that the search and filter section displays the correct filters
        XCTAssertEqual(view.searchAndFilterSection.selectedFilter, .all)
        XCTAssertTrue(view.searchAndFilterSection.showingSearch)
    }
    
    func testAddTransactionButton() {
        let view = TransactionsView(
            transactions: self.transactions,
            onTransactionTapped: { _ in },
            onDeleteTransaction: { _ in }
        )
        
        // Assert that the add transaction button is displayed
        XCTAssertTrue(view.toolbarContent.contains(where: { $0.type == .primaryAction }))
    }
    
    func testDeleteTransaction() {
        let view = TransactionsView(
            transactions: self.transactions,
            onTransactionTapped: { _ in },
            onDeleteTransaction: { _ in }
        )
        
        // Assert that the delete transaction action is handled correctly
        let transaction = FinancialTransaction(
            id: UUID(),
            title: "Salary",
            amount: 5000.0,
            category: ExpenseCategory(name: "Income"),
            account: FinancialAccount(name: "Payroll", balance: 20000.0)
        )
        
        view.deleteTransaction(transaction)
        
        // Assert that the transaction is deleted from the model context
        XCTAssertFalse(self.transactions.contains(transaction))
    }
}
