// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import MomentumFinanceCore
import SwiftData
import SwiftUI

extension Features.Transactions {
    struct AddTransactionView: View {
        @Environment(\.dismiss)
        private var dismiss
        @Environment(\.modelContext)
        private var modelContext

        let categories: [ExpenseCategory]
        let accounts: [FinancialAccount]

        @State private var title = ""
        @State private var amount = ""
        @State private var selectedTransactionType = TransactionType.expense
        @State private var selectedCategory: ExpenseCategory?
        @State private var selectedAccount: FinancialAccount?
        @State private var date = Date()
        @State private var notes = ""

        private var isFormValid: Bool {
            !self.title.isEmpty && !self.amount.isEmpty && Double(self.amount) != nil
                && self.selectedAccount != nil
        }

        var body: some View {
            NavigationView {
                Form {
                    self.detailsSection
                    self.classificationSection
                    self.notesSection
                }
                .navigationTitle("Add Transaction")

                #if canImport(UIKit)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                #if canImport(UIKit)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Button")
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            self.saveTransaction()
                        }
                        .accessibilityLabel("Button")
                        .disabled(!self.isFormValid)
                    }
                }
                #else
                .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    self.dismiss()
                                }
                                .accessibilityLabel("Button")
                            }

                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") {
                                    self.saveTransaction()
                                }
                                .accessibilityLabel("Button")
                                .disabled(!self.isFormValid)
                            }
                        }
                #endif
            }
        }

        private var detailsSection: some View {
            Section(header: Text("Transaction Details")) {
                TextField("Title", text: self.$title)
                    .onChange(of: self.title) { _ in
                        self.handleTitleChange()
                    }

                TextField("Amount", text: self.$amount)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif

                Picker("Type", selection: self.$selectedTransactionType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                DatePicker("Date", selection: self.$date, displayedComponents: .date)
            }
        }

        private var classificationSection: some View {
            Section(header: Text("Category & Account")) {
                Picker("Category", selection: self.$selectedCategory) {
                    exportableCategoryRow(nil)
                    ForEach(self.categories, id: \.id) { category in
                        exportableCategoryRow(category)
                    }
                }

                Picker("Account", selection: self.$selectedAccount) {
                    exportableAccountRow(nil)
                    ForEach(self.accounts, id: \.id) { account in
                        exportableAccountRow(account)
                    }
                }
            }
        }

        private var notesSection: some View {
            Section(header: Text("Notes (Optional)")) {
                TextField("Add notes...", text: self.$notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }

        private func exportableCategoryRow(_ category: ExpenseCategory?) -> some View {
            Text(category?.name ?? "None").tag(category as ExpenseCategory?)
        }

        private func exportableAccountRow(_ account: FinancialAccount?) -> some View {
            Text(account?.name ?? "Select Account").tag(account as FinancialAccount?)
        }

        private func handleTitleChange() {
            let newValue = self.title
            Task {
                // Debounce
                try? await Task.sleep(nanoseconds: 600_000_000)
                guard !Task.isCancelled, newValue == self.title else { return }

                // Only auto-categorize if not already selected
                if self.selectedCategory == nil {
                    if let predicted = AICategorizationService.predictCategory(
                        for: newValue, categories: self.categories
                    ) {
                        await MainActor.run {
                            withAnimation {
                                self.selectedCategory = predicted
                            }
                        }
                    }
                }
            }
        }

        private func saveTransaction() {
            guard let amountValue = Double(amount),
                  let account = selectedAccount
            else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amountValue,
                date: date,
                transactionType: selectedTransactionType,
                notes: notes.isEmpty ? nil : self.notes
            )

            transaction.category = self.selectedCategory
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            self.modelContext.insert(transaction)

            try? self.modelContext.save()
            self.dismiss()
        }
    }
}
