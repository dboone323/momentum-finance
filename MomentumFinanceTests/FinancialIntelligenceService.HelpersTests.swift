@testable import MomentumFinance
import XCTest

class FinancialIntelligenceServiceHelpersTests: XCTestCase {
    // MARK: - FormattingUtilities Tests

    func testFormatCurrency() {
        let amount = 123_456.789
        let formattedAmount = FormattingUtilities.formatCurrency(amount)

        XCTAssertEqual(formattedAmount, "$123,456.79")
    }

    func testFormatDate() {
        let date = Date()
        let formattedDate = FormattingUtilities.formatDate(date)

        XCTAssert(formattedDate.count == 10) // Expected format: YYYY-MM-DD
    }

    func testCleanText() {
        let text = "Hello, World! This is a test."
        let cleanedText = FormattingUtilities.cleanText(text)

        XCTAssertEqual(cleanedText, "Hello World This is a test")
    }

    // MARK: - TransactionPatternDetection Tests

    func testDetectRecurringTransactions() {
        let transactions = [
            Transaction(date: Date(), amount: 100.0),
            Transaction(date: Date().addingTimeInterval(86400), amount: 100.0),
            Transaction(date: Date().addingTimeInterval(172_800), amount: -50.0),
        ]

        let recurringTransactions = TransactionPatternDetection.detectRecurringTransactions(transactions)

        XCTAssertEqual(recurringTransactions.count, 1) // Expected to find one recurring transaction
    }

    func testDetectAnomalies() {
        let transactions = [
            Transaction(date: Date(), amount: 100.0),
            Transaction(date: Date().addingTimeInterval(86400), amount: 200.0),
            Transaction(date: Date().addingTimeInterval(172_800), amount: -50.0),
        ]

        let anomalies = TransactionPatternDetection.detectAnomalies(transactions)

        XCTAssertEqual(anomalies.count, 1) // Expected to find one anomaly
    }

    // MARK: - OptimizationSuggestions Tests

    func testOptimizeIdleCash() {
        let idleCash = 500.0
        let creditUtilization = 75.0

        let optimizationSuggestion = OptimizationSuggestions.optimizeIdleCash(idleCash, creditUtilization)

        XCTAssertEqual(optimizationSuggestion, "Reduce spending by $250 to free up $125")
    }

    func testOptimizeCreditUtilization() {
        let idleCash = 500.0
        let creditUtilization = 75.0

        let optimizationSuggestion = OptimizationSuggestions.optimizeCreditUtilization(idleCash, creditUtilization)

        XCTAssertEqual(optimizationSuggestion, "Reduce spending by $250 to free up $125")
    }

    // MARK: - BudgetRecommendations Tests

    func testGenerateBudgetRecommendation() {
        let transactions = [
            Transaction(date: Date(), amount: 100.0),
            Transaction(date: Date().addingTimeInterval(86400), amount: 200.0),
            Transaction(date: Date().addingTimeInterval(172_800), amount: -50.0),
        ]

        let budgetRecommendation = BudgetRecommendations.generateBudgetRecommendation(transactions)

        XCTAssertEqual(budgetRecommendation, "Reduce spending by $250 to free up $125")
    }

    // MARK: - FinancialForecasting Tests

    func testGenerateFinancialForecast() {
        let transactions = [
            Transaction(date: Date(), amount: 100.0),
            Transaction(date: Date().addingTimeInterval(86400), amount: 200.0),
            Transaction(date: Date().addingTimeInterval(172_800), amount: -50.0),
        ]

        let financialForecast = FinancialForecasting.generateFinancialForecast(transactions)

        XCTAssertEqual(financialForecast, "Expected financial forecast")
    }

    // MARK: - Test Setup and Teardown

}
