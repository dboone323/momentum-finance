import XCTest
@testable import MomentumFinance

class TransactionPatternAnalyzerTests: XCTestCase {
    var analyzer: TransactionPatternAnalyzer!

    // Test analyzePatterns method with real data
    func testAnalyzePatterns_withRealData() {
        let transactions = [
            FinancialTransaction(date: Date(), amount: -100.0, category: "Groceries"),
            FinancialTransaction(date: Date(), amount: -200.0, category: "Entertainment"),
            FinancialTransaction(date: Date(), amount: 50.0, category: "Groceries"),
            FinancialTransaction(date: Date(), amount: 100.0, category: "Entertainment"),
        ]

        let insights = analyzer.analyzePatterns(transactions)

        XCTAssertEqual(insights.count, 2)
        XCTAssertTrue(insights[0].title == "Spending Patterns")
        XCTAssertTrue(insights[0]
            .description == "You tend to spend the most on Sundays. Consider this when planning your budget.")
        XCTAssertTrue(insights[0].priority == .low)
        XCTAssertTrue(insights[0].type == .pattern)
        XCTAssertTrue(insights[0].visualizationType == .barChart)
        XCTAssertEqual(insights[0].data.count, 2)

        XCTAssertTrue(insights[1].title == "Monthly Spending Cycle")
        XCTAssertTrue(insights[1]
            .description ==
            "You tend to spend more around the 15th of each month. This could indicate bill payment patterns.")
        XCTAssertTrue(insights[1].priority == .low)
        XCTAssertTrue(insights[1].type == .pattern)
        XCTAssertTrue(insights[1].visualizationType == .lineChart)
        XCTAssertEqual(insights[1].data.count, 2)
    }

    // Test analyzeWeekdaySpending method with real data
    func testAnalyzeWeekdaySpending_withRealData() {
        let transactions = [
            FinancialTransaction(date: Date(), amount: -100.0, category: "Groceries"),
            FinancialTransaction(date: Date(), amount: -200.0, category: "Entertainment"),
            FinancialTransaction(date: Date(), amount: 50.0, category: "Groceries"),
            FinancialTransaction(date: Date(), amount: 100.0, category: "Entertainment"),
        ]

        let insights = analyzer.analyzePatterns(transactions)

        XCTAssertTrue(insights[0].title == "Spending Patterns")
        XCTAssertTrue(insights[0]
            .description == "You tend to spend the most on Sundays. Consider this when planning your budget.")
        XCTAssertTrue(insights[0].priority == .low)
        XCTAssertTrue(insights[0].type == .pattern)
        XCTAssertTrue(insights[0].visualizationType == .barChart)
        XCTAssertEqual(insights[0].data.count, 2)

        XCTAssertTrue(insights[1].title == "Monthly Spending Cycle")
        XCTAssertTrue(insights[1]
            .description ==
            "You tend to spend more around the 15th of each month. This could indicate bill payment patterns.")
        XCTAssertTrue(insights[1].priority == .low)
        XCTAssertTrue(insights[1].type == .pattern)
        XCTAssertTrue(insights[1].visualizationType == .lineChart)
        XCTAssertEqual(insights[1].data.count, 2)
    }

}
