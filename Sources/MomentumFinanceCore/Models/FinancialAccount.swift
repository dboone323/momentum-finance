import Foundation
#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @Model
#endif
public final class FinancialAccount: Hashable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name, balance, iconName, createdDate, accountType, currencyCode, creditLimit
    }

    public var name: String
    public var balance: Decimal
    public var iconName: String
    public var createdDate: Date
    public var accountType: AccountType
    public var currencyCode: String
    public var creditLimit: Decimal?

    #if canImport(SwiftData)
        @Relationship(deleteRule: .cascade)
    #endif
    public var transactions: [FinancialTransaction] = []

    #if canImport(SwiftData)
        @Relationship(deleteRule: .cascade)
    #endif
    public var subscriptions: [Subscription] = []

    public init(
        name: String,
        balance: Decimal,
        iconName: String,
        accountType: AccountType = .checking,
        currencyCode: String = "USD",
        creditLimit: Decimal? = nil
    ) {
        self.name = name
        self.balance = balance
        self.iconName = iconName
        self.accountType = accountType
        self.currencyCode = currencyCode
        self.creditLimit = creditLimit
        self.createdDate = Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(balance, forKey: .balance)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(creditLimit, forKey: .creditLimit)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(accountType)
        hasher.combine(createdDate)
    }

    public static func == (lhs: FinancialAccount, rhs: FinancialAccount) -> Bool {
        lhs.name == rhs.name && lhs.accountType == rhs.accountType
            && lhs.createdDate == rhs.createdDate
    }

    public func updateBalance(for transaction: FinancialTransaction) {
        if transaction.transactionType == .income {
            self.balance += transaction.amount
        } else if transaction.transactionType == .expense {
            self.balance -= transaction.amount
        }
    }
}
