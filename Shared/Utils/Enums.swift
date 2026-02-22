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
        case .checking: "#007AFF"  // Blue
        case .savings: "#34C759"  // Green
        case .credit: "#FF3B30"  // Red
        case .investment: "#AF52DE"  // Purple
        case .loan: "#FF9500"  // Orange
        case .cash: "#FFCC00"  // Yellow
        case .other: "#8E8E93"  // Gray
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

public enum BudgetPeriod: String, Codable, Sendable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case annually = "Annually"
    case custom = "Custom"

    public var displayName: String {
        rawValue
    }

    public func nextPeriod(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            let start = date.startOfWeek
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
            return (start, end)
        case .monthly:
            let start = date.startOfMonth
            let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? start
            return (start, end)
        case .quarterly:
            let start = date.startOfQuarter
            let end = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: start) ?? start
            return (start, end)
        case .semiAnnually:
            let start = date.startOfSemester
            let end = calendar.date(byAdding: DateComponents(month: 6, day: -1), to: start) ?? start
            return (start, end)
        case .annually:
            let start = date.startOfYear
            let end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: start) ?? start
            return (start, end)
        case .custom:
            return (date, date)
        }
    }
}

public enum BillingCycle: String, Codable, Sendable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case yearly = "Yearly"
    case annually = "Annually"
    case custom = "Custom"

    public var displayName: String {
        rawValue
    }

    public var days: Int {
        switch self {
        case .daily: 1
        case .weekly: 7
        case .monthly: 30
        case .quarterly: 90
        case .semiAnnually: 180
        case .yearly, .annually: 365
        case .custom: 30 // Default to 30 for now
        }
    }

    public func nextDate(from date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: date)
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
