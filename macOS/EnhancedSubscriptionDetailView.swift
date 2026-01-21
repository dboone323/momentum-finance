// Momentum Finance - Enhanced Subscription Detail View for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SubscriptionDetailComponents
import SwiftData
import SwiftUI

#if os(macOS)
    extension Features.Subscriptions {
        /// Enhanced subscription detail view optimized for macOS screen real estate
        struct EnhancedSubscriptionDetailView: View {
            let subscriptionId: String

            @Environment(\.modelContext) private var modelContext
            @Query private var subscriptions: [Subscription]
            @Query private var accounts: [FinancialAccount]
            @Query private var transactions: [FinancialTransaction]
            @State private var isEditing = false
            @State private var editedSubscription: SubscriptionEditModel?
            @State private var selectedTransactionIds: Set<String> = []
            @State private var selectedTimespan: Timespan = .sixMonths
            @State private var showingDeleteConfirmation = false
            @State private var showingCancelFlow = false
            @State private var showingShoppingAlternatives = false
            @State private var validationErrors: [String: String] = [:]
            @State private var showingValidationAlert = false

            private var subscription: Subscription? {
                self.subscriptions.first(where: { $0.id == self.subscriptionId })
            }

            private var relatedTransactions: [FinancialTransaction] {
                guard let subscription, let subscriptionId = subscription.id else { return [] }

                return self.transactions.filter { transaction in
                    // Match transactions by subscription ID or by name pattern
                    if let relatedSubscriptionId = transaction.subscriptionId, relatedSubscriptionId == subscriptionId {
                        return true
                    }

                    if transaction.name.lowercased().contains(subscription.name.lowercased()) {
                        return true
                    }

                    return false
                }.sorted { $0.date > $1.date }
            }

            // swiftlint:disable:next nesting
            enum Timespan: String, CaseIterable, Identifiable {
                case threeMonths = "3 Months"
                case sixMonths = "6 Months"
                case oneYear = "1 Year"
                case twoYears = "2 Years"
                case allTime = "All Time"

                var id: String { rawValue }
            }

            var body: some View {
                VStack(spacing: 0) {
                    // Top toolbar with actions
                    HStack {
                        if let subscription {
                            Text(subscription.name)
                                .font(.title)
                                .bold()
                        }

                        Spacer()

                        Picker("Time Span", selection: self.$selectedTimespan) {
                            ForEach(Timespan.allCases) { timespan in
                                Text(timespan.rawValue).tag(timespan)
                            }
                        }
                        .frame(width: 150)

                        Button(
                            action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button")
                            },
                            label: {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        )
                        .keyboardShortcut("e", modifiers: .command)

                        Menu {
                            Button("Mark as Paid", action: self.markAsPaid).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Button("Skip Next Payment", action: self.skipNextPayment).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Divider()
                            Button("Pause Subscription", action: self.pauseSubscription).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Button("Cancel Subscription...", action: { self.showingCancelFlow = true })
                                .accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Divider()
                            Button("Find Alternatives...", action: { self.showingShoppingAlternatives = true })
                                .accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Divider()
                            Button("Export as PDF", action: self.exportAsPDF).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Button("Print", action: self.printSubscription).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Divider()
                            Button("Delete", role: .destructive).accessibilityLabel("Button")
                                .accessibilityLabel("Button") {
                                    self.showingDeleteConfirmation = true
                                }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))

                    Divider()

                    if self.isEditing, let subscription {
                        self.editView(for: subscription)
                            .padding()
                            .transition(.opacity)
                    } else {
                        self.detailView()
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .alert("Delete Subscription", isPresented: self.$showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
                    Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.deleteSubscription()
                    }
                } message: {
                    Text("Are you sure you want to delete this subscription? This action cannot be undone.")
                }
                .sheet(isPresented: self.$showingCancelFlow) {
                    SubscriptionCancellationAssistantView(subscription: self.subscription)
                        .frame(width: 600, height: 500)
                }
                .sheet(isPresented: self.$showingShoppingAlternatives) {
                    SubscriptionAlternativesView(subscription: self.subscription)
                        .frame(width: 700, height: 600)
                }
                .onAppear {
                    // Initialize edit model if needed
                    if let subscription, editedSubscription == nil {
                        self.editedSubscription = SubscriptionEditModel(from: subscription)
                    }
                }
            }

            // MARK: - Detail View

            private func detailView() -> some View {
                guard let subscription else {
                    return AnyView(
                        ContentUnavailableView(
                            "Subscription Not Found",
                            systemImage: "exclamationmark.triangle",
                            description: Text("The subscription you're looking for could not be found.")
                        )
                    )
                }

                return AnyView(
                    HStack(spacing: 0) {
                        // Left panel - subscription details and analytics
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Subscription overview
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                SubscriptionLogo(provider: subscription.provider)
                                                    .frame(width: 40, height: 40)
                                                    .padding(6)
                                                    .background(Color(.windowBackgroundColor).opacity(0.5))
                                                    .cornerRadius(8)

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(subscription.provider)
                                                        .font(.headline)

                                                    Text(subscription.category ?? "Subscription")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            SubscriptionStatusBadge(
                                                isActive: subscription.nextPaymentDate != nil,
                                                autoRenews: subscription.autoRenews
                                            )
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(subscription.amount
                                                .formatted(.currency(code: subscription.currencyCode)))
                                                .font(.system(size: 28, weight: .bold))

                                            Text(self.formatBillingCycle(subscription.billingCycle))
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Divider()

                                    // Cost breakdown
                                    Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                                        GridRow {
                                            SubscriptionDetailField(
                                                label: "Monthly Cost",
                                                value: self.calculateMonthlyCost(subscription)
                                                    .formatted(.currency(code: subscription.currencyCode))
                                            )

                                            SubscriptionDetailField(
                                                label: "Annual Cost",
                                                value: self.calculateAnnualCost(subscription)
                                                    .formatted(.currency(code: subscription.currencyCode))
                                            )
                                        }

                                        GridRow {
                                            if let nextPayment = subscription.nextPaymentDate {
                                                SubscriptionDetailField(
                                                    label: "Next Payment",
                                                    value: nextPayment.formatted(date: .abbreviated, time: .omitted)
                                                )
                                            } else {
                                                SubscriptionDetailField(label: "Next Payment", value: "Not scheduled")
                                            }

                                            if let startDate = subscription.startDate {
                                                SubscriptionDetailField(
                                                    label: "Started On",
                                                    value: startDate.formatted(date: .abbreviated, time: .omitted)
                                                )
                                            }
                                        }

                                        if let paymentMethod = subscription.paymentMethod {
                                            GridRow {
                                                SubscriptionDetailField(label: "Payment Method", value: paymentMethod)
                                                    .gridCellColumns(2)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)

                                // Cost analysis
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Cost Analysis")
                                        .font(.headline)

                                    PaymentHistoryChart(subscription: subscription)
                                        .frame(height: 220)

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Total Spent")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(self.calculateTotalSpent(subscription)
                                                .formatted(.currency(code: subscription.currencyCode)))
                                                .font(.headline)
                                        }

                                        Spacer()

                                        VStack(alignment: .center) {
                                            Text("Average Monthly")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(self.calculateMonthlyCost(subscription)
                                                .formatted(.currency(code: subscription.currencyCode)))
                                                .font(.headline)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing) {
                                            Text("% of Monthly Budget")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("3.2%")
                                                .font(.headline)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)

                                // Value assessment
                                ValueAssessmentView(subscription: subscription)

                                // Notes
                                if !subscription.notes.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Notes")
                                            .font(.headline)

                                        Text(subscription.notes)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.windowBackgroundColor).opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    .padding()
                                    .background(Color(.windowBackgroundColor).opacity(0.3))
                                    .cornerRadius(8)
                                }

                                // Upcoming dates
                                if let nextDate = subscription.nextPaymentDate {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Upcoming Payments")
                                            .font(.headline)

                                        VStack(spacing: 10) {
                                            ForEach(0..<4) { i in
                                                HStack {
                                                    if i == 0 {
                                                        Text(nextDate.formatted(date: .abbreviated, time: .omitted))
                                                            .foregroundStyle(.primary)
                                                    } else {
                                                        Text(self.calculateFuturePaymentDate(
                                                            from: nextDate,
                                                            offset: i,
                                                            cycle: subscription.billingCycle
                                                        ).formatted(date: .abbreviated, time: .omitted))
                                                            .foregroundStyle(.secondary)
                                                    }

                                                    Spacer()

                                                    Text(subscription.amount
                                                        .formatted(.currency(code: subscription.currencyCode)))
                                                        .foregroundStyle(i == 0 ? .primary : .secondary)
                                                }
                                                .padding(.vertical, 4)

                                                if i < 3 {
                                                    Divider()
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(.windowBackgroundColor).opacity(0.2))
                                        .cornerRadius(8)
                                    }
                                    .padding()
                                    .background(Color(.windowBackgroundColor).opacity(0.3))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)

                        Divider()

                        // Right panel - payment history
                        VStack(spacing: 0) {
                            // Transactions header
                            HStack {
                                Text("Payment History")
                                    .font(.headline)

                                Spacer()

                                Button(action: self.addTransaction).accessibilityLabel("Button")
                                    .accessibilityLabel("Button") {
                                        Label("Add", systemImage: "plus")
                                    }
                                    .buttonStyle(.bordered)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.5))

                            Divider()

                            // Transactions list
                            if self.relatedTransactions.isEmpty {
                                ContentUnavailableView {
                                    Label("No Payment History", systemImage: "creditcard")
                                } description: {
                                    Text("No payment records found for this subscription.")
                                } actions: {
                                    Button("Add Payment Record").accessibilityLabel("Button")
                                        .accessibilityLabel("Button") {
                                            self.addTransaction()
                                        }
                                        .buttonStyle(.bordered)
                                }
                                .frame(maxHeight: .infinity)
                            } else {
                                List(self.relatedTransactions, selection: self.$selectedTransactionIds) {
                                    self.paymentRow(for: $0)
                                }
                                .listStyle(.inset)
                            }
                        }
                        .frame(width: 350)
                    }
                )
            }

            // MARK: - Edit View

            private func editView(for subscription: Subscription) -> some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Subscription")
                        .font(.title2)

                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                        // Name field
                        GridRow {
                            Text("Name:")
                                .gridColumnAlignment(.trailing)

                            TextField("Subscription name", text: Binding(
                                get: { self.editedSubscription?.name ?? subscription.name },
                                set: { self.editedSubscription?.name = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }

                        // Provider field
                        GridRow {
                            Text("Provider:")
                                .gridColumnAlignment(.trailing)

                            TextField("Service provider", text: Binding(
                                get: { self.editedSubscription?.provider ?? subscription.provider },
                                set: { self.editedSubscription?.provider = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }

                        // Amount field
                        GridRow {
                            Text("Amount:")
                                .gridColumnAlignment(.trailing)

                            HStack {
                                TextField("Amount", value: Binding(
                                    get: { self.editedSubscription?.amount ?? subscription.amount },
                                    set: { self.editedSubscription?.amount = $0 }
                                ), format: .currency(code: subscription.currencyCode))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 150)

                                Picker("Currency", selection: Binding(
                                    get: { self.editedSubscription?.currencyCode ?? subscription.currencyCode },
                                    set: { self.editedSubscription?.currencyCode = $0 }
                                )) {
                                    Text("USD").tag("USD")
                                    Text("EUR").tag("EUR")
                                    Text("GBP").tag("GBP")
                                    Text("CAD").tag("CAD")
                                }
                            }
                        }

                        // Billing cycle field
                        GridRow {
                            Text("Billing Cycle:")
                                .gridColumnAlignment(.trailing)

                            Picker("Billing Cycle", selection: Binding(
                                get: { self.editedSubscription?.billingCycle ?? subscription.billingCycle },
                                set: { self.editedSubscription?.billingCycle = $0 }
                            )) {
                                Text("Monthly").tag("monthly")
                                Text("Quarterly").tag("quarterly")
                                Text("Annual").tag("annual")
                                Text("Weekly").tag("weekly")
                                Text("Biweekly").tag("biweekly")
                                Text("Custom").tag("custom")
                            }
                        }

                        // Payment dates
                        GridRow {
                            Text("Start Date:")
                                .gridColumnAlignment(.trailing)

                            DatePicker("Start Date", selection: Binding(
                                get: { self.editedSubscription?.startDate ?? subscription.startDate ?? Date() },
                                set: { self.editedSubscription?.startDate = $0 }
                            ), displayedComponents: .date)
                                .labelsHidden()
                        }

                        GridRow {
                            Text("Next Payment:")
                                .gridColumnAlignment(.trailing)

                            DatePicker("Next Payment", selection: Binding(
                                get: {
                                    self.editedSubscription?.nextPaymentDate ?? subscription.nextPaymentDate ?? Date()
                                },
                                set: { self.editedSubscription?.nextPaymentDate = $0 }
                            ), displayedComponents: .date)
                                .labelsHidden()
                        }

                        // Payment method field
                        GridRow {
                            Text("Payment Method:")
                                .gridColumnAlignment(.trailing)

                            Picker("Payment Method", selection: Binding(
                                get: { self.editedSubscription?.paymentMethod ?? subscription.paymentMethod ?? "" },
                                set: { self.editedSubscription?.paymentMethod = $0 }
                            )) {
                                Text("None").tag("")
                                Text("Credit Card").tag("Credit Card")
                                Text("Bank Account").tag("Bank Account")
                                Text("PayPal").tag("PayPal")
                                Text("Apple Pay").tag("Apple Pay")
                            }
                        }

                        // Category field
                        GridRow {
                            Text("Category:")
                                .gridColumnAlignment(.trailing)

                            Picker("Category", selection: Binding(
                                get: { self.editedSubscription?.category ?? subscription.category ?? "" },
                                set: { self.editedSubscription?.category = $0 }
                            )) {
                                Text("None").tag("")
                                Text("Entertainment").tag("Entertainment")
                                Text("Software").tag("Software")
                                Text("Streaming").tag("Streaming")
                                Text("Utilities").tag("Utilities")
                                Text("Other").tag("Other")
                            }
                        }

                        // Auto-renew field
                        GridRow {
                            Text("Auto-renew:")
                                .gridColumnAlignment(.trailing)

                            Toggle("This subscription auto-renews", isOn: Binding(
                                get: { self.editedSubscription?.autoRenews ?? subscription.autoRenews },
                                set: { self.editedSubscription?.autoRenews = $0 }
                            ))
                        }
                    }
                    .padding(.bottom, 20)

                    Text("Notes:")
                        .padding(.top, 10)

                    TextEditor(text: Binding(
                        get: { self.editedSubscription?.notes ?? subscription.notes },
                        set: { self.editedSubscription?.notes = $0 }
                    ))
                    .font(.body)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(4)

                    HStack {
                        Spacer()

                        Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                            self.isEditing = false
                            // Reset edited subscription to original
                            if let subscription {
                                self.editedSubscription = SubscriptionEditModel(from: subscription)
                            }
                        }
                        .buttonStyle(.bordered)
                        .keyboardShortcut(.escape, modifiers: [])

                        Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                            self.saveChanges()
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .padding(.top)
                }
            }

            // MARK: - Supporting Views

            private func paymentRow(for transaction: FinancialTransaction) -> some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)

                        Text(transaction.isReconciled ? "Paid" : "Pending")
                            .font(.caption)
                            .foregroundStyle(transaction.isReconciled ? .green : .orange)
                    }

                    Spacer()

                    Text(transaction.amount.formatted(.currency(code: "USD")))
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
                .contextMenu {
                    Button("View Details").accessibilityLabel("Button").accessibilityLabel("Button") {
                        // Navigate to transaction detail
                    }

                    Button("Edit").accessibilityLabel("Button").accessibilityLabel("Button") {
                        // Edit transaction
                    }

                    Divider()

                    Button("Mark as \(transaction.isReconciled ? "Unpaid" : "Paid")") {
                        self.toggleTransactionStatus(transaction)
                    }
                }
            }

            // MARK: - Helper Methods

            private func formatBillingCycle(_ cycle: String) -> String {
                switch cycle {
                case "monthly": "Billed Monthly"
                case "annual": "Billed Annually"
                case "quarterly": "Billed Quarterly"
                case "weekly": "Billed Weekly"
                case "biweekly": "Billed Biweekly"
                default: "Custom Billing"
                }
            }

            private func calculateMonthlyCost(_ subscription: Subscription) -> Double {
                switch subscription.billingCycle {
                case "monthly": subscription.amount
                case "annual": subscription.amount / 12
                case "quarterly": subscription.amount / 3
                case "weekly": subscription.amount * 4.33 // Average weeks in a month
                case "biweekly": subscription.amount * 2.17 // Average bi-weeks in a month
                default: subscription.amount
                }
            }

            private func calculateAnnualCost(_ subscription: Subscription) -> Double {
                switch subscription.billingCycle {
                case "monthly": subscription.amount * 12
                case "annual": subscription.amount
                case "quarterly": subscription.amount * 4
                case "weekly": subscription.amount * 52
                case "biweekly": subscription.amount * 26
                default: subscription.amount * 12
                }
            }

            private func calculateTotalSpent(_ subscription: Subscription) -> Double {
                // In a real app, this would sum up actual transactions
                guard let startDate = subscription.startDate else { return 0 }

                let monthsSinceStart = Calendar.current.dateComponents([.month], from: startDate, to: Date()).month ?? 0
                return self.calculateMonthlyCost(subscription) * Double(monthsSinceStart)
            }

            private func calculateFuturePaymentDate(from date: Date, offset: Int, cycle: String) -> Date {
                let calendar = Calendar.current

                switch cycle {
                case "monthly":
                    return calendar.date(byAdding: .month, value: offset, to: date) ?? date
                case "annual":
                    return calendar.date(byAdding: .year, value: offset, to: date) ?? date
                case "quarterly":
                    return calendar.date(byAdding: .month, value: offset * 3, to: date) ?? date
                case "weekly":
                    return calendar.date(byAdding: .weekOfYear, value: offset, to: date) ?? date
                case "biweekly":
                    return calendar.date(byAdding: .weekOfYear, value: offset * 2, to: date) ?? date
                default:
                    return calendar.date(byAdding: .month, value: offset, to: date) ?? date
                }
            }

            // MARK: - Action Methods

            private func saveChanges() {
                guard let subscription, let editData = editedSubscription else {
                    self.isEditing = false
                    return
                }

                // Update subscription with edited values
                subscription.name = editData.name
                subscription.provider = editData.provider
                subscription.amount = editData.amount
                subscription.billingCycle = editData.billingCycle
                subscription.startDate = editData.startDate
                subscription.nextPaymentDate = editData.nextPaymentDate
                subscription.notes = editData.notes
                subscription.currencyCode = editData.currencyCode
                subscription.category = editData.category
                subscription.paymentMethod = editData.paymentMethod
                subscription.autoRenews = editData.autoRenews

                // Save changes to the model context
                try? self.modelContext.save()

                self.isEditing = false
            }

            private func deleteSubscription() {
                guard let subscription else { return }

                // Delete the subscription from the model context
                self.modelContext.delete(subscription)
                try? self.modelContext.save()

                // Navigate back would happen here
            }

            private func addTransaction() {
                // Logic to add a new transaction for this subscription
            }

            private func toggleTransactionStatus(_ transaction: FinancialTransaction) {
                transaction.isReconciled.toggle()
                try? self.modelContext.save()
            }

            private func markAsPaid() {
                guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

                // Create a new transaction for this payment
                let transaction = FinancialTransaction(
                    name: "\(subscription.provider) - \(subscription.name)",
                    amount: -subscription.amount,
                    date: nextDate,
                    notes: "Automatic payment for subscription",
                    isReconciled: true
                )

                transaction.subscriptionId = subscription.id

                // Calculate next payment date based on billing cycle
                if let newNextDate = calculateFuturePaymentDate(
                    from: nextDate,
                    offset: 1,
                    cycle: subscription.billingCycle
                ) {
                    subscription.nextPaymentDate = newNextDate
                }

                // Add transaction to the model context
                self.modelContext.insert(transaction)
                try? self.modelContext.save()
            }

            private func skipNextPayment() {
                guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

                // Calculate next payment date based on billing cycle and skip one period
                if let newNextDate = calculateFuturePaymentDate(
                    from: nextDate,
                    offset: 1,
                    cycle: subscription.billingCycle
                ) {
                    subscription.nextPaymentDate = newNextDate
                    try? self.modelContext.save()
                }
            }

            private func pauseSubscription() {
                guard let subscription else { return }

                // Store the current next payment date for later resumption
                // In a real app, you'd store this in the model
                let savedNextDate = subscription.nextPaymentDate

                // Clear the next payment date to indicate paused status
                subscription.nextPaymentDate = nil
                try? self.modelContext.save()
            }

            private func exportAsPDF() {
                // Implementation for PDF export
            }

            private func printSubscription() {
                // Implementation for printing
            }
        }
    }
#endif
