import XCTest
@testable import MomentumFinance

class TransactionComponentsTests: XCTestCase {
    var viewModel: TransactionEmptyStateViewModel!
    var view: TransactionEmptyStateView!

    override func setUp() {
        super.setUp()
        viewModel = TransactionEmptyStateViewModel()
        view = TransactionEmptyStateView(viewModel: viewModel)
    }

    /// Test for the initial state of the view when searchText is empty
    func testInitialViewStateWhenSearchTextIsEmpty() {
        XCTAssertEqual(view.searchText, "")
        XCTAssertNotNil(view.onAddTransaction)
        XCTAssertEqual(view.body.description, """
        VStack(spacing: 20) {
            Image(systemName: self.searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(self.searchText.isEmpty ? "No transactions yet" : "No transactions found")
                .font(.title2)
                .foregroundColor(.primary)
            Text(
                self.searchText.isEmpty
                    ? "Add your first transaction to get started"
                    : "Try adjusting your search or filter"
            )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if self.searchText.isEmpty {
                Button(action: self.onAddTransaction, label: {
                    Label("Add Transaction", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                .accessibilityLabel("Add Transaction")
            }
        }
        """)
    }

    /// Test for the initial state of the view when searchText is not empty
    func testInitialViewStateWhenSearchTextIsNotEmpty() {
        let searchText = "Test Search"
        viewModel.searchText = searchText
        XCTAssertEqual(view.searchText, searchText)
        XCTAssertNotNil(view.onAddTransaction)
        XCTAssertEqual(view.body.description, """
        VStack(spacing: 20) {
            Image(systemName: self.searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(self.searchText.isEmpty ? "No transactions yet" : "No transactions found")
                .font(.title2)
                .foregroundColor(.primary)
            Text(
                self.searchText.isEmpty
                    ? "Add your first transaction to get started"
                    : "Try adjusting your search or filter"
            )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if self.searchText.isEmpty {
                Button(action: self.onAddTransaction, label: {
                    Label("Add Transaction", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                .accessibilityLabel("Add Transaction")
            }
        }
        """)
    }

    /// Test for the behavior of the onAddTransaction action
    func testOnAddTransactionAction() {
        let mockOnAddTransaction = MockFunction<Void>()
        viewModel.onAddTransaction = mockOnAddTransaction

        view.onAddTransaction()

        XCTAssertEqual(mockOnAddTransaction.callCount, 1)
    }

    // Auto-added closing brace to fix unexpected EOF
}
