import Foundation
import MomentumFinanceCore

// MARK: - Optimization Suggestions

/// Suggest insights for idle cash optimization
func fi_suggestIdleCashInsights(
    transactions: [FinancialTransaction],
    accounts: [FinancialAccount]
) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let checkingAccounts = accounts.filter { $0.accountType == .checking }
    for account in checkingAccounts {
        guard account.balance > 5000 else { continue }

        let accountTransactions = transactions.filter {
            $0.account?.id == account.id && $0.amount < 0
        }

        let calendar = Calendar.current
        let monthlyTransactions = Dictionary(grouping: accountTransactions) { transaction in
            calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date))
        }

        let monthlyExpenses = monthlyTransactions.map { $0.value.reduce(0) { $0 + abs($1.amount) } }
        let averageMonthlyExpense = monthlyExpenses.isEmpty
            ? 0
            : monthlyExpenses.reduce(0, +) / Double(monthlyExpenses.count)

        let recommendedBuffer = averageMonthlyExpense * 2

        if account.balance > recommendedBuffer {
            let excessCash = account.balance - recommendedBuffer
            let excessCashStr = fi_formatCurrency(excessCash, code: account.currencyCode)
            let accountName = account.name
            let idleDescription = "You have \(excessCashStr) more than needed in your \(accountName). "
                + "Consider moving some to a higher-yielding savings or investment account."

            let insight = FinancialInsight(
                title: "Idle Cash Detected",
                description: idleDescription,
                priority: .medium,
                type: .optimization,
                relatedAccountId: String(account.id.hashValue),
                chartData: [
                    ChartDataPoint(label: "Current Balance", value: account.balance),
                    ChartDataPoint(label: "Recommended Buffer", value: recommendedBuffer),
                    ChartDataPoint(label: "Excess Cash", value: excessCash),
                ]
            )
            insights.append(insight)
        }
    }

    return insights
}

/// Suggest insights for credit utilization optimization
func fi_suggestCreditUtilizationInsights(accounts: [FinancialAccount]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let creditAccounts = accounts.filter { $0.accountType == .creditCard }
    for account in creditAccounts {
        let balance = abs(account.balance)
        guard balance > 0 else { continue }

        // Current account model does not store credit limit, so use a conservative
        // high-balance threshold to surface repayment guidance.
        let suggestedMaxRevolvingBalance = 1000.0
        if balance > suggestedMaxRevolvingBalance {
            let utilDescription = "Your outstanding balance on \(account.name) is "
                + fi_formatCurrency(balance, code: account.currencyCode)
                + ". Paying this down can help improve credit health and reduce interest charges."

            let insight = FinancialInsight(
                title: "High Credit Balance",
                description: utilDescription,
                priority: balance > 2500 ? .critical : .high,
                type: .creditUtilization,
                relatedAccountId: String(account.id.hashValue),
                visualizationType: .progressBar,
                chartData: [
                    ChartDataPoint(label: "Balance", value: balance),
                    ChartDataPoint(
                        label: "Suggested Max Revolving Balance",
                        value: suggestedMaxRevolvingBalance
                    ),
                ]
            )
            insights.append(insight)
        }
    }

    return insights
}
