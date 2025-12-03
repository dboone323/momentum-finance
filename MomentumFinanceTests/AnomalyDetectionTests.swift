import XCTest
@testable import MomentumFinance

class AnomalyDetectionTests: XCTestCase {
    var service: FinancialIntelligenceService!

    // Test for fi_detectCategoryOutliers
    func testFiDetectCategoryOutliers() {
        let transactions = [
            FinancialTransaction(amount: -100, category: nil),
            FinancialTransaction(amount: -200, category: nil),
            FinancialTransaction(amount: 50, category: nil),
            FinancialTransaction(amount: 150, category: nil),
        ]

        let expectedInsights = [
            FinancialInsight(
                title: "Unusual Spending in Category",
                description: "You had a transaction of $200 on April 1st that is 33.33% higher than your average spending in this category.",
                priority: .high,
                type: .anomaly,
                relatedTransactionId: "123456789",
                visualizationType: .boxPlot,
                data: [
                    ("Average", 0),
                    ("This Transaction", 200),
                    ("Typical Range", 0),
                ]
            ),
        ]

        let insights = service.fi_detectCategoryOutliers(transactions)

        XCTAssertEqual(insights.count, expectedInsights.count)
        for i in 0..<insights.count {
            XCTAssertEqual(insights[i].title, expectedInsights[i].title)
            XCTAssertEqual(insights[i].description, expectedInsights[i].description)
            XCTAssertEqual(insights[i].priority, expectedInsights[i].priority)
            XCTAssertEqual(insights[i].type, expectedInsights[i].type)
            XCTAssertEqual(insights[i].relatedTransactionId, expectedInsights[i].relatedTransactionId)
            XCTAssertEqual(insights[i].visualizationType, expectedInsights[i].visualizationType)
            XCTAssertEqual(insights[i].data.count, expectedInsights[i].data.count)
        }
    }

    // Test for fi_detectRecentFrequencyAnomalies
    func testFiDetectRecentFrequencyAnomalies() {
        let transactions = [
            FinancialTransaction(amount: -100, date: Date()),
            FinancialTransaction(amount: 50, date: Date()),
            FinancialTransaction(amount: 150, date: Date()),
            FinancialTransaction(amount: 200, date: Date()),
        ]

        let expectedInsights = [
            FinancialInsight(
                title: "Unusual Transaction Activity",
                description: "You had 4 transactions on April 1st that is 33.33% more than your daily average.",
                priority: .high,
                type: .anomaly,
                relatedTransactionId: "123456789",
                visualizationType: .barChart,
                data: [
                    ("April 1st", 4),
                    ("Average Daily Transactions", 0),
                ]
            ),
        ]

        let insights = service.fi_detectRecentFrequencyAnomalies(transactions)

        XCTAssertEqual(insights.count, expectedInsights.count)
        for i in 0..<insights.count {
            XCTAssertEqual(insights[i].title, expectedInsights[i].title)
            XCTAssertEqual(insights[i].description, expectedInsights[i].description)
            XCTAssertEqual(insights[i].priority, expectedInsights[i].priority)
            XCTAssertEqual(insights[i].type, expectedInsights[i].type)
            XCTAssertEqual(insights[i].relatedTransactionId, expectedInsights[i].relatedTransactionId)
            XCTAssertEqual(insights[i].visualizationType, expectedInsights[i].visualizationType)
            XCTAssertEqual(insights[i].data.count, expectedInsights[i].data.count)
        }
    }

}
