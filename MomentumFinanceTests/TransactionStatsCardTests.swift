import XCTest
@testable import MomentumFinance

class TransactionStatsCardTests: XCTestCase {
    var transactionStatsCard: TransactionStatsCard!

    override func setUp() {
        super.setUp()
        // Initialize your transaction data here
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0),
            FinancialTransaction(transactionType: .expense, amount: -50.0),
            FinancialTransaction(transactionType: .income, amount: 200.0)
        ]
        transactionStatsCard = TransactionStatsCard(transactions: transactions)
    }

    override func tearDown() {
        super.tearDown()
        // Clean up your test data here
    }

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
