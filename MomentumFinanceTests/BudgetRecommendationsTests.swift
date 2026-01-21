@testable import MomentumFinance
import XCTest

class BudgetRecommendationsTests: XCTestCase {
    var budgetRecommendations: BudgetRecommendations!

    // Test case for fi_findBudgetRecommendations with real data
    func testFindBudgetRecommendationsWithRealData() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100, date: Date(), category: Category(name: "Groceries")),
            FinancialTransaction(amount: 200, date: Date(), category: Category(name: "Entertainment")),
            FinancialTransaction(amount: -50, date: Date(), category: Category(name: "Clothing")),
        ]

        let budgets: [Budget] = [
            Budget(limitAmount: 300, category: Category(name: "Groceries")),
            Budget(limitAmount: 400, category: Category(name: "Entertainment")),
            Budget(limitAmount: 250, category: Category(name: "Clothing")),
        ]

        let insights = budgetRecommendations.fi_findBudgetRecommendations(transactions: transactions, budgets: budgets)

        XCTAssertEqual(insights.count, 1)

        let insight = insights.first!
        XCTAssertEqual(insight.title, "Budget Recommendation: Groceries")
        XCTAssertEqual(
            insight.description,
            "Based on your average spending of $200.00, consider setting a budget of $310.00 for Groceries."
        )
        XCTAssertEqual(insight.priority, .medium)
        XCTAssertEqual(insight.type, .budgetRecommendation)
        XCTAssertEqual(insight.relatedAccountId, nil)
        XCTAssertEqual(insight.relatedTransactionId, nil)
        XCTAssertEqual(insight.relatedCategoryId, "Groceries")
        XCTAssertEqual(insight.relatedBudgetId, nil)
        XCTAssertEqual(insight.visualizationType, nil)

        let data = insight.data
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].key, "Average Spending")
        XCTAssertEqual(data[0].value, 200.00)
        XCTAssertEqual(data[1].key, "Recommended Budget")
        XCTAssertEqual(data[1].value, 310.00)
    }

    // Test case for fi_findBudgetRecommendations with no budget set
    func testFindBudgetRecommendationsWithNoBudgetSet() {
        let transactions: [FinancialTransaction] = [
            FinancialTransaction(amount: -100, date: Date(), category: Category(name: "Groceries")),
            FinancialTransaction(amount: 200, date: Date(), category: Category(name: "Entertainment")),
            FinancialTransaction(amount: -50, date: Date(), category: Category(name: "Clothing")),
        ]

        let budgets: [Budget] = [
            Budget(limitAmount: 300, category: Category(name: "Groceries")),
            Budget(limitAmount: 400, category: Category(name: "Entertainment")),
            Budget(limitAmount: 250, category: Category(name: "Clothing")),
        ]

        let insights = budgetRecommendations.fi_findBudgetRecommendations(transactions: transactions, budgets: budgets)

        XCTAssertEqual(insights.count, 1)

        let insight = insights.first!
        XCTAssertEqual(insight.title, "Budget Recommendation: Groceries")
        XCTAssertEqual(
            insight.description,
            "Based on your average spending of $200.00, consider setting a budget of $310.00 for Groceries."
        )
        XCTAssertEqual(insight.priority, .medium)
        XCTAssertEqual(insight.type, .budgetRecommendation)
        XCTAssertEqual(insight.relatedAccountId, nil)
        XCTAssertEqual(insight.relatedTransactionId, nil)
        XCTAssertEqual(insight.relatedCategoryId, "Groceries")
        XCTAssertEqual(insight.relatedBudgetId, nil)
        XCTAssertEqual(insight.visualizationType, nil)

        let data = insight.data
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].key, "Average Spending")
        XCTAssertEqual(data[0].value, 200.00)
        XCTAssertEqual(data[1].key, "Recommended Budget")
        XCTAssertEqual(data[1].value, 310.00)
    }
}
