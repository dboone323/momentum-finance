import XCTest
@testable import MomentumFinance

class FinancialSummaryCardTests: XCTestCase {
    var viewModel: Features.GoalsAndReports.EnhancedFinancialSummaryCard!

    // Test calculateIncome method
    func testCalculateIncome() {
        let expectedIncome = "100.00"
        XCTAssertEqual(viewModel.calculateIncome(), expectedIncome, "Expected income to be \(expectedIncome)")
    }

    // Test calculateExpenses method
    func testCalculateExpenses() {
        let expectedExpenses = "50.00"
        XCTAssertEqual(viewModel.calculateExpenses(), expectedExpenses, "Expected expenses to be \(expectedExpenses)")
    }

    // Test calculateNet method
    func testCalculateNet() {
        let expectedNet = "50.00"
        XCTAssertEqual(
            String(format: "%.2f", viewModel.calculateNet()),
            expectedNet,
            "Expected net to be \(expectedNet)"
        )
    }
}
