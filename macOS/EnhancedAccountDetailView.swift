// Momentum Finance - Enhanced Account Detail View for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
    /// Enhanced account detail view optimized for macOS screen real estate
    struct EnhancedAccountDetailView: View {
        let accountId: String

        @Environment(\.modelContext) private var modelContext
        @Query private var accounts: [FinancialAccount]
        @Query private var transactions: [FinancialTransaction]
        @State private var isEditing = false
        @State private var editedAccount: AccountEditModel?
        @State private var selectedTransactionIds: Set<String> = []
        @State private var selectedTimeFrame: TimeFrame = .last30Days
        @State private var showingDeleteConfirmation = false
        @State private var showingExportOptions = false
        @State private var validationErrors: [String: String] = [:]
        @State private var showingValidationAlert = false

        private var account: FinancialAccount? {
            self.accounts.first(where: { $0.id == self.accountId })
        }

        private var filteredTransactions: [FinancialTransaction] {
            guard let account else { return [] }

            return self.transactions
                .filter {
                    $0.account?.id == self.accountId
                        && self.isTransactionInSelectedTimeFrame($0.date)
                }
                .sorted { $0.date > $1.date }
        }

        var body: some View {
            VStack(spacing: 0) {
                // Top toolbar with actions
                HStack {
                    if let account {
                        HStack(spacing: 8) {
                            Image(
                                systemName: account.type == .checking
                                    ? "banknote" : "creditcard.fill"
                            )
                            .font(.title)
                            .foregroundStyle(account.type == .checking ? .green : .blue)

                            Text(account.name)
                                .font(.title)
                                .bold()
                        }
                    }

                    Spacer()

                    Picker("Time Frame", selection: self.$selectedTimeFrame) {
                        ForEach(TimeFrame.allCases) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .frame(width: 150)

                    Button(
                        action: {
                            self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel(
                                "Button")
                        },
                        label: {
                            Text(self.isEditing ? "Done" : "Edit")
                        }
                    )
                    .keyboardShortcut("e", modifiers: .command)

                    Menu {
                        Button("Add Transaction", action: self.addTransaction).accessibilityLabel(
                            "Button"
                        )
                        .accessibilityLabel("Button")
                        Divider()
                        Button(
                            "Export Transactions...", action: { self.showingExportOptions = true }
                        )
                        .accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                        Button("Print Account Summary", action: self.printAccountSummary)
                            .accessibilityLabel("Button")
                            .accessibilityLabel("Button")
                        Divider()
                        Button("Delete Account", role: .destructive).accessibilityLabel("Button")
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

                if self.isEditing, let account {
                    self.editView(for: account)
                        .padding()
                        .transition(.opacity)
                } else {
                    self.detailView()
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert("Delete Account", isPresented: self.$showingDeleteConfirmation) {
                Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel(
                    "Button"
                ) {}
                Button("Delete", role: .destructive).accessibilityLabel("Button")
                    .accessibilityLabel("Button") {
                        self.deleteAccount()
                    }
            } message: {
                Text(
                    "Are you sure you want to delete this account? This will also delete all associated transactions and cannot be undone."
                )
            }
            .alert("Validation Error", isPresented: self.$showingValidationAlert) {
                Button("OK").accessibilityLabel("Button").accessibilityLabel("Button") {}
            } message: {
                Text("Please fix the validation errors before saving.")
            }
            .sheet(isPresented: self.$showingExportOptions) {
                AccountExportOptionsView(
                    account: self.account, transactions: self.filteredTransactions
                )
                .frame(width: 500, height: 400)
            }
            .onAppear {
                // Initialize edit model if needed
                if let account, editedAccount == nil {
                    self.editedAccount = AccountEditModel(from: account)
                }
            }
        }

        // MARK: - Detail View

        private func detailView() -> some View {
            guard let account else {
                return AnyView(
                    ContentUnavailableView(
                        "Account Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The account you're looking for could not be found.")
                    )
                )
            }

            return AnyView(
                HStack(spacing: 0) {
                    // Left panel - account details and analytics
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Account overview
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            AccountTypeBadge(type: account.type)

                                            Text(account.institution ?? "")
                                                .font(.headline)
                                        }

                                        if let accountNumber = account.accountNumber {
                                            Text("•••• \(String(accountNumber.suffix(4)))")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(
                                            account.balance.formatted(
                                                .currency(code: account.currencyCode))
                                        )
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(account.balance >= 0 ? .green : .red)

                                        Text("Current Balance")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Divider()

                                // Quick stats
                                Grid(
                                    alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12
                                ) {
                                    GridRow {
                                        DetailField(
                                            label: "Income",
                                            value: self.getIncomeTotal()
                                                .formatted(.currency(code: account.currencyCode))
                                        )
                                        .foregroundStyle(.green)

                                        DetailField(
                                            label: "Expenses",
                                            value: self.getExpensesTotal()
                                                .formatted(.currency(code: account.currencyCode))
                                        )
                                        .foregroundStyle(.red)
                                    }

                                    GridRow {
                                        DetailField(
                                            label: "Net Flow",
                                            value: self.getNetCashFlow()
                                                .formatted(.currency(code: account.currencyCode))
                                        )
                                        .foregroundStyle(self.getNetCashFlow() >= 0 ? .green : .red)

                                        DetailField(
                                            label: "Transactions",
                                            value: "\(self.filteredTransactions.count)")
                                    }

                                    if let interestRate = account.interestRate, interestRate > 0 {
                                        GridRow {
                                            DetailField(
                                                label: "Interest Rate",
                                                value: "\(interestRate.formatted(.percent))"
                                            )
                                            .gridCellColumns(2)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Balance trend chart
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Balance Trend")
                                    .font(.headline)

                                BalanceTrendChart(
                                    account: account, timeFrame: self.selectedTimeFrame
                                )
                                .frame(height: 220)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Spending breakdown
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Spending Breakdown")
                                    .font(.headline)

                                SpendingBreakdownChart(transactions: self.filteredTransactions)
                                    .frame(height: 280)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Account notes
                            if let notes = account.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.headline)

                                    Text(notes)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.windowBackgroundColor).opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                            }

                            // Credit account specifics
                            if account.type == .credit {
                                CreditAccountDetailsView(account: account)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Right panel - transactions list
                    VStack(spacing: 0) {
                        // Transactions header
                        HStack {
                            Text("Transactions")
                                .font(.headline)
                                .toolbar {
                                    ToolbarItem(placement: .automatic) {
                                        Button(action: self.toggleSidebar) {
                                            Image(systemName: "sidebar.left")
                                        }
                                        .accessibilityLabel("Toggle Sidebar")
                                        .help("Toggle Sidebar")
                                    }
                                }

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
                        if self.filteredTransactions.isEmpty {
                            ContentUnavailableView {
                                Label("No Transactions", systemImage: "list.bullet")
                            } description: {
                                Text(
                                    "No transactions found for this account in the selected time period."
                                )
                            } actions: {
                                Button("Add Transaction").accessibilityLabel("Button")
                                    .accessibilityLabel("Button") {
                                        self.addTransaction()
                                    }
                                    .buttonStyle(.bordered)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            List(self.filteredTransactions, selection: self.$selectedTransactionIds)
                            {
                                self.transactionRow(for: $0)
                            }
                            .listStyle(.inset)
                        }
                    }
                    .frame(width: 400)
                }
            )
        }

        // MARK: - Edit View

        private func editView(for account: FinancialAccount) -> some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Account")
                    .font(.title2)

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    // Name field
                    GridRow {
                        Text("Name:")
                            .gridColumnAlignment(.trailing)

                        VStack(alignment: .leading) {
                            TextField(
                                "Account name",
                                text: Binding(
                                    get: { self.editedAccount?.name ?? account.name },
                                    set: { newValue in
                                        self.editedAccount?.name = newValue
                                        self.validateAccountName(newValue)
                                    }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            if let error = self.validationErrors["name"] {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // Type field
                    GridRow {
                        Text("Type:")
                            .gridColumnAlignment(.trailing)

                        Picker(
                            "Type",
                            selection: Binding(
                                get: { self.editedAccount?.type ?? account.type },
                                set: { self.editedAccount?.type = $0 }
                            )
                        ) {
                            Text("Checking").tag(FinancialAccount.AccountType.checking)
                            Text("Savings").tag(FinancialAccount.AccountType.savings)
                            Text("Credit").tag(FinancialAccount.AccountType.credit)
                            Text("Investment").tag(FinancialAccount.AccountType.investment)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 400)
                    }

                    // Balance field
                    GridRow {
                        Text("Balance:")
                            .gridColumnAlignment(.trailing)

                        HStack {
                            TextField(
                                "Balance",
                                value: Binding(
                                    get: { self.editedAccount?.balance ?? account.balance },
                                    set: { self.editedAccount?.balance = $0 }
                                ), format: .currency(code: account.currencyCode)
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)

                            Picker(
                                "Currency",
                                selection: Binding(
                                    get: {
                                        self.editedAccount?.currencyCode ?? account.currencyCode
                                    },
                                    set: { self.editedAccount?.currencyCode = $0 }
                                )
                            ) {
                                Text("USD").tag("USD")
                                Text("EUR").tag("EUR")
                                Text("GBP").tag("GBP")
                                Text("CAD").tag("CAD")
                            }
                        }
                    }

                    // Institution field
                    GridRow {
                        Text("Institution:")
                            .gridColumnAlignment(.trailing)

                        VStack(alignment: .leading) {
                            TextField(
                                "Bank or financial institution",
                                text: Binding(
                                    get: {
                                        self.editedAccount?.institution ?? account.institution ?? ""
                                    },
                                    set: { newValue in
                                        self.editedAccount?.institution = newValue
                                        self.validateInstitution(newValue)
                                    }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            if let error = self.validationErrors["institution"] {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // Account number field
                    GridRow {
                        Text("Account Number:")
                            .gridColumnAlignment(.trailing)

                        VStack(alignment: .leading) {
                            TextField(
                                "Account number",
                                text: Binding(
                                    get: {
                                        self.editedAccount?.accountNumber ?? account.accountNumber
                                            ?? ""
                                    },
                                    set: { newValue in
                                        self.editedAccount?.accountNumber = newValue
                                        self.validateAccountNumber(newValue)
                                    }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            if let error = self.validationErrors["accountNumber"] {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // Interest rate field (for savings or credit)
                    if account.type == .savings || account.type == .credit {
                        GridRow {
                            Text("Interest Rate (%):")
                                .gridColumnAlignment(.trailing)

                            TextField(
                                "Interest rate",
                                value: Binding(
                                    get: {
                                        ((self.editedAccount?.interestRate ?? account.interestRate)
                                            ?? 0) * 100
                                    },
                                    set: { self.editedAccount?.interestRate = $0 / 100 }
                                ), format: .number
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        }
                    }

                    // Credit limit (for credit accounts)
                    if account.type == .credit {
                        GridRow {
                            Text("Credit Limit:")
                                .gridColumnAlignment(.trailing)

                            TextField(
                                "Credit limit",
                                value: Binding(
                                    get: {
                                        self.editedAccount?.creditLimit ?? account.creditLimit ?? 0
                                    },
                                    set: { self.editedAccount?.creditLimit = $0 }
                                ), format: .currency(code: account.currencyCode)
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                        }

                        GridRow {
                            Text("Due Date:")
                                .gridColumnAlignment(.trailing)

                            Picker(
                                "Due Date",
                                selection: Binding(
                                    get: { self.editedAccount?.dueDate ?? account.dueDate ?? 1 },
                                    set: { self.editedAccount?.dueDate = $0 }
                                )
                            ) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                        }
                    }

                    // Include in total
                    GridRow {
                        Text("Include in Totals:")
                            .gridColumnAlignment(.trailing)

                        Toggle(
                            "Include this account in dashboard totals",
                            isOn: Binding(
                                get: {
                                    self.editedAccount?.includeInTotal ?? account.includeInTotal
                                },
                                set: { self.editedAccount?.includeInTotal = $0 }
                            ))
                    }

                    // Active/Inactive
                    GridRow {
                        Text("Status:")
                            .gridColumnAlignment(.trailing)

                        Toggle(
                            "Account is active",
                            isOn: Binding(
                                get: { self.editedAccount?.isActive ?? account.isActive },
                                set: { self.editedAccount?.isActive = $0 }
                            ))
                    }
                }
                .padding(.bottom, 20)

                Text("Notes:")
                    .padding(.top, 10)

                TextEditor(
                    text: Binding(
                        get: { self.editedAccount?.notes ?? account.notes ?? "" },
                        set: { newValue in
                            self.editedAccount?.notes = newValue
                            self.validateNotes(newValue)
                        }
                    )
                )
                .font(.body)
                .frame(minHeight: 100)
                .padding(4)
                .background(Color(.textBackgroundColor))
                .cornerRadius(4)

                if let error = self.validationErrors["notes"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }

                HStack {
                    Spacer()

                    Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.isEditing = false
                        // Reset edited account to original
                        if let account {
                            self.editedAccount = AccountEditModel(from: account)
                        }
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.escape, modifiers: [])

                    Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                        if self.isValidForm() {
                            self.saveChanges()
                        } else {
                            self.showingValidationAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(!self.isValidForm())
                }
                .padding(.top)
            }
        }

        // MARK: - Supporting Views

        private func transactionRow(for transaction: FinancialTransaction) -> some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(.headline)

                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(transaction.amount.formatted(.currency(code: transaction.currencyCode)))
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                    .font(.subheadline)
            }
            .padding(.vertical, 4)
            .tag(transaction.id)
            .contextMenu {
                Button("View Details").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Navigate to transaction detail
                }

                Button("Edit").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Edit transaction
                }

                Divider()

                Button("Delete", role: .destructive).accessibilityLabel("Button")
                    .accessibilityLabel("Button") {
                        self.deleteTransaction(transaction)
                    }
            }
        }

        // MARK: - Supporting Views

        // MARK: - Helper Methods

        private func isTransactionInSelectedTimeFrame(_ date: Date) -> Bool {
            let calendar = Calendar.current
            let today = Date()

            switch self.selectedTimeFrame {
            case .last30Days:
                guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)
                else { return false }
                return date >= thirtyDaysAgo && date <= today
            case .last90Days:
                guard let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: today)
                else { return false }
                return date >= ninetyDaysAgo && date <= today
            case .thisYear:
                var components = calendar.dateComponents([.year], from: today)
                guard let startOfYear = calendar.date(from: components) else { return false }
                return date >= startOfYear && date <= today
            case .lastYear:
                var componentsThisYear = calendar.dateComponents([.year], from: today)
                guard let startOfThisYear = calendar.date(from: componentsThisYear),
                    let startOfLastYear = calendar.date(
                        byAdding: .year, value: -1, to: startOfThisYear),
                    let endOfLastYear = calendar.date(
                        byAdding: .day, value: -1, to: startOfThisYear)
                else { return false }
                return date >= startOfLastYear && date <= endOfLastYear
            case .allTime:
                return true
            }
        }

        private func getIncomeTotal() -> Double {
            self.filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        }

        private func getExpensesTotal() -> Double {
            self.filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        }

        private func getNetCashFlow() -> Double {
            self.getIncomeTotal() - self.getExpensesTotal()
        }

        // MARK: - Action Methods

        private func saveChanges() {
            guard let account, let editData = editedAccount else {
                self.isEditing = false
                return
            }

            // Update account with edited values
            account.name = editData.name
            account.type = editData.type
            account.balance = editData.balance
            account.currencyCode = editData.currencyCode
            account.institution = editData.institution
            account.accountNumber = editData.accountNumber
            account.interestRate = editData.interestRate
            account.creditLimit = editData.creditLimit
            account.dueDate = editData.dueDate
            account.includeInTotal = editData.includeInTotal
            account.isActive = editData.isActive
            account.notes = editData.notes

            // Save changes to the model context
            try? self.modelContext.save()

            self.isEditing = false
        }

        private func deleteAccount() {
            guard let account else { return }

            // First delete all associated transactions
            for transaction in self.filteredTransactions {
                self.modelContext.delete(transaction)
            }

            // Then delete the account
            self.modelContext.delete(account)
            try? self.modelContext.save()

            // Navigate back would happen here
        }

        private func addTransaction() {
            guard let account else { return }

            // Create a new transaction
            let transaction = FinancialTransaction(
                title: "New Transaction",
                amount: 0,
                date: Date(),
                transactionType: .expense,
                notes: ""
            )

            // Set the account relationship
            transaction.account = account

            // Add transaction to the model context
            self.modelContext.insert(transaction)
            try? self.modelContext.save()

            // Ideally navigate to this transaction for editing
        }

        private func toggleTransactionStatus(_ transaction: FinancialTransaction) {
            transaction.isReconciled.toggle()
            try? self.modelContext.save()
        }

        private func deleteTransaction(_ transaction: FinancialTransaction) {
            self.modelContext.delete(transaction)
            try? self.modelContext.save()
        }

        private func printAccountSummary() {
            // Implementation for printing
        }

        // MARK: - Validation Methods

        private func validateAccountName(_ name: String) {
            do {
                try InputValidator.validateTextInput(name, maxLength: 100)
                self.validationErrors.removeValue(forKey: "name")
            } catch {
                self.validationErrors["name"] = error.localizedDescription
            }
        }

        private func validateInstitution(_ institution: String) {
            do {
                try InputValidator.validateTextInput(institution, maxLength: 100)
                self.validationErrors.removeValue(forKey: "institution")
            } catch {
                self.validationErrors["institution"] = error.localizedDescription
            }
        }

        private func validateAccountNumber(_ number: String) {
            do {
                try InputValidator.validateTextInput(number, maxLength: 50)
                self.validationErrors.removeValue(forKey: "accountNumber")
            } catch {
                self.validationErrors["accountNumber"] = error.localizedDescription
            }
        }

        private func validateNotes(_ notes: String) {
            do {
                try InputValidator.validateTextInput(notes, maxLength: 1000)
                self.validationErrors.removeValue(forKey: "notes")
            } catch {
                self.validationErrors["notes"] = error.localizedDescription
            }
        }

        private func isValidForm() -> Bool {
            self.validationErrors.isEmpty
        }
    }

    // Extension to add ordinal suffix to numbers
    extension Int {
        var ordinal: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }
#endif
