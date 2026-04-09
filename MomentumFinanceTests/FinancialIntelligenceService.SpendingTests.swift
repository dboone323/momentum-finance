import Foundation
import MomentumFinanceCore
import Testing
@testable import MomentumFinance

@Suite("Financial Intelligence Spending Analysis Tests")
@MainActor
struct FISSpendingTests {
    let service = FinancialIntelligenceService.shared

    @Test("Monthly spending by category calculation")
    func computeMonthlySpendingByCategory() {
        let calendar = Calendar.current
        let now = Date()
        let foodCategory = ExpenseCategory(id: "category1", name: "Food")
        let entCategory = ExpenseCategory(id: "category2", name: "Entertainment")

        let transactions: [FinancialTransaction] = [
            FinancialTransaction(
                title: "Groceries",
                amount: -100,
                date: now,
                transactionType: .expense,
                category: foodCategory
            ),
            FinancialTransaction(
                title: "Dining",
                amount: -200,
                date: now,
                transactionType: .expense,
                category: foodCategory
            ),
            FinancialTransaction(
                title: "Movies",
                amount: -50,
                date: now,
                transactionType: .expense,
                category: entCategory
            ),
        ]

        let result = service.fi_computeMonthlySpendingByCategory(transactions)

        #expect(result.count == 2)
        #expect(result["category1"] != nil)
        #expect(result["category2"] != nil)

        // Verify values (handle potential absolute values vs sign issues in implementation)
        let foodTotal = result["category1"]?.values.first ?? 0
        #expect(abs(foodTotal) == 300)
    }

    @Test("Spending insights generation")
    func generateSpendingInsights() {
        let now = Date()
        let categories = [
            ExpenseCategory(id: "category1", name: "Food"),
            ExpenseCategory(id: "category2", name: "Entertainment"),
        ]

        let transactions: [FinancialTransaction] = [
            FinancialTransaction(
                title: "Food",
                amount: -100,
                date: now,
                transactionType: .expense,
                category: categories[0]
            ),
            FinancialTransaction(
                title: "Entertainment",
                amount: -50,
                date: now,
                transactionType: .expense,
                category: categories[1]
            ),
        ]

        let insights = service.fi_generateSpendingInsightsFromMonthlyData(transactions, categories)

        #expect(!insights.isEmpty)
        #expect(insights.contains { $0.title.contains("Food") })
    }

    @Test("Top spending categories identification")
    func topCategoriesInsight() {
        let now = Date()
        let categories = [
            ExpenseCategory(id: "category1", name: "Food"),
            ExpenseCategory(id: "category2", name: "Entertainment"),
        ]

        let transactions: [FinancialTransaction] = [
            FinancialTransaction(
                title: "Large Expense",
                amount: -1000,
                date: now,
                transactionType: .expense,
                category: categories[0]
            ),
            FinancialTransaction(
                title: "Small Expense",
                amount: -10,
                date: now,
                transactionType: .expense,
                category: categories[1]
            ),
        ]

        let insight = service.fi_topCategoriesInsight(transactions, categories)

        #expect(insight.title == "Top Spending Categories")
        #expect(insight.description.contains("Food"))
    }
}
