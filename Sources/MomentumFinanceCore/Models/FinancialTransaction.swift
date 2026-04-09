import Foundation
#if canImport(SwiftData)
    import SwiftData
#endif

/// Recurring transaction frequencies
public enum RecurringFrequency: String, Codable, CaseIterable, Sendable {
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

#if canImport(SwiftData)
    @Model
#endif
public final class FinancialTransaction: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, transactionType, notes, tags, isReconciled, isRecurring,
             recurringFrequency, location, subcategory, receiptImageData, category, account,
             currencyCode, budget, savingsGoal, subscription, createdDate, lastModifiedDate
    }

    public var id: UUID
    public var title: String
    public var amount: Decimal
    public var date: Date
    public var transactionType: TransactionType
    public var notes: String?
    public var tags: [String] = []
    public var isReconciled: Bool = false
    public var isRecurring: Bool = false
    public var recurringFrequency: RecurringFrequency?
    public var location: String?
    public var subcategory: String?
    public var receiptImageData: Data?
    public var createdDate: Date
    public var lastModifiedDate: Date

    public var category: ExpenseCategory?
    public var account: FinancialAccount?
    
    #if canImport(SwiftData)
        public var budget: Budget?
        public var savingsGoal: SavingsGoal?
        public var subscription: Subscription?
    #else
        public var budget: Budget?
        public var savingsGoal: SavingsGoal?
        public var subscription: Subscription?
    #endif

    public var currencyCode: String = "USD"

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        date: Date,
        transactionType: TransactionType,
        notes: String? = nil,
        tags: [String] = [],
        isReconciled: Bool = false,
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        location: String? = nil,
        subcategory: String? = nil,
        receiptImageData: Data? = nil,
        category: ExpenseCategory? = nil,
        account: FinancialAccount? = nil,
        currencyCode: String? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
        self.tags = tags
        self.isReconciled = isReconciled
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.location = location
        self.subcategory = subcategory
        self.receiptImageData = receiptImageData
        self.category = category
        self.account = account
        self.currencyCode = currencyCode ?? account?.currencyCode ?? "USD"
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(transactionType, forKey: .transactionType)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(tags, forKey: .tags)
        try container.encode(isReconciled, forKey: .isReconciled)
        try container.encode(isRecurring, forKey: .isRecurring)
        try container.encodeIfPresent(recurringFrequency, forKey: .recurringFrequency)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(subcategory, forKey: .subcategory)
        try container.encodeIfPresent(receiptImageData, forKey: .receiptImageData)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(account, forKey: .account)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
        
        #if canImport(SwiftData)
            try container.encodeIfPresent(budget, forKey: .budget)
            try container.encodeIfPresent(savingsGoal, forKey: .savingsGoal)
            try container.encodeIfPresent(subscription, forKey: .subscription)
        #endif
    }

    /// Signed amount (negative for expenses, positive for income)
    public var signedAmount: Decimal {
        switch transactionType {
        case .income: amount
        case .expense: -amount
        case .transfer: amount
        }
    }

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        let sign = transactionType == .income ? "+" : "-"
        let formattedValue = formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
        return "\(sign)\(formattedValue)"
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    public var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    public var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    public var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    public func isWithinDateRange(_ range: ClosedRange<Date>) -> Bool {
        range.contains(date)
    }

    public func matchesSearch(_ query: String) -> Bool {
        let searchTerm = query.lowercased()
        return title.lowercased().contains(searchTerm)
            || (notes?.lowercased().contains(searchTerm) ?? false)
            || (subcategory?.lowercased().contains(searchTerm) ?? false)
            || tags.contains { $0.lowercased().contains(searchTerm) }
    }

    public func copy(
        title: String? = nil,
        amount: Decimal? = nil,
        date: Date? = nil,
        transactionType: TransactionType? = nil,
        notes: String? = nil,
        tags: [String]? = nil
    ) -> FinancialTransaction {
        FinancialTransaction(
            id: self.id,
            title: title ?? self.title,
            amount: amount ?? self.amount,
            date: date ?? self.date,
            transactionType: transactionType ?? self.transactionType,
            notes: notes ?? self.notes,
            tags: tags ?? self.tags,
            isReconciled: self.isReconciled,
            isRecurring: self.isRecurring,
            recurringFrequency: self.recurringFrequency,
            location: self.location,
            subcategory: self.subcategory,
            receiptImageData: self.receiptImageData,
            category: self.category,
            account: self.account,
            currencyCode: self.currencyCode,
            createdDate: self.createdDate,
            lastModifiedDate: Date()
        )
    }
}

extension FinancialTransaction {
    public static var sampleIncome: FinancialTransaction {
        FinancialTransaction(
            title: "Salary Deposit",
            amount: 3500,
            date: Date(),
            transactionType: .income,
            notes: "Monthly salary",
            tags: ["work", "salary"]
        )
    }

    public static var sampleExpense: FinancialTransaction {
        FinancialTransaction(
            title: "Groceries",
            amount: 85.50,
            date: Date(),
            transactionType: .expense,
            notes: "Whole Foods",
            tags: ["food", "groceries"]
        )
    }

    public static var sampleTransfer: FinancialTransaction {
        FinancialTransaction(
            title: "Transfer to Savings",
            amount: 500,
            date: Date(),
            transactionType: .transfer,
            notes: "Monthly savings transfer",
            tags: ["savings", "transfer"]
        )
    }
}


