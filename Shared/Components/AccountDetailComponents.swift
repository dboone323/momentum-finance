//
//  AccountDetailComponents.swift
//  MomentumFinance
//
//  Extracted components from EnhancedAccountDetailView for SwiftLint compliance
//

import Charts
import MomentumFinanceCore
import SwiftData
import SwiftUI

#if os(macOS)

    // MARK: - Shared Account Components

    enum TimeFrame: String, CaseIterable, Identifiable {
        case last30Days = "Last 30 Days"
        case last90Days = "Last 90 Days"
        case thisYear = "This Year"
        case lastYear = "Last Year"
        case allTime = "All Time"

        var id: String { rawValue }
    }

    struct AccountTypeBadge: View {
        let type: AccountType

        private var text: String {
            switch self.type {
            case .checking: "Checking"
            case .savings: "Savings"
            case .credit: "Credit"
            case .investment: "Investment"
            case .cash: "Cash"
            }
        }

        private var color: Color {
            switch self.type {
            case .checking: .green
            case .savings: .blue
            case .credit: .purple
            case .investment: .orange
            case .cash: .gray
            }
        }

        var body: some View {
            Text(self.text)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(self.color.opacity(0.1))
                .foregroundColor(self.color)
                .cornerRadius(4)
        }
    }

    struct BalanceTrendChart: View {
        let account: FinancialAccount
        let timeFrame: TimeFrame

        // Sample data - would be real data in actual implementation
        /// <#Description#>
        /// - Returns: <#description#>
        func generateSampleData() -> [(date: String, balance: Double)] {
            [
                (date: "Jan", balance: 1250.00),
                (date: "Feb", balance: 1450.25),
                (date: "Mar", balance: 2100.50),
                (date: "Apr", balance: 1825.75),
                (date: "May", balance: 2200.00),
                (date: "Jun", balance: self.account.balance),
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Chart {
                    ForEach(self.generateSampleData(), id: \.date) { item in
                        LineMark(
                            x: .value("Month", item.date),
                            y: .value("Balance", item.balance)
                        )
                        .foregroundStyle(.blue)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8)
                        }
                        .interpolationMethod(.catmullRom)
                    }

                    ForEach(self.generateSampleData(), id: \.date) { item in
                        PointMark(
                            x: .value("Month", item.date),
                            y: .value("Balance", item.balance)
                        )
                        .foregroundStyle(.blue)
                    }

                    // Average line
                    let average =
                        self.generateSampleData()
                        .reduce(0.0) { $0 + $1.balance } / Double(self.generateSampleData().count)
                    RuleMark(y: .value("Average", average))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.gray)
                        .annotation(position: .top, alignment: .trailing) {
                            Text(
                                "Average: \(average.formatted(.currency(code: self.account.currencyCode)))"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("Starting Balance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$1,250.00")
                            .font(.subheadline)
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Text("Change")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(
                            "+\((self.account.balance - 1250).formatted(.currency(code: self.account.currencyCode)))"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Current Balance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(
                            "\(self.account.balance.formatted(.currency(code: self.account.currencyCode)))"
                        )
                        .font(.subheadline)
                        .bold()
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    struct CategoryData {
        let name: String
        let amount: Double
        let color: Color
    }

    struct SpendingBreakdownChart: View {
        let transactions: [FinancialTransaction]

        // This would normally calculate categories from actual transactions
        private var categories: [CategoryData] {
            [
                CategoryData(name: "Groceries", amount: 450.00, color: .green),
                CategoryData(name: "Dining", amount: 320.50, color: .blue),
                CategoryData(name: "Entertainment", amount: 150.25, color: .purple),
                CategoryData(name: "Shopping", amount: 280.75, color: .orange),
                CategoryData(name: "Utilities", amount: 190.30, color: .red),
            ]
        }

        private var totalSpending: Double {
            self.categories.reduce(0) { $0 + $1.amount }
        }

        var body: some View {
            VStack(spacing: 20) {
                // Pie chart
                HStack {
                    ZStack {
                        PieChartView(categories: self.categories)
                            .frame(width: 180, height: 180)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(self.categories, id: \.name) { category in
                            HStack {
                                Rectangle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)

                                Text(category.name)
                                    .font(.subheadline)

                                Spacer()

                                Text(category.amount.formatted(.currency(code: "USD")))
                                    .font(.subheadline)

                                Text("(\(Int((category.amount / self.totalSpending) * 100))%)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.leading)
                }

                Divider()

                // Top merchants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Merchants")
                        .font(.headline)

                    HStack {
                        Text("Merchant")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)

                        Spacer()

                        Text("Transactions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .center)

                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .trailing)
                    }

                    Divider()

                    VStack(spacing: 6) {
                        MerchantRow(name: "Whole Foods", count: 5, total: 245.75)
                        MerchantRow(name: "Amazon", count: 3, total: 157.92)
                        MerchantRow(name: "Starbucks", count: 8, total: 42.35)
                    }
                }
            }
        }
    }

    struct MerchantRow: View {
        let name: String
        let count: Int
        let total: Double

        var body: some View {
            HStack {
                Text(self.name)
                    .frame(width: 120, alignment: .leading)

                Spacer()

                Text("\(self.count)")
                    .frame(width: 100, alignment: .center)

                Text(self.total.formatted(.currency(code: "USD")))
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.vertical, 2)
        }
    }

    struct PieChartView: View {
        let categories: [CategoryData]

        var body: some View {
            let total = self.categories.reduce(0) { $0 + $1.amount }
            let sortedCategories = self.categories.sorted { $0.amount > $1.amount }

            Canvas { context, size in
                // Define the center and radius
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2

                // Keep track of the start angle
                var startAngle: Double = 0

                // Draw each category as a pie slice
                for category in sortedCategories {
                    let angleSize = (category.amount / total) * 360
                    let endAngle = startAngle + angleSize

                    // Create a path for the slice
                    var path = Path()
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                    path.closeSubpath()

                    // Fill the slice with the category color
                    context.fill(path, with: .color(category.color))

                    // Update the start angle for the next slice
                    startAngle = endAngle
                }

                // Add a white circle in the center for a donut chart effect
                let innerRadius = radius * 0.6
                let innerCirclePath = Path(
                    ellipseIn: CGRect(
                        x: center.x - innerRadius,
                        y: center.y - innerRadius,
                        width: innerRadius * 2,
                        height: innerRadius * 2
                    ))
                context.fill(innerCirclePath, with: .color(.white))
            }
        }
    }

    struct CreditAccountDetailsView: View {
        let account: FinancialAccount

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Credit Account Details")
                    .font(.headline)

                let creditLimit = self.account.creditLimit ?? 0
                let balance = abs(self.account.balance)
                let availableCredit = creditLimit - balance
                let utilization = creditLimit > 0 ? (balance / creditLimit) * 100 : 0

                Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                    GridRow {
                        DetailField(
                            label: "Credit Limit",
                            value: creditLimit.formatted(.currency(code: self.account.currencyCode))
                        )

                        DetailField(
                            label: "Available Credit",
                            value: availableCredit.formatted(
                                .currency(code: self.account.currencyCode))
                        )
                    }

                    GridRow {
                        DetailField(
                            label: "Utilization",
                            value: "\(String(format: "%.2f", utilization))%"
                        )
                        .gridCellColumns(2)
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)

                // Credit utilization chart
                if let creditLimit = account.creditLimit, creditLimit > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Credit Utilization")
                            .font(.subheadline)

                        ProgressView(value: abs(self.account.balance), total: creditLimit)
                            .tint(
                                self.getCreditUtilizationColor(
                                    used: abs(self.account.balance), limit: creditLimit))

                        HStack {
                            Text(
                                "Used: \(abs(self.account.balance).formatted(.currency(code: self.account.currencyCode)))"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Spacer()

                            Text(
                                "Limit: \(creditLimit.formatted(.currency(code: self.account.currencyCode)))"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }

        private func getCreditUtilizationColor(used: Double, limit: Double) -> Color {
            let percentage = used / limit
            if percentage < 0.3 {
                return .green
            } else if percentage < 0.7 {
                return .yellow
            } else {
                return .red
            }
        }
    }

    struct AccountExportOptionsView: View {
        let account: FinancialAccount?
        let transactions: [FinancialTransaction]
        @State private var exportFormat: ExportFormat = .csv
        @State private var dateRange: DateRange = .all
        @State private var customStartDate = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        @State private var customEndDate = Date()
        @Environment(\.dismiss) private var dismiss

        enum ExportFormat: String, CaseIterable {
            case csv = "CSV"
            case pdf = "PDF"
            case qif = "QIF"
        }

        enum DateRange: String, CaseIterable {
            case last30Days = "Last 30 Days"
            case last90Days = "Last 90 Days"
            case thisYear = "This Year"
            case custom = "Custom Range"
            case all = "All Transactions"
        }

        var body: some View {
            VStack(spacing: 20) {
                Text("Export Account Transactions")
                    .font(.title2)
                    .padding(.vertical)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Format")
                            .font(.headline)

                        Picker("Format", selection: self.$exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Range")
                            .font(.headline)

                        Picker("Date Range", selection: self.$dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 400)
                    }

                    if self.dateRange == .custom {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Start Date")
                                    .font(.subheadline)
                                DatePicker(
                                    "", selection: self.$customStartDate, displayedComponents: .date
                                )
                                .labelsHidden()
                            }

                            VStack(alignment: .leading) {
                                Text("End Date")
                                    .font(.subheadline)
                                DatePicker(
                                    "", selection: self.$customEndDate, displayedComponents: .date
                                )
                                .labelsHidden()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Details")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Account Name: \(self.account?.name ?? "Unknown")")
                            Text("• Transaction Count: \(self.transactions.count)")
                            Text("• Fields: Date, Description, Category, Amount, Balance")

                            if self.exportFormat == .pdf {
                                Text("• Includes account summary and balance chart")
                            }
                        }
                        .font(.subheadline)
                    }
                }

                Spacer()

                HStack {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Button")
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Export") {
                        self.performExport()
                        self.dismiss()
                    }
                    .accessibilityLabel("Button")
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
            }
            .padding()
        }

        private func performExport() {
            // Export logic would go here
        }
    }

    struct AccountEditModel {
        var name: String
        var type: AccountType
        var balance: Double
        var currencyCode: String
        var institution: String?
        var accountNumber: String?
        var interestRate: Double?
        var creditLimit: Double?
        var dueDate: Int?
        var includeInTotal: Bool
        var isActive: Bool
        var notes: String?

        init(from account: FinancialAccount) {
            self.name = account.name
            self.type = account.accountType
            self.balance = account.balance
            self.currencyCode = account.currencyCode
            self.dueDate = nil
            self.includeInTotal = true
            self.isActive = true
            self.notes = ""
        }
    }

#endif
