import XCTest
@testable import MomentumFinance

class FinancialMLModelsTests: XCTestCase {
    var financialMLModels: FinancialMLModels!

    override func setUp() {
        super.setUp()
        financialMLModels = FinancialMLModels.shared
    }

    override func tearDown() {
        super.tearDown()
        financialMLModels = nil
    }

    // Test case for analyzeSpendingPatterns
    func testAnalyzeSpendingPatterns() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100.0, description: "Grocery"),
            FinancialTransaction(amount: 50.0, description: "Restaurant"),
            FinancialTransaction(amount: -200.0, description: "Gas"),
            FinancialTransaction(amount: 300.0, description: "Shopping")
        ]

        let expected = [
            "totalSpent": 180.0,
            "smallTransactionCount": 2,
            "mediumTransactionCount": 1,
            "largeTransactionCount": 1,
            "averageTransactionSize": 90.0,
            "transactionFrequency": 4.0, // per day
        ]

        let result = financialMLModels.analyzeSpendingPatterns(transactions: transactions)
        XCTAssertEqual(result, expected, "Expected analyzeSpendingPatterns to return the correct results.")
    }

    // Test case for predictFutureSpending
    func testPredictFutureSpending() {
        let historicalData: [Double] = [10.0, 20.0, 30.0, 40.0]
        let months = 5

        let expected = [30.0, 40.0, 50.0, 60.0, 70.0]

        let result = financialMLModels.predictFutureSpending(historicalData: historicalData, months: months)
        XCTAssertEqual(result, expected, "Expected predictFutureSpending to return the correct predictions.")
    }

    // Test case for classifyTransaction
    func testClassifyTransaction() {
        let transaction1 = FinancialTransaction(amount: -50.0, description: "Grocery")
        let transaction2 = FinancialTransaction(amount: 300.0, description: "Shopping")

        XCTAssertEqual(financialMLModels.classifyTransaction(transaction: transaction1), "Food & Dining", "Expected classifyTransaction to return 'Food & Dining' for grocery transaction.")
        XCTAssertEqual(financialMLModels.classifyTransaction(transaction: transaction2), "Shopping", "Expected classifyTransaction to return 'Shopping' for shopping transaction.")
    }
}
