import Foundation

public enum TransactionType: String, Codable, Sendable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"
}

public enum AccountType: String, Codable, Sendable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case credit = "Credit Card"
    case investment = "Investment"
    case cash = "Cash"
}

public enum BillingCycle: String, Codable, Sendable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
}

/// Lightweight struct for financial calculations using Decimal for precision
public struct CoreTransaction: Identifiable, Codable, Sendable {
    public let id: UUID
    public let amount: Decimal
    public let date: Date
    public let note: String
    public let categoryId: UUID?
    public let accountId: UUID?

    public init(
        id: UUID = UUID(), amount: Decimal, date: Date = Date(), note: String,
        categoryId: UUID? = nil, accountId: UUID? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
        self.categoryId = categoryId
        self.accountId = accountId
    }
}

/// Lightweight struct for account calculations
public struct CoreAccount: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public var balance: Decimal
    public let type: String

    public init(id: UUID = UUID(), name: String, balance: Decimal, type: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.type = type
    }
}
