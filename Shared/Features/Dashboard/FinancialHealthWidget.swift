import MomentumFinanceCore
import SwiftUI

/// Widget displaying key financial health metrics
struct FinancialHealthWidget: View {
    let transactions: [FinancialTransaction]
    let accounts: [FinancialAccount]

    @State private var burnRate: Decimal = 0
    @State private var savingRate: Double = 0
    @State private var anomalyCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.green)
                    .font(.title2)

                Text("Financial Health")
                    .font(.headline)

                Spacer()
            }

            Divider()

            // Key Metrics
            VStack(spacing: 12) {
                // Monthly Burn Rate
                MetricRow(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Monthly Burn Rate",
                    value: burnRate.formatted(.currency(code: "USD")),
                    subtitle: "Average monthly spending"
                )

                // Saving Rate
                MetricRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: savingRateColor,
                    title: "Saving Rate",
                    value: String(format: "%.1f%%", savingRate),
                    subtitle: savingRateDescription
                )

                // Spending Anomalies
                if anomalyCount > 0 {
                    MetricRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .red,
                        title: "Spending Anomalies",
                        value: "\(anomalyCount)",
                        subtitle: "Unusual transactions detected"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            calculateMetrics()
        }
        .onChange(of: transactions) { _ in
            calculateMetrics()
        }
    }

    private var savingRateColor: Color {
        if savingRate >= 20 {
            return .green
        } else if savingRate >= 10 {
            return .orange
        } else {
            return .red
        }
    }

    private var savingRateDescription: String {
        if savingRate >= 20 {
            return "Great job saving!"
        } else if savingRate >= 10 {
            return "Good progress"
        } else {
            return "Consider saving more"
        }
    }

    private func calculateMetrics() {
        let analyzer = SpendingAnalyzer.shared

        // Calculate burn rate
        let coreTransactions = transactions.map { transaction in
            CoreTransaction(
                id: UUID(),
                amount: transaction.amount,
                date: transaction.date,
                note: transaction.notes ?? "",
                categoryId: transaction.category?.id,
                accountId: transaction.account?.id
            )
        }

        burnRate = analyzer.calculateMonthlyBurnRate(transactions: coreTransactions)

        // Calculate saving rate
        let calendar = Calendar.current
        let now = Date()
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
            return
        }

        let recentTransactions = coreTransactions.filter { $0.date >= oneMonthAgo }
        let income = recentTransactions.filter { $0.amount > 0 }.reduce(Decimal(0)) {
            $0 + $1.amount
        }
        let expenses = recentTransactions.filter { $0.amount < 0 }.reduce(Decimal(0)) {
            $0 + abs($1.amount)
        }

        savingRate = analyzer.calculateSavingRate(income: income, expenses: expenses)

        // Detect anomalies
        let anomalies = analyzer.detectSpendingAnomalies(transactions: coreTransactions)
        anomalyCount = anomalies.count
    }
}

/// Reusable metric row component
private struct MetricRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    FinancialHealthWidget(
        transactions: [],
        accounts: []
    )
    .padding()
}
