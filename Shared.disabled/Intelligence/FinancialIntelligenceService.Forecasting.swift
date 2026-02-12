import Foundation
import MomentumFinanceCore

@MainActor
extension FinancialIntelligenceService {
    func generateForecasts(transactions: [FinancialTransaction], accounts: [FinancialAccount])
        -> [FinancialInsight]
    {
        var insights: [FinancialInsight] = []

        // Analyze cash flow trend
        let calendar = Calendar.current
        // Removed unused sixMonthsAgo variable

        // Use helpers to compute monthly net cash flow and a simple forecast
        let monthlyPairs = fi_monthlyNetCashFlow(transactions)
        let sortedMonths = monthlyPairs
        if sortedMonths.count >= 3 {
            let values = sortedMonths.map(\.1)
            let trend = fi_trendAndForecast(values: values)

            if let nextMonthForecast = trend.nextForecast {
                let title: String
                let priority: InsightPriority

                if nextMonthForecast < 0, trend.trendDirection == "declining" {
                    title = "Negative Cash Flow Forecast"
                    priority = .critical
                } else if nextMonthForecast < 0 {
                    title = "Potential Negative Cash Flow"
                    priority = .high
                } else if trend.trendDirection == "improving" {
                    title = "Improving Cash Flow"
                    priority = .low
                } else {
                    title = "Cash Flow Forecast"
                    priority = .medium
                }

                let lastMonths = sortedMonths.suffix(3).map { fi_formatMonthAbbrev($0.0) }
                var forecastLabels = lastMonths

                if let lastDate = sortedMonths.last?.0,
                   let nextMonth = calendar.date(byAdding: .month, value: 1, to: lastDate)
                {
                    forecastLabels.append(fi_formatMonthAbbrev(nextMonth))
                }

                let lastValues = values.suffix(3)
                var chartData: [(String, Double)] = Array(zip(lastMonths, lastValues))
                chartData.append((forecastLabels.last ?? "Next", nextMonthForecast))

                let trendDirection =
                    nextMonthForecast > (values.last ?? 0) ? "increasing" : "decreasing"

                let nextMonthFormatted = fi_formatCurrency(nextMonthForecast, code: "USD")
                let descA = "Your cash flow is \(trendDirection)."
                let descB = " Next month's estimated net flow is \(nextMonthFormatted)."
                let insight = FinancialInsight(
                    title: title,
                    description: descA + descB,
                    priority: priority,
                    type: InsightType.forecast,
                    visualizationType: VisualizationType.lineChart,
                    chartData: chartData.map { ChartDataPoint(label: $0.0, value: $0.1) }
                )
                insights.append(insight)
            }
        }

        // Generate balance forecast for each account
        for account in accounts {
            if let accountInsight = generateAccountForecastInsight(
                account: account,
                transactions: transactions,
                calendar: calendar
            ) {
                insights.append(accountInsight)
            }
        }

        return insights
    }

    private func generateAccountForecastInsight(
        account: FinancialAccount, transactions: [FinancialTransaction], calendar: Calendar
    ) -> FinancialInsight? {
        let accountTransactions = transactions.filter { $0.account?.id == account.id }
        let monthlyTransactions = Dictionary(grouping: accountTransactions) { transaction in
            calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date))
        }

        // We need at least 3 months of data for a meaningful forecast
        guard monthlyTransactions.count >= 3 else { return nil }

        let sortedMonths = monthlyTransactions.sorted { lhs, rhs in
            guard let lhsKey = lhs.key, let rhsKey = rhs.key else { return false }
            return lhsKey < rhsKey
        }
        let monthlyNetFlow = sortedMonths.map { month, transactions in
            (month, transactions.reduce(Decimal(0)) { $0 + $1.amount })
        }

        // Calculate average monthly change
        let monthlyChanges = monthlyNetFlow.map(\.1)
        let averageMonthlyChange =
            monthlyChanges.reduce(Decimal(0), +) / Decimal(monthlyChanges.count)

        // Forecast next 3 months
        let forecastData = fi_projectedBalances(
            startingBalance: account.balance,
            monthlyChange: averageMonthlyChange,
            months: 3,
            calendar: calendar
        )
        let threeMonthPrediction = account.balance + (averageMonthlyChange * Decimal(3))

        let title: String
        let priority: InsightPriority
        let description: String

        if averageMonthlyChange < 0, threeMonthPrediction < account.balance * Decimal(0.5) {
            title = "Critical Balance Reduction"
            priority = .critical
            let dropAmount = fi_formatCurrency(
                Double(truncating: abs(averageMonthlyChange * Decimal(3)) as NSDecimalNumber),
                code: account.currencyCode
            )
            description =
                "Your \(account.name) balance is projected to drop by \(dropAmount) in the next 3 months."
        } else if averageMonthlyChange < 0 {
            title = "Declining Account Balance"
            priority = .high
            let declinePerMonth = fi_formatCurrency(
                Double(truncating: abs(averageMonthlyChange) as NSDecimalNumber),
                code: account.currencyCode
            )
            description =
                "Your \(account.name) balance is declining by approximately \(declinePerMonth) per month."
        } else if averageMonthlyChange > 0 {
            title = "Growing Account Balance"
            priority = .medium
            let growthPerMonth = fi_formatCurrency(
                Double(truncating: averageMonthlyChange as NSDecimalNumber),
                code: account.currencyCode
            )
            description =
                "Your \(account.name) balance is growing by approximately \(growthPerMonth) per month."
        } else {
            title = "Stable Account Balance"
            priority = .low
            description = "Your \(account.name) balance is stable."
        }

        return FinancialInsight(
            title: title,
            description: description,
            priority: priority,
            type: InsightType.forecast,
            relatedAccountId: String(account.id.hashValue),
            visualizationType: VisualizationType.lineChart,
            chartData: forecastData.map { ChartDataPoint(label: $0.0, value: $0.1) }
        )
    }

    /// Main forecasting function for helpers
    func fi_generateForecasts(
        transactions: [FinancialTransaction], accounts: [FinancialAccount]
    ) -> [FinancialInsight] {
        self.generateForecasts(transactions: transactions, accounts: accounts)
    }
}
