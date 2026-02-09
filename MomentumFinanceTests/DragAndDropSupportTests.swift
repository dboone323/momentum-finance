import XCTest
@testable import MomentumFinance

class DragAndDropSupportTests: XCTestCase {
    // MARK: - Setup & Teardown

    // MARK: - Test Draggable Finance Item Protocol

    func testDraggableFinanceItemProtocol() {
        let account = FinancialAccount(name: "Checking Account", balance: 1000.0, currencyCode: "USD")
        XCTAssertEqual(account.dragItemType, .account)
        XCTAssertEqual(account.dragItemTitle, "Checking Account")
        XCTAssertEqual(account.dragItemIconName, "banknote")
    }

    func testDragItemTypes() {
        let accountType = FinanceDragItemType.account
        XCTAssertEqual(accountType.uniformType.identifier, UTType("com.momentumfinance.account")!.identifier)

        let transactionType = FinanceDragItemType.transaction
        XCTAssertEqual(transactionType.uniformType.identifier, UTType("com.momentumfinance.transaction")!.identifier)
    }

    // MARK: - Model Extensions

    func testFinancialAccountAsItemProvider() {
        let account = FinancialAccount(name: "Checking Account", balance: 1000.0, currencyCode: "USD")
        let provider = account.asItemProvider()

        var data: Data?
        var error: Error?

        do {
            data = try provider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier)
            XCTAssertNotNil(data)
        } catch {
            error = error
        }

        XCTAssertNil(error)
    }

    func testFinancialTransactionAsItemProvider() {
        let transaction = FinancialTransaction(name: "Salary", amount: 500.0, date: Date())
        let provider = transaction.asItemProvider()

        var data: Data?
        var error: Error?

        do {
            data = try provider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier)
            XCTAssertNotNil(data)
        } catch {
            error = error
        }

        XCTAssertNil(error)
    }

    // Similar tests for other model types...

    // MARK: - UTType Extensions

    func testFinanceAccountUTType() {
        let accountType = FinanceDragItemType.account
        XCTAssertEqual(accountType.uniformType.identifier, UTType("com.momentumfinance.account")!.identifier)
    }
}
