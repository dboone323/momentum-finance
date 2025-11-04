import XCTest
@testable import MomentumFinance

class FinancialSummaryCardTests: XCTestCase {
    var viewModel: Features.GoalsAndReports.EnhancedFinancialSummaryCard!

    override func setUp() {
        super.setUp()
        viewModel = Features.GoalsAndReports.EnhancedFinancialSummaryCard(transactions: [
            FinancialTransaction(transactionType: .income, amount: 100.0),
            FinancialTransaction(transactionType: .expense, amount: 50.0)
        ], timeframe: .lastMonth)
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

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
        XCTAssertEqual(String(format: "%.2f", viewModel.calculateNet()), expectedNet, "Expected net to be \(expectedNet)")
    }
}
