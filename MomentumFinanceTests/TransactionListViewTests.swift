import XCTest
@testable import MomentumFinance

class TransactionListViewTests: XCTestCase {
    var viewModel: Features.Transactions.TransactionListView!
    var transactions: [FinancialTransaction]!

    override func setUp() {
        super.setUp()
        
        // Create sample data for testing
        let transaction1 = FinancialTransaction(date: Date(), amount: 100.0, category: "Groceries")
        let transaction2 = FinancialTransaction(date: Date().addingTimeInterval(365 * 24 * 60 * 60), amount: -50.0, category: "Utilities")
        let transaction3 = FinancialTransaction(date: Date(), amount: 75.0, category: "Entertainment")
        
        transactions = [transaction1, transaction2, transaction3]
        
        // Initialize the view model with sample data
        viewModel = Features.Transactions.TransactionListView(transactions: transactions) { transaction in
            print("Tapped transaction: \(transaction)")
        } onDeleteTransaction: { transaction in
            print("Deleted transaction: \(transaction)")
        }
    }

    override func tearDown() {
        super.tearDown()
        
        // Clean up any resources if needed
    }

    func testGroupedTransactions() {
        // GIVEN: A list of transactions with different dates
        let grouped = viewModel.groupedTransactions
        
        // WHEN: We check the number of sections and items in each section
        XCTAssertEqual(grouped.count, 2)
        
        // THEN: Each section should have a unique date formatted as "MMMM yyyy"
        XCTAssertTrue(grouped[0].key == "January 2025")
        XCTAssertTrue(grouped[1].key == "February 2025")
    }

    func testTransactionRowView() {
        // GIVEN: A transaction row view with sample data
        let transaction = FinancialTransaction(date: Date(), amount: 100.0, category: "Groceries")
        
        // WHEN: We create a transaction row view and tap it
        let transactionRowView = Features.Transactions.TransactionRowView(transaction: transaction) {
            print("Tapped transaction: \(transaction)")
        }
        
        // THEN: The onTransactionTapped closure should be called with the correct transaction
        XCTAssertEqual(transactionRowView.onTransactionTapped, { tappedTransaction in
            XCTAssertEqual(tappedTransaction, transaction)
        })
    }

    func testDeleteTransaction() {
        // GIVEN: A transaction row view with sample data
        let transaction = FinancialTransaction(date: Date(), amount: 100.0, category: "Groceries")
        
        // WHEN: We create a transaction row view and delete it
        let transactionRowView = Features.Transactions.TransactionRowView(transaction: transaction) {
            print("Tapped transaction: \(transaction)")
        }
        
        // THEN: The onDeleteTransaction closure should be called with the correct transaction
        XCTAssertEqual(transactionRowView.onDeleteTransaction, { tappedTransaction in
            XCTAssertEqual(tappedTransaction, transaction)
        })
    }

    func testListStyle() {
        // GIVEN: A list view with sample data
        let listView = Features.Transactions.TransactionListView(transactions: transactions) { transaction in
            print("Tapped transaction: \(transaction)")
        } onDeleteTransaction: { transaction in
            print("Deleted transaction: \(transaction)")
        }
        
        // WHEN: We check the list style of the view
        XCTAssertEqual(listView.listStyle, .plainListStyle())
    }
}
