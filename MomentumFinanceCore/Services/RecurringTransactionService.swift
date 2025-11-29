//
// RecurringTransactionService.swift
// MomentumFinance
//
// Service for handling recurring transactions
//

import Foundation

enum RecurrenceInterval: String, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case quarterly
    case yearly
}

struct RecurringTransaction: Identifiable, Codable {
    let id: UUID
    let name: String
    let amount: Decimal
    let categoryId: UUID
    let accountId: UUID
    let interval: RecurrenceInterval
    let startDate: Date
    var nextDueDate: Date
    var isActive: Bool
}

class RecurringTransactionService {
    static let shared = RecurringTransactionService()
    
    func processRecurringTransactions(transactions: [RecurringTransaction]) -> [Transaction] {
        var newTransactions: [Transaction] = []
        let today = Date()
        
        for var recurring in transactions where recurring.isActive {
            if recurring.nextDueDate <= today {
                // Generate transaction
                let transaction = Transaction(
                    amount: recurring.amount,
                    date: recurring.nextDueDate,
                    note: recurring.name,
                    categoryId: recurring.categoryId,
                    accountId: recurring.accountId
                )
                newTransactions.append(transaction)
                
                // Update next due date
                recurring.nextDueDate = calculateNextDate(from: recurring.nextDueDate, interval: recurring.interval)
            }
        }
        
        return newTransactions
    }
    
    private func calculateNextDate(from date: Date, interval: RecurrenceInterval) -> Date {
        let calendar = Calendar.current
        switch interval {
        case .daily: return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly: return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly: return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly: return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly: return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .yearly: return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

// Placeholder Transaction struct if not already defined
struct Transaction: Identifiable {
    let id = UUID()
    let amount: Decimal
    let date: Date
    let note: String
    let categoryId: UUID
    let accountId: UUID
}
