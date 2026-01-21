@testable import MomentumFinance
import XCTest

class TransactionDetailViewTests: XCTestCase {
    var transaction: FinancialTransaction!
    var viewModel: Features.Transactions.TransactionDetailView!

    // Test that the amount is displayed correctly
    func testAmountDisplay() {
        XCTAssertEqual(viewModel.amountLabel, "100.0")
    }

    // Test that the transaction type label is displayed correctly
    func testTransactionTypeLabel() {
        XCTAssertEqual(viewModel.transactionTypeLabel, "Income")
    }

    // Test that the date is displayed correctly
    func testDateDisplay() {
        XCTAssertEqual(viewModel.dateLabel, "2024-12-19")
    }

    // Test that the category label is displayed correctly
    func testCategoryLabel() {
        XCTAssertEqual(viewModel.categoryLabel, "Food")
    }

    // Test that the account label is displayed correctly
    func testAccountLabel() {
        XCTAssertEqual(viewModel.accountLabel, "Checking")
    }

    // Test that the notes are displayed correctly
    func testNotesDisplay() {
        XCTAssertEqual(viewModel.notesLabel, "This is a test note.")
    }
}
