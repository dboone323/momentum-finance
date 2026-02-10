//
//  DetailViewComponents.swift
//  MomentumFinance
//
//  Extracted components from EnhancedDetailViews for SwiftLint compliance
//

import Charts
import MomentumFinanceCore
import SwiftData
import SwiftUI

#if os(macOS)

    // MARK: - Shared Detail Components

    struct DetailField: View {
        let label: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(self.value)
                    .font(.body)
            }
        }
    }

    struct CategoryTag: View {
        let category: ExpenseCategory

        var body: some View {
            HStack(spacing: 4) {
                Circle()
                    .fill(self.getCategoryColor(self.category.name))
                    .frame(width: 10, height: 10)

                Text(self.category.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(self.getCategoryColor(self.category.name).opacity(0.1))
            .cornerRadius(4)
        }

        private func getCategoryColor(_ name: String) -> Color {
            // Simple deterministic color based on name length/hash
            let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
            let index = abs(name.hashValue) % colors.count
            return colors[index]
        }
    }

    struct AttachmentThumbnail: View {
        let attachment: String
        var showDeleteButton: Bool = false

        var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack {
                    Image(systemName: "doc.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 4)

                    Text(self.attachment)
                        .font(.caption)
                        .lineLimit(1)
                }
                .padding(8)
                .frame(width: 100, height: 90)
                .background(Color(.windowBackgroundColor).opacity(0.5))
                .cornerRadius(8)

                if self.showDeleteButton {
                    Button(action: {}) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .background(Color.white.clipShape(Circle()))
                    }
                    .accessibilityLabel("Button")
                    .buttonStyle(.borderless)
                    .offset(x: 5, y: -5)
                }
            }
        }
    }

    struct BudgetImpactView: View {
        let category: ExpenseCategory
        let transactionAmount: Double

        // This would be calculated from actual budget data
        var budgetTotal: Double = 500
        var budgetSpent: Double = 325

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget Impact")
                    .font(.headline)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(self.category.name)
                            .font(.subheadline)

                        Text("Monthly Budget")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Text("\(self.budgetSpent.formatted(.currency(code: "USD")))")
                            Text("of")
                                .foregroundStyle(.secondary)
                            Text("\(self.budgetTotal.formatted(.currency(code: "USD")))")
                        }
                        .font(.subheadline)

                        Text("\(Int((self.budgetSpent / self.budgetTotal) * 100))% Used")
                            .font(.caption)
                            .foregroundStyle(
                                self.getBudgetColor(self.budgetSpent / self.budgetTotal))
                    }
                }

                ProgressView(value: self.budgetSpent, total: self.budgetTotal)
                    .tint(self.getBudgetColor(self.budgetSpent / self.budgetTotal))

                HStack {
                    Text(
                        "This transaction: \(self.transactionAmount.formatted(.currency(code: "USD")))"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Spacer()

                    Text(
                        "\(Int((self.transactionAmount / self.budgetTotal) * 100))% of monthly budget"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }

        private func getBudgetColor(_ percentage: Double) -> Color {
            if percentage < 0.7 {
                .green
            } else if percentage < 0.9 {
                .yellow
            } else {
                .red
            }
        }
    }

    struct CategorySpendingChart: View {
        let category: ExpenseCategory

        /// Sample data - would be real data in actual implementation
        let monthlyData = [
            (month: "Jan", amount: 78.50),
            (month: "Feb", amount: 92.30),
            (month: "Mar", amount: 45.75),
            (month: "Apr", amount: 120.00),
            (month: "May", amount: 87.25),
            (month: "Jun", amount: 95.50),
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Chart {
                    ForEach(self.monthlyData, id: \.month) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }

                    RuleMark(y: .value("Average", 86.55))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Average: $86.55")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("6 Month Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$519.30")
                            .font(.headline)
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Text("Monthly Average")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$86.55")
                            .font(.headline)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("% of Total Spending")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("8.3%")
                            .font(.headline)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    struct MerchantSpendingChart: View {
        let merchantName: String

        /// Sample data - would be real data in actual implementation
        let transactions = [
            (date: "Feb 3", amount: 45.99),
            (date: "Mar 5", amount: 52.25),
            (date: "Apr 2", amount: 48.50),
            (date: "May 7", amount: 55.75),
            (date: "Jun 4", amount: 50.30),
        ]

        var body: some View {
            VStack(alignment: .leading) {
                Chart {
                    ForEach(self.transactions, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Amount", item.amount)
                        )
                        .symbol(Circle().strokeBorder(lineWidth: 2))
                        .foregroundStyle(.blue)
                    }

                    ForEach(self.transactions, id: \.date) { item in
                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    struct TransactionExportOptionsView: View {
        let transaction: FinancialTransaction
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            VStack(spacing: 20) {
                Text("Export Transaction")
                    .font(.title)

                Picker("Format", selection: .constant("csv")) {
                    Text("CSV").tag("csv")
                    Text("PDF").tag("pdf")
                    Text("QIF").tag("qif")
                }
                .pickerStyle(.segmented)
                .frame(width: 300)

                // Export options and controls would go here

                HStack {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Button")
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Export") {
                        // Export logic
                        self.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Button")
                }
                .padding(.top)
            }
            .frame(width: 400)
            .padding()
        }
    }

    struct RelatedTransactionsView: View {
        let transaction: FinancialTransaction
        @Environment(\.dismiss) private var dismiss

        /// Sample data - would be actual transactions in implementation
        let relatedTransactions = [
            "January Grocery Shopping",
            "February Grocery Shopping",
            "March Grocery Shopping",
            "April Grocery Shopping",
            "May Grocery Shopping",
        ]

        var body: some View {
            VStack {
                Text("Transactions Similar to '\(self.transaction.title)'")
                    .font(.headline)
                    .padding()

                List(self.relatedTransactions, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Text("$\(Int.random(in: 45...95)).\(Int.random(in: 10...99))")
                            .foregroundStyle(.red)
                    }
                }

                Button("Close") {
                    self.dismiss()
                }
                .accessibilityLabel("Button")
                .buttonStyle(.bordered)
                .padding()
            }
            .frame(width: 500, height: 400)
        }
    }

    struct TransactionEditModel {
        var name: String
        var amount: Double
        var date: Date
        var notes: String
        var categoryId: String
        var accountId: String
        var isReconciled: Bool
        var isRecurring: Bool
        var location: String?
        var subcategory: String?

        init(from transaction: FinancialTransaction) {
            self.name = transaction.title
            self.amount = transaction.amount
            self.date = transaction.date
            self.notes = transaction.notes ?? ""
            self.categoryId = transaction.category?.id.uuidString ?? ""
            self.accountId = transaction.account?.name ?? "" // Using account name as ID for now
            self.isReconciled = transaction.isReconciled
            self.isRecurring = transaction.isRecurring
            self.location = transaction.location
            self.subcategory = transaction.subcategory
        }
    }

#endif
