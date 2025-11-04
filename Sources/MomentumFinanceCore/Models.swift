import Foundation
import SwiftData

// MARK: - Core Domain Types

public enum TransactionType: String, Codable, Sendable {
    case income
    case expense
    case transfer
}

public enum AccountType: String, Codable, Sendable {
    case checking
    case savings
    case credit
    case investment
    case cash
}

@Model
public final class FinancialTransaction {
    public var title: String
    public var amount: Double
    public var date: Date
    public var transactionType: TransactionType
    public var notes: String?

    public var category: ExpenseCategory?
    public var account: FinancialAccount?

    public init(
        title: String,
        amount: Double,
        date: Date,
        transactionType: TransactionType,
        notes: String? = nil,
        category: ExpenseCategory? = nil,
        account: FinancialAccount? = nil
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
        self.category = category
        self.account = account
    }
}

@Model
public final class FinancialAccount {
    public var name: String
    public var balance: Double
    public var createdDate: Date
    public var accountType: AccountType
    public var currencyCode: String

    public init(
        name: String,
        balance: Double,
        createdDate: Date = Date(),
        accountType: AccountType = .checking,
        currencyCode: String = "USD"
    ) {
        self.name = name
        self.balance = balance
        self.createdDate = createdDate
        self.accountType = accountType
        self.currencyCode = currencyCode
    }
}

@Model
public final class ExpenseCategory {
    public var name: String
    public var iconName: String
    public var createdDate: Date

    public init(name: String, iconName: String = "tag") {
        self.name = name
        self.iconName = iconName
        self.createdDate = Date()
    }
}
