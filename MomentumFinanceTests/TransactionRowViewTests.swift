import XCTest
@testable import MomentumFinance

class TransactionRowViewTests: XCTestCase {
    var transaction: FinancialTransaction!
    var viewModel: Features.Transactions.TransactionRowViewModel!

    func testTransactionRowView() {
        // GIVEN a FinancialTransaction instance and a TransactionRowViewModel
        viewModel = Features.Transactions.TransactionRowViewModel(transaction: transaction)

        // WHEN the view is rendered
        let view = viewModel.view()

        // THEN the view should display the correct transaction details
        XCTAssertEqual(view.title, "Grocery Purchase")
        XCTAssertEqual(view.amount.formattedAmount, "$100.50")
        XCTAssertEqual(view.category.name, "Groceries")
        XCTAssertEqual(view.category.color, .green)
        XCTAssertEqual(view.date.formattedDate, "Aug 19, 2021")
    }
}
