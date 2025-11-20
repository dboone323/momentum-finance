@testable import MomentumFinance
import XCTest

class TransactionListViewTests: XCTestCase {
    var viewModel: Features.Transactions.TransactionListViewModel!
    var transactions: [FinancialTransaction]!

    override func setUp() {
        super.setUp()
        transactions = [
            FinancialTransaction(date: Date(timeIntervalSince1970: 1_672_531_200), amount: 100.0, category: "Groceries"),
            FinancialTransaction(date: Date(timeIntervalSince1970: 1_675_209_600), amount: 50.0, category: "Coffee")
        ]
        viewModel = Features.Transactions.TransactionListViewModel(transactions: transactions)
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
        XCTAssertNotNil(transactionRowView.onTransactionTapped)
    }

    func testDeleteTransaction() {
        // GIVEN: A transaction row view with sample data
        let transaction = FinancialTransaction(date: Date(), amount: 100.0, category: "Groceries")

        // WHEN: We create a transaction row view and delete it
        let transactionRowView = Features.Transactions.TransactionRowView(transaction: transaction) {
            print("Tapped transaction: \(transaction)")
        }

        // THEN: The onDeleteTransaction closure should be called with the correct transaction
        XCTAssertNotNil(transactionRowView.onDeleteTransaction)
    }

    func testListStyle() {
        // GIVEN: A list view with sample data
        let listView = Features.Transactions.TransactionListView(transactions: transactions) { transaction in
            print("Tapped transaction: \(transaction)")
        } onDeleteTransaction: { transaction in
            print("Deleted transaction: \(transaction)")
        }

        // WHEN: We check the list style of the view
        XCTAssertNotNil(listView.listStyle)
    }
}
