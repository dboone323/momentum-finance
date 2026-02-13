//
//  TransactionDetailView.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2024-12-19.
//

import MomentumFinanceCore
import SwiftData
import SwiftUI

extension Features.Transactions {
    struct TransactionDetailView: View {
        let transaction: FinancialTransaction
        @Environment(\.dismiss)
        private var dismiss

        var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    // Amount Display
                    VStack(spacing: 8) {
                        Text(
                            self.transaction.formattedAmount(
                                currency: self.transaction.account?.currency ?? "USD"
                            )
                        )
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(
                                self.transaction.transactionType == .income ? .green : .red
                            )

                        Text(self.transaction.transactionType.rawValue)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Title", value: self.transaction.title)
                        DetailRow(
                            label: "Date",
                            value: self.transaction.date.formatted(date: .abbreviated, time: .omitted)
                        )

                        if let category = transaction.category {
                            DetailRow(label: "Category", value: category)
                        }

                        if let account = transaction.account {
                            DetailRow(label: "Account", value: account.name)
                        }

                        if let notes = transaction.notes, !notes.isEmpty {
                            DetailRow(label: "Notes", value: notes)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .navigationTitle("Transaction Details")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Done")
                    }
                }
            }
        }
    }

    struct DetailRow: View {
        let label: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(self.value)
                    .font(.body)
            }
        }
    }
}
