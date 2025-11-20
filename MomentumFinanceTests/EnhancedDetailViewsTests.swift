@testable import MomentumFinance
import XCTest

class EnhancedDetailViewsTests: XCTestCase {
    var transactionId: String = "12345"
    var modelContext: ModelContext = .init()
    var transactions: [FinancialTransaction] = []
    var categories: [ExpenseCategory] = []

    func testEnhancedTransactionDetailView() {
        let view = EnhancedTransactionDetailView(transactionId: transactionId)

        // Test the body of the view
        XCTAssertEqual(view.body, "Expected body of EnhancedTransactionDetailView")

        // Test the top action bar
        XCTAssertEqual(view.topActionBar, "Expected top action bar of EnhancedTransactionDetailView")

        // Test the picker for selecting tab
        XCTAssertEqual(view.tabPicker, "Expected tab picker of EnhancedTransactionDetailView")

        // Test the buttons for editing and saving transaction
        XCTAssertEqual(view.editButton, "Expected edit button of EnhancedTransactionDetailView")
        XCTAssertEqual(view.saveButton, "Expected save button of EnhancedTransactionDetailView")
        XCTAssertEqual(view.cancelButton, "Expected cancel button of EnhancedTransactionDetailView")

        // Test the menu for deleting transaction
        XCTAssertEqual(view.deleteMenu, "Expected delete menu of EnhancedTransactionDetailView")

        // Test the export options
        XCTAssertEqual(view.exportOptions, "Expected export options of EnhancedTransactionDetailView")

        // Test the print transaction
        XCTAssertEqual(view.printTransaction, "Expected print transaction of EnhancedTransactionDetailView")
    }
}
