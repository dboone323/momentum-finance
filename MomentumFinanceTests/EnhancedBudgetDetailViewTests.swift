import XCTest
@testable import MomentumFinance

class EnhancedBudgetDetailViewTests: XCTestCase {
    var sut: EnhancedBudgetDetailView!

    func testBudgetNameDisplay() {
        XCTAssertEqual(sut.name, "Test Budget")
    }

    func testTimeFramePicker() {
        XCTAssertEqual(sut.selectedTimeFrame.rawValue, "This Month")
    }

    func testEditButtonToggle() {
        XCTAssertTrue(sut.isEditing)
        sut.isEditing.toggle()
        XCTAssertFalse(sut.isEditing)
    }

    func testExportAsPDF() {
        // Implement PDF export logic
    }

    func testPrintBudget() {
        // Implement print logic
    }

    func testDeleteConfirmation() {
        XCTAssertTrue(sut.showingDeleteConfirmation)
        sut.showingDeleteConfirmation.toggle()
        XCTAssertFalse(sut.showingDeleteConfirmation)
    }

    func testDetailViewWithTransactions() {
        let expectedTransactionNames = ["Groceries", "Transportation"]
        XCTAssertEqual(sut.relatedTransactions.map(\.name), expectedTransactionNames)
    }
}
