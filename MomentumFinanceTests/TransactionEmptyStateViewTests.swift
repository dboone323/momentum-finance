@testable import MomentumFinance
import XCTest

class TransactionEmptyStateViewTests: XCTestCase {
    var sut: TransactionEmptyStateView!
    var viewModel: Features.Transactions.TransactionEmptyStateViewModel!

    override func setUp() {
        super.setUp()
        let onAddTransaction = {}
        let searchText = ""
        viewModel = Features.Transactions.TransactionEmptyStateViewModel(
            searchText: searchText,
            onAddTransaction: onAddTransaction
        )
        sut = TransactionEmptyStateView(viewModel: viewModel)
    }

    func testSearchTextIsEmptyImageAndText() {
        // GIVEN: The search text is empty
        let searchText = ""

        // WHEN: The view is created
        sut = TransactionEmptyStateView(viewModel: viewModel)

        // THEN: The image should be "list.bullet" and the text should be "No Transactions"
        XCTAssertEqual(sut.image.systemName, "list.bullet")
        XCTAssertEqual(sut.text.title2, "No Transactions")
    }

    func testSearchTextIsNotEmptyImageAndText() {
        // GIVEN: The search text is not empty
        let searchText = "test"

        // WHEN: The view is created
        sut = TransactionEmptyStateView(viewModel: viewModel)

        // THEN: The image should be "magnifyingglass" and the text should be "No Results Found"
        XCTAssertEqual(sut.image.systemName, "magnifyingglass")
        XCTAssertEqual(sut.text.title2, "No Results Found")
    }

    func testAddTransactionButton() {
        // GIVEN: The search text is empty
        let searchText = ""

        // WHEN: The view is created
        sut = TransactionEmptyStateView(viewModel: viewModel)

        // THEN: The button should be present and the action should be called when tapped
        XCTAssertTrue(sut.addTransactionButton.isDisplayed)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addTransactionButtonTapped))
        sut.addTransactionButton.addGestureRecognizer(tapGesture)

        // WHEN: The button is tapped
        tapGesture.sendActions(for: .touchUpInside)

        // THEN: The onAddTransaction method should be called
        XCTAssertEqual(viewModel.onAddTransactionCount, 1)
    }

    @objc
    func addTransactionButtonTapped() {
        viewModel.onAddTransaction()
    }
}
