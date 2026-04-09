//
//  FinancialTransaction.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class FinancialTransaction {
    public var id: UUID
    public var title: String
    public var amount: Double
    public var date: Date
    public var transactionType: TransactionType
    public var category: String?
    public var notes: String?
    public var tags: [String]
    public var isRecurring: Bool
    public var recurringFrequency: RecurringFrequency?
    public var location: String?
    public var receiptImageData: Data?
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Relationships
    public var expenseCategory: ExpenseCategory?
    public var account: FinancialAccount?
    public var budget: Budget?
    public var savingsGoal: SavingsGoal?
    public var subscription: Subscription?

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        transactionType: TransactionType,
        category: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        location: String? = nil,
        receiptImageData: Data? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.category = category
        self.notes = notes
        self.tags = tags
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.location = location
        self.receiptImageData = receiptImageData
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Signed amount (negative for expenses, positive for income)
    public var signedAmount: Double {
        switch transactionType {
        case .income:
            amount
        case .expense:
            -amount
        case .transfer:
            amount // Transfers can be positive or negative based on context
        }
    }

    /// Formatted amount string with currency
    public func formattedAmount(currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(abs(amount))"
    }

    /// Month and year string for grouping
    public var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Day string for display
    public var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// Weekday string
    public var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// Time string
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    /// Check if transaction is within a date range
    public func isWithinDateRange(_ range: ClosedRange<Date>) -> Bool {
        range.contains(date)
    }

    /// Check if transaction matches a search query
    public func matchesSearch(_ query: String) -> Bool {
        let searchTerm = query.lowercased()
        return title.lowercased().contains(searchTerm) ||
            (notes?.lowercased().contains(searchTerm) ?? false) ||
            (category?.lowercased().contains(searchTerm) ?? false) ||
            tags.contains { $0.lowercased().contains(searchTerm) }
    }

    /// Create a copy with modified properties
    public func copy(
        title: String? = nil,
        amount: Double? = nil,
        date: Date? = nil,
        transactionType: TransactionType? = nil,
        category: String? = nil,
        notes: String? = nil,
        tags: [String]? = nil
    ) -> FinancialTransaction {
        FinancialTransaction(
            id: id,
            title: title ?? self.title,
            amount: amount ?? self.amount,
            date: date ?? self.date,
            transactionType: transactionType ?? self.transactionType,
            category: category ?? self.category,
            notes: notes ?? self.notes,
            tags: tags ?? self.tags,
            isRecurring: isRecurring,
            recurringFrequency: recurringFrequency,
            location: location,
            receiptImageData: receiptImageData,
            createdDate: createdDate,
            lastModifiedDate: Date()
        )
    }
}

/// Transaction types
public enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"

    public var displayName: String {
        rawValue
    }

    public var colorHex: String {
        switch self {
        case .income: "#34C759" // Green
        case .expense: "#FF3B30" // Red
        case .transfer: "#007AFF" // Blue
        }
    }

    public var iconName: String {
        switch self {
        case .income: "arrow.down.circle.fill"
        case .expense: "arrow.up.circle.fill"
        case .transfer: "arrow.left.arrow.right.circle.fill"
        }
    }
}

/// Recurring transaction frequencies
public enum RecurringFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case annually = "Annually"

    public var displayName: String {
        rawValue
    }

    public var days: Int {
        switch self {
        case .daily: 1
        case .weekly: 7
        case .biweekly: 14
        case .monthly: 30
        case .quarterly: 90
        case .semiAnnually: 180
        case .annually: 365
        }
    }
}

public extension FinancialTransaction {
    /// Sample data for previews and testing
    static var sampleIncome: FinancialTransaction {
        FinancialTransaction(
            title: "Salary Deposit",
            amount: 3500,
            date: Date(),
            transactionType: .income,
            category: "Salary",
            notes: "Monthly salary payment",
            tags: ["work", "salary"]
        )
    }

    static var sampleExpense: FinancialTransaction {
        FinancialTransaction(
            title: "Grocery Shopping",
            amount: 85.50,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            transactionType: .expense,
            category: "Groceries",
            notes: "Weekly grocery shopping at Whole Foods",
            tags: ["food", "groceries"]
        )
    }

    static var sampleTransfer: FinancialTransaction {
        FinancialTransaction(
            title: "Transfer to Savings",
            amount: 500,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            transactionType: .transfer,
            category: "Savings",
            notes: "Monthly savings transfer",
            tags: ["savings", "transfer"]
        )
    }
}
