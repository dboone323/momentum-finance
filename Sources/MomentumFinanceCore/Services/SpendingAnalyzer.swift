//
// SpendingAnalyzer.swift
// MomentumFinance
//
// Service for analyzing spending habits
//

import Foundation

public struct CategorySpending: Sendable {
    public let categoryId: UUID
    public let totalAmount: Decimal
    public let percentage: Double
}

@MainActor
class SpendingAnalyzer {
    @MainActor static let shared = SpendingAnalyzer()

    func analyzeSpendingByCategory(transactions: [CoreTransaction]) -> [CategorySpending] {
        let totalSpending = transactions.reduce(0) { $0 + $1.amount }
        guard totalSpending > 0 else { return [] }

        let grouped = Dictionary(grouping: transactions, by: { $0.categoryId ?? UUID() })

        return grouped.map { categoryId, txs in
            let categoryTotal = txs.reduce(0) { $0 + $1.amount }
            let percentage =
                (Double(truncating: categoryTotal as NSNumber)
                        / Double(truncating: totalSpending as NSNumber)) * 100
            return CategorySpending(
                categoryId: categoryId, totalAmount: categoryTotal, percentage: percentage
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }

    /// Calculates the average monthly spending (burn rate) based on recent transactions
    /// - Parameter transactions: Array of transactions to analyze
    /// - Returns: Average monthly spending as a Decimal
    func calculateMonthlyBurnRate(transactions: [CoreTransaction]) -> Decimal {
        let calendar = Calendar.current
        let now = Date()

        // Get transactions from the last 3 months
        guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
            return 0
        }

        let recentTransactions = transactions.filter { $0.date >= threeMonthsAgo && $0.date <= now }
        guard !recentTransactions.isEmpty else { return 0 }

        // Calculate total expenses (negative transactions)
        let totalExpenses =
            recentTransactions
                .filter { $0.amount < 0 }
                .reduce(Decimal(0)) { $0 + abs($1.amount) }

        // Calculate number of months in the range
        let components = calendar.dateComponents([.month], from: threeMonthsAgo, to: now)
        let monthCount = max(1, components.month ?? 1)

        return totalExpenses / Decimal(monthCount)
    }

    /// Calculates the saving rate as a percentage of income
    /// - Parameters:
    ///   - income: Total income amount
    ///   - expenses: Total expenses amount
    /// - Returns: Saving rate as a percentage (0-100)
    func calculateSavingRate(income: Decimal, expenses: Decimal) -> Double {
        guard income > 0 else { return 0 }

        let savings = income - expenses
        let savingRate =
            (Double(truncating: savings as NSDecimalNumber)
                    / Double(truncating: income as NSDecimalNumber)) * 100

        return max(0, min(100, savingRate)) // Clamp between 0 and 100
    }

    /// Detects spending anomalies based on statistical analysis
    /// - Parameters:
    ///   - transactions: Array of transactions to analyze
    ///   - thresholdMultiplier: Number of standard deviations to consider anomalous (default: 2.0)
    /// - Returns: Array of transactions that are considered anomalies
    func detectSpendingAnomalies(
        transactions: [CoreTransaction],
        thresholdMultiplier: Decimal = 2.0
    ) -> [CoreTransaction] {
        // Filter to expenses only
        let expenses = transactions.filter { $0.amount < 0 }
        guard expenses.count > 3 else { return [] } // Need at least a few transactions

        // Convert to positive amounts for analysis
        let amounts = expenses.map { abs($0.amount) }
        let doubleAmounts = amounts.map { Double(truncating: $0 as NSDecimalNumber) }

        // Calculate mean and standard deviation
        let mean = doubleAmounts.reduce(0, +) / Double(doubleAmounts.count)
        let variance =
            doubleAmounts.reduce(0) { $0 + pow($1 - mean, 2) } / Double(doubleAmounts.count)
        let stdDev = sqrt(variance)

        // Find transactions beyond the threshold
        let threshold = mean + (Double(truncating: thresholdMultiplier as NSDecimalNumber) * stdDev)

        return expenses.filter { transaction in
            let amount = Double(truncating: abs(transaction.amount) as NSDecimalNumber)
            return amount > threshold
        }
    }
}
