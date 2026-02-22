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
    case loan = "Loan"
    case cash = "Cash"
    case other = "Other"

    public var displayName: String {
        rawValue
    }

    public var defaultColorHex: String {
        switch self {
        case .checking: "#007AFF" // Blue
        case .savings: "#34C759" // Green
        case .credit: "#FF3B30" // Red
        case .investment: "#AF52DE" // Purple
        case .loan: "#FF9500" // Orange
        case .cash: "#FFCC00" // Yellow
        case .other: "#8E8E93" // Gray
        }
    }

    public var defaultIconName: String {
        switch self {
        case .checking: "building.columns.fill"
        case .savings: "banknote.fill"
        case .credit: "creditcard.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .loan: "dollarsign.circle.fill"
        case .cash: "banknote"
        case .other: "circle.fill"
        }
    }

    public var isAsset: Bool {
        switch self {
        case .checking, .savings, .investment, .cash:
            true
        case .credit, .loan, .other:
            false
        }
    }

    public var isLiability: Bool {
        switch self {
        case .credit, .loan:
            true
        case .checking, .savings, .investment, .cash, .other:
            false
        }
    }
}

public enum BillingCycle: String, Codable, Sendable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"

    public var displayName: String {
        self.rawValue
    }
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
