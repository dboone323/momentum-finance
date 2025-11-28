import Foundation
import SwiftData
import SwiftUI
import MomentumFinanceCore

// MARK: - Core Financial Types

/// Represents a financial account
public struct SimpleFinancialAccount: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let type: AccountType
    public let balance: Double
    public let currency: String

    public init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        balance: Double = 0.0,
        currency: String = "USD"
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.currency = currency
    }

    public enum AccountType: String, Codable, Sendable {
        case checking, savings, credit, investment, loan, other
    }
}

/// Represents an expense category
public struct SimpleExpenseCategory: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let color: String
    public let icon: String

    public init(
        id: UUID = UUID(),
        name: String,
        color: String = "#007AFF",
        icon: String = "circle"
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }
}

/// Represents a financial transaction
public struct SimpleFinancialTransaction: Identifiable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let amount: Double
    public let date: Date
    public let category: SimpleExpenseCategory?
    public let account: SimpleFinancialAccount?
    public let type: TransactionType
    public let notes: String?

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        category: SimpleExpenseCategory? = nil,
        account: SimpleFinancialAccount? = nil,
        type: TransactionType = .expense,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.account = account
        self.type = type
        self.notes = notes
    }

    public enum TransactionType: String, Codable, Sendable {
        case income, expense, transfer
    }
}

/// Represents a budget
public struct SimpleBudget: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let category: SimpleExpenseCategory
    public let limit: Double
    public let spent: Double
    public let period: BudgetPeriod

    public init(
        id: UUID = UUID(),
        name: String,
        category: SimpleExpenseCategory,
        limit: Double,
        spent: Double = 0.0,
        period: BudgetPeriod = .monthly
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.limit = limit
        self.spent = spent
        self.period = period
    }

    public enum BudgetPeriod: String, Codable, Sendable {
        case weekly, monthly, yearly
    }
}
