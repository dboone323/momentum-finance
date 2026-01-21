@testable import MomentumFinance
import XCTest

class FISSpendingTests: XCTestCase {
    var service: FinancialIntelligenceService!

    // Test computeMonthlySpendingByCategory
    func testComputeMonthlySpendingByCategory() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(amount: 200, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(
                amount: -50,
                date: Date(),
                category: ExpenseCategory(id: "category2", name: "Entertainment")
            ),
        ]

        let expected = [
            "category1": [DateComponents(year: 2023, month: 4): 300.0],
            "category2": [DateComponents(year: 2023, month: 4): -50.0],
        ]

        XCTAssertEqual(service.fi_computeMonthlySpendingByCategory(transactions), expected)
    }

    // Test generateSpendingInsightsFromMonthlyData
    func testGenerateSpendingInsightsFromMonthlyData() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(amount: 200, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(
                amount: -50,
                date: Date(),
                category: ExpenseCategory(id: "category2", name: "Entertainment")
            ),
        ]

        let categories = [
            ExpenseCategory(id: "category1", name: "Food"),
            ExpenseCategory(id: "category2", name: "Entertainment"),
        ]

        let expectedInsights = [
            FinancialInsight(
                title: "Increased Spending in Food",
                description:
                "Your spending in Food increased by 50% last month.",
                priority: .medium,
                type: .spendingPattern,
                relatedCategoryId: "category1",
                visualizationType: .lineChart,
                data: [
                    ("2023-04-01", -100.0),
                    ("2023-04-08", 200.0),
                ]
            ),
            FinancialInsight(
                title: "Reduced Spending in Entertainment",
                description:
                "Your spending in Entertainment decreased by 50% last month.",
                priority: .low,
                type: .positiveSpendingTrend,
                relatedCategoryId: "category2",
                visualizationType: .lineChart,
                data: [
                    ("2023-04-01", -50.0),
                    ("2023-04-08", 0.0),
                ]
            ),
        ]

        XCTAssertEqual(service.fi_generateSpendingInsightsFromMonthlyData(transactions, categories), expectedInsights)
    }

    // Test topCategoriesInsight
    func testTopCategoriesInsight() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(amount: 200, date: Date(), category: ExpenseCategory(id: "category1", name: "Food")),
            FinancialTransaction(
                amount: -50,
                date: Date(),
                category: ExpenseCategory(id: "category2", name: "Entertainment")
            ),
        ]

        let categories = [
            ExpenseCategory(id: "category1", name: "Food"),
            ExpenseCategory(id: "category2", name: "Entertainment"),
        ]

        let expectedInsight = FinancialInsight(
            title: "Top Spending Categories",
            description:
            "Your highest spending categories are Food, Entertainment.",
            priority: .medium,
            type: .spendingPattern,
            visualizationType: .pieChart,
            data: [
                ("Food", 300.0),
                ("Entertainment", 200.0),
            ]
        )

        XCTAssertEqual(service.fi_topCategoriesInsight(transactions, categories), expectedInsight)
    }
}
