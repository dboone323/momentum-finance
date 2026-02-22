// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import MomentumFinanceCore
import Observation
import SwiftData
import SwiftUI

extension Features.Transactions {
    @MainActor
    @Observable
    final class TransactionsViewModel {
        private var modelContext: ModelContext?

        /// <#Description#>
        /// - Returns: <#description#>
        func setModelContext(_ context: ModelContext) {
            self.modelContext = context
        }

        /// Filter transactions by type
        /// <#Description#>
        /// - Returns: <#description#>
        func filterTransactions(_ transactions: [FinancialTransaction], by type: TransactionType?)
            -> [FinancialTransaction]
        {
            guard let type else { return transactions }
            return transactions.filter { $0.transactionType == type }
        }

        /// Search transactions by title or category
        func searchTransactions(_ transactions: [FinancialTransaction], query: String)
            -> [FinancialTransaction]
        {
            guard !query.isEmpty else { return transactions }

            return transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(query)
                    || transaction.category?.localizedCaseInsensitiveContains(query) == true
                    || transaction.notes?.localizedCaseInsensitiveContains(query) == true
            }
        }

        func groupTransactionsByMonth(_ transactions: [FinancialTransaction]) -> [String:
            [FinancialTransaction]]
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"

            return Dictionary(grouping: transactions) { transaction in
                formatter.string(from: transaction.date)
            }
        }

        func totalIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Decimal
        {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
                    transactions.filter { transaction in
                        period.contains(transaction.date)
                    }
                } else {
                    transactions
                }

            return
                filteredTransactions
                .filter { $0.transactionType == .income }
                .reduce(Decimal(0)) { $0 + $1.amount }
        }

        func totalExpenses(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Decimal
        {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
                    transactions.filter { transaction in
                        period.contains(transaction.date)
                    }
                } else {
                    transactions
                }

            return
                filteredTransactions
                .filter { $0.transactionType == .expense }
                .reduce(Decimal(0)) { $0 + $1.amount }
        }

        func netIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Decimal
        {
            self.totalIncome(transactions, for: period)
                - self.totalExpenses(transactions, for: period)
        }

        func currentMonthTransactions(_ transactions: [FinancialTransaction])
            -> [FinancialTransaction]
        {
            let calendar = Calendar.current
            let now = Date()

            return transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
        }

        func recentTransactions(_ transactions: [FinancialTransaction], limit: Int = 10)
            -> [FinancialTransaction]
        {
            Array(
                transactions
                    .sorted { $0.date > $1.date }
                    .prefix(limit)
            )
        }

        func deleteTransaction(_ transaction: FinancialTransaction) {
            guard let modelContext else { return }

            if let account = transaction.account {
                switch transaction.transactionType {
                case .income:
                    account.balance -= transaction.amount
                case .expense:
                    account.balance += transaction.amount
                case .transfer:
                    break
                }
            }

            modelContext.delete(transaction)

            do {
                try modelContext.save()
            } catch {
                Logger.logError(error, context: "Deleting transaction")
            }
        }

        func createTransaction(
            title: String,
            amount: Decimal,
            type: TransactionType,
            category: ExpenseCategory?,
            account: FinancialAccount,
            date: Date = Date(),
            notes: String? = nil
        ) {
            guard let modelContext else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amount,
                date: date,
                transactionType: type,
                notes: notes
            )

            transaction.category = category?.name
            transaction.account = account

            account.updateBalance(with: transaction)

            modelContext.insert(transaction)

            do {
                try modelContext.save()
            } catch {
                Logger.logError(error, context: "Creating transaction")
            }
        }

        func spendingByCategory(
            _ transactions: [FinancialTransaction], for period: DateInterval? = nil
        ) -> [String: Decimal] {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
                    transactions.filter { transaction in
                        transaction.transactionType == .expense && period.contains(transaction.date)
                    }
                } else {
                    transactions.filter { $0.transactionType == .expense }
                }

            var spending: [String: Decimal] = [:]

            for transaction in filteredTransactions {
                let categoryName = transaction.category ?? "Uncategorized"
                spending[categoryName, default: Decimal(0)] += transaction.amount
            }

            return spending
        }
    }
}
