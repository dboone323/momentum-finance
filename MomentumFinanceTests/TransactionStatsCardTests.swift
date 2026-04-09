import XCTest
@testable import MomentumFinance

class TransactionStatsCardTests: XCTestCase {
    var transactionStatsCard: TransactionStatsCard!

    func testIncomeAndExpenses() {
        // GIVEN
        let expectedIncome = 300.0
        let expectedExpenses = -50.0

        // WHEN
        let actualIncome = transactionStatsCard.income
        let actualExpenses = transactionStatsCard.expenses

        // THEN
        XCTAssertEqual(actualIncome, expectedIncome)
        XCTAssertEqual(actualExpenses, expectedExpenses)
    }

    func testTransactionCount() {
        // GIVEN
        let expectedCount = 3

        // WHEN
        let actualCount = transactionStatsCard.transactions.count

        // THEN
        XCTAssertEqual(actualCount, expectedCount)
    }
}
