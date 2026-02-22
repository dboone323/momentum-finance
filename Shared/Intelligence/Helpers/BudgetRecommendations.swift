import Foundation
import MomentumFinanceCore

// MARK: - Budget Recommendations

/// Create budget recommendations based on spending patterns
func fi_findBudgetRecommendations(transactions: [FinancialTransaction], budgets: [Budget])
    -> [FinancialInsight]
{
    var insights: [FinancialInsight] = []

    // Group by category
    // Map categories to a non-optional key (use category name or "Uncategorized")
    let categorySpending = Dictionary(
        grouping:
            transactions
            .filter { $0.amount < 0 }
    ) { (tx: FinancialTransaction) -> String in
        tx.category ?? "Uncategorized"
    }

    let calendar = Calendar.current
    let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
    let monthsBack = 3

    var monthlyAverages: [String: Decimal] = [:]

    for (category, categoryTransactions) in categorySpending {
        let monthlySpends = (0..<monthsBack).compactMap { monthOffset -> Decimal? in
            let targetMonth = calendar.date(
                byAdding: .month, value: -monthOffset, to: currentMonth)!
            let monthTransactions = categoryTransactions.filter {
                calendar.date(from: calendar.dateComponents([.year, .month], from: $0.date))
                    == calendar
                    .date(
                        from: calendar.dateComponents(
                            [.year, .month],
                            from: targetMonth
                        ))
            }
            guard !monthTransactions.isEmpty else { return nil }
            return monthTransactions.reduce(0) { $0 + abs($1.amount) }
        }

        if !monthlySpends.isEmpty {
            monthlyAverages[category] = monthlySpends.reduce(0, +) / Decimal(monthlySpends.count)
        }
    }

    // Generate budget recommendations
    // Build a lookup of current budgets keyed by category name
    var currentBudget: [String: Decimal] = [:]
    for b in budgets {
        if let cname = b.category {
            currentBudget[cname] = b.limitAmount
        }
    }

    for (categoryName, averageSpend) in monthlyAverages.sorted(by: { $0.value > $1.value }) {
        let currentBudgetAmount = currentBudget[categoryName] ?? 0
        let recommendedBudget = averageSpend * 1.1  // 10% buffer

        if currentBudgetAmount == 0 {
            // No budget set
            let budgetDescription =
                "Based on your average spending of \(fi_formatCurrency(averageSpend)), "
                + "consider setting a budget of \(fi_formatCurrency(recommendedBudget)) for \(categoryName)."

            let insight = FinancialInsight(
                title: "Budget Recommendation: \(categoryName)",
                description: budgetDescription,
                priority: .medium,
                type: .budgetRecommendation,
                relatedAccountId: nil,
                relatedTransactionId: nil,
                relatedCategoryId: categoryName,
                relatedBudgetId: nil,
                visualizationType: nil,
                chartData: [
                    ChartDataPoint(
                        label: "Average Spending",
                        value: Double(truncating: averageSpend as NSDecimalNumber)),
                    ChartDataPoint(
                        label: "Recommended Budget",
                        value: Double(truncating: recommendedBudget as NSDecimalNumber)),
                ]
            )
            insights.append(insight)
        } else if currentBudgetAmount < averageSpend * 0.8 {
            // Budget too low
            let budgetDescription =
                "Your current budget of \(fi_formatCurrency(currentBudgetAmount)) for \(categoryName) "
                + "may be too low. Consider increasing it to \(fi_formatCurrency(recommendedBudget))."

            let insight = FinancialInsight(
                title: "Budget Adjustment: \(categoryName)",
                description: budgetDescription,
                priority: .medium,
                type: .budgetRecommendation,
                relatedAccountId: nil,
                relatedTransactionId: nil,
                relatedCategoryId: categoryName,
                relatedBudgetId: nil,
                visualizationType: nil,
                chartData: [
                    ChartDataPoint(
                        label: "Current Budget",
                        value: Double(truncating: currentBudgetAmount as NSDecimalNumber)),
                    ChartDataPoint(
                        label: "Average Spending",
                        value: Double(truncating: averageSpend as NSDecimalNumber)),
                    ChartDataPoint(
                        label: "Recommended Budget",
                        value: Double(truncating: recommendedBudget as NSDecimalNumber)),
                ]
            )
            insights.append(insight)
        }
    }

    return insights
}
