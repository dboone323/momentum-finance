//
//  TransactionRowView.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import MomentumFinanceCore
import SwiftData
import SwiftUI

public extension Features.Transactions {
    struct TransactionRowView: View {
        public let transaction: FinancialTransaction
        public let onTapped: () -> Void

        public init(transaction: FinancialTransaction, onTapped: @escaping () -> Void) {
            self.transaction = transaction
            self.onTapped = onTapped
        }

        public var body: some View {
            Button(action: self.onTapped) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.transaction.title)
                            .font(.headline)

                        if let category = transaction.category {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(
                            self.transaction.formattedAmount(
                                currency: self.transaction.account?.currency ?? "USD"
                            )
                        )
                            .font(.headline)
                            .foregroundColor(
                                self.transaction.transactionType == .income ? .green : .red
                            )

                        Text(self.transaction.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .accessibilityLabel("Transaction")
            .buttonStyle(PlainButtonStyle())
        }
    }
}
