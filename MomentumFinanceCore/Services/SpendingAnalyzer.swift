//
// SpendingAnalyzer.swift
// MomentumFinance
//
// Service for analyzing spending habits
//

import Foundation

struct CategorySpending {
    let categoryId: UUID
    let totalAmount: Decimal
    let percentage: Double
}

class SpendingAnalyzer {
    static let shared = SpendingAnalyzer()
    
    func analyzeSpendingByCategory(transactions: [Transaction]) -> [CategorySpending] {
        let totalSpending = transactions.reduce(0) { $0 + $1.amount }
        guard totalSpending > 0 else { return [] }
        
        let grouped = Dictionary(grouping: transactions, by: { $0.categoryId })
        
        return grouped.map { categoryId, txs in
            let categoryTotal = txs.reduce(0) { $0 + $1.amount }
            let percentage = (Double(truncating: categoryTotal as NSNumber) / Double(truncating: totalSpending as NSNumber)) * 100
            return CategorySpending(categoryId: categoryId, totalAmount: categoryTotal, percentage: percentage)
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    func calculateMonthlyBurnRate(transactions: [Transaction]) -> Decimal {
        // Simple average of last 3 months
        return 0.0 // Placeholder logic
    }
}
