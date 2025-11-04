import XCTest
@testable import MomentumFinance

class TransactionComponentsTests: XCTestCase {
    var viewModel: TransactionEmptyStateViewModel!
    var view: TransactionEmptyStateView!

    override func setUp() {
        super.setUp()
        
        // Initialize the ViewModel and View
        viewModel = TransactionEmptyStateViewModel(searchText: "", onAddTransaction: {})
        view = TransactionEmptyStateView(viewModel: viewModel)
    }

    override func tearDown() {
        super.tearDown()
        
        // Clean up any resources if needed
    }
    
    // Test for the initial state of the view when searchText is empty
    func testInitialViewStateWhenSearchTextIsEmpty() {
        XCTAssertEqual(view.searchText, "")
        XCTAssertEqual(view.onAddTransaction, {})
        XCTAssertEqual(view.body.description, "VStack(spacing: 20) {\n    Image(systemName: self.searchText.isEmpty ? \"doc.text.magnifyingglass\" : \"magnifyingglass\")\n        .font(.system(size: 48))\n        .foregroundColor(.secondary)\n    Text(self.searchText.isEmpty ? \"No transactions yet\" : \"No transactions found\")\n        .font(.title2)\n        .foregroundColor(.primary)\n    Text(\n        self.searchText.isEmpty\n            ? \"Add your first transaction to get started\"\n            : \"Try adjusting your search or filter\"\n    )\n        .font(.body)\n        .foregroundColor(.secondary)\n        .multilineTextAlignment(.center)\n    if self.searchText.isEmpty {\n        Button(action: self.onAddTransaction) {\n            Label(\"Add Transaction\", systemImage: \"plus\")\n                .padding()\n                .background(Color.blue)\n                .foregroundColor(.white)\n                .cornerRadius(8)\n        }\n        .accessibilityLabel(\"Add Transaction\")\n    }\n}")
    }
    
    // Test for the initial state of the view when searchText is not empty
    func testInitialViewStateWhenSearchTextIsNotEmpty() {
        let searchText = "Test Search"
        viewModel.searchText = searchText
        XCTAssertEqual(view.searchText, searchText)
        XCTAssertEqual(view.onAddTransaction, {})
        XCTAssertEqual(view.body.description, "VStack(spacing: 20) {\n    Image(systemName: self.searchText.isEmpty ? \"doc.text.magnifyingglass\" : \"magnifyingglass\")\n        .font(.system(size: 48))\n        .foregroundColor(.secondary)\n    Text(self.searchText.isEmpty ? \"No transactions yet\" : \"No transactions found\")\n        .font(.title2)\n        .foregroundColor(.primary)\n    Text(\n        self.searchText.isEmpty\n            ? \"Add your first transaction to get started\"\n            : \"Try adjusting your search or filter\"\n    )\n        .font(.body)\n        .foregroundColor(.secondary)\n        .multilineTextAlignment(.center)\n    if self.searchText.isEmpty {\n        Button(action: self.onAddTransaction) {\n            Label(\"Add Transaction\", systemImage: \"plus\")\n                .padding()\n                .background(Color.blue)\n                .foregroundColor(.white)\n                .cornerRadius(8)\n        }\n        .accessibilityLabel(\"Add Transaction\")\n    }\n}")
    }
    
    // Test for the behavior of the onAddTransaction action
    func testOnAddTransactionAction() {
        let mockOnAddTransaction = MockFunction<Void>()
        viewModel.onAddTransaction = mockOnAddTransaction
        
        view.onAddTransaction()
        
        XCTAssertEqual(mockOnAddTransaction.callCount, 1)
    }
