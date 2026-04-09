import Foundation
#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @Model
#endif
public final class FinancialAccount: Hashable, Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, balance, iconName, createdDate, lastModifiedDate, accountType, currencyCode,
             institutionName, accountNumber, isActive, colorHex, creditLimit
    }

    public var id: UUID
    public var name: String
    public var balance: Decimal
    public var iconName: String
    public var accountType: AccountType
    public var currencyCode: String
    public var institutionName: String?
    public var accountNumber: String?
    public var isActive: Bool = true
    public var colorHex: String?
    public var creditLimit: Decimal?
    public var createdDate: Date
    public var lastModifiedDate: Date

    #if canImport(SwiftData)
        @Relationship(deleteRule: .cascade, inverse: \FinancialTransaction.account)
        public var transactions: [FinancialTransaction] = []

        @Relationship(deleteRule: .cascade, inverse: \Subscription.account)
        public var subscriptions: [Subscription] = []
    #else
        public var transactions: [FinancialTransaction] = []
        public var subscriptions: [Subscription] = []
    #endif

    public init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal = 0,
        iconName: String = "building.columns.fill",
        accountType: AccountType = .checking,
        currencyCode: String = "USD",
        institutionName: String? = nil,
        accountNumber: String? = nil,
        isActive: Bool = true,
        colorHex: String? = nil,
        creditLimit: Decimal? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.iconName = iconName
        self.accountType = accountType
        self.currencyCode = currencyCode
        self.institutionName = institutionName
        self.accountNumber = accountNumber
        self.isActive = isActive
        self.colorHex = colorHex
        self.creditLimit = creditLimit
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(balance, forKey: .balance)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(institutionName, forKey: .institutionName)
        try container.encodeIfPresent(accountNumber, forKey: .accountNumber)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(colorHex, forKey: .colorHex)
        try container.encodeIfPresent(creditLimit, forKey: .creditLimit)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: FinancialAccount, rhs: FinancialAccount) -> Bool {
        lhs.id == rhs.id
    }

    /// Helpers
    public var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: balance as NSDecimalNumber) ?? "$\(balance)"
    }

    public var isOverdrawn: Bool {
        balance < 0
    }

    public var maskedAccountNumber: String? {
        guard let accountNumber, accountNumber.count >= 4 else { return nil }
        let lastFour = String(accountNumber.suffix(4))
        return "****\(lastFour)"
    }

    public func updateBalance(with transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        case .transfer:
            // Transfers handled by higher-level service logic
            break
        }
        lastModifiedDate = Date()
    }

    /// Legacy support
    public func updateBalance(for transaction: FinancialTransaction) {
        updateBalance(with: transaction)
    }
}

extension FinancialAccount {
    public static var sampleChecking: FinancialAccount {
        FinancialAccount(
            name: "Main Checking",
            balance: 5420.50,
            accountType: .checking,
            institutionName: "Chase Bank",
            accountNumber: "1234567890",
            colorHex: "#007AFF"
        )
    }

    static var sampleSavings: FinancialAccount {
        FinancialAccount(
            name: "Emergency Fund",
            balance: 15000.00,
            accountType: .savings,
            institutionName: "Chase Bank",
            accountNumber: "0987654321",
            colorHex: "#34C759"
        )
    }
}

