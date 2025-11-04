import XCTest
@testable import MomentumFinance

class EnhancedDetailViewsTests: XCTestCase {
    var transactionId: String = "12345"
    var modelContext: ModelContext = ModelContext()
    var transactions: [FinancialTransaction] = []
    var categories: [ExpenseCategory] = []

    override func setUp() {
        super.setUp()
        // Set up the test environment
        let context = ModelContext()
        let transaction = FinancialTransaction(id: transactionId, amount: 100.0, category: categories.first!)
        context.insert(transaction)
        modelContext.save()

        transactions = try! context.fetch(FinancialTransaction.self)
    }

    override func tearDown() {
        super.tearDown()
        // Clean up the test environment
        modelContext.deleteAll()
    }

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
