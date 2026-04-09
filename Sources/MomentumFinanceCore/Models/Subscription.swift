import Foundation

#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @Model
#endif
public final class Subscription: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, provider, amount, currencyCode, billingCycle, startDate, nextDueDate, notes,
             paymentMethod, isActive, autoRenews, reminderDays, createdDate, lastModifiedDate
    }

    public var id: UUID
    public var name: String
    public var provider: String
    public var amount: Decimal
    public var currencyCode: String
    public var billingCycle: BillingCycle
    public var startDate: Date
    public var nextDueDate: Date
    public var notes: String?
    public var paymentMethod: String?
    public var isActive: Bool = true
    public var autoRenews: Bool = true
    public var reminderDays: Int = 3
    public var category: ExpenseCategory?
    public var createdDate: Date
    public var lastModifiedDate: Date

    #if canImport(SwiftData)
        public var account: FinancialAccount?
        @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.subscription)
        public var transactions: [FinancialTransaction] = []
    #endif

    public init(
        id: UUID = UUID(),
        name: String,
        provider: String = "",
        amount: Decimal,
        currencyCode: String = "USD",
        billingCycle: BillingCycle,
        startDate: Date = Date(),
        nextDueDate: Date,
        notes: String? = nil,
        paymentMethod: String? = nil,
        isActive: Bool = true,
        autoRenews: Bool = true,
        reminderDays: Int = 3,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.amount = amount
        self.currencyCode = currencyCode
        self.billingCycle = billingCycle
        self.startDate = startDate
        self.nextDueDate = nextDueDate
        self.notes = notes
        self.paymentMethod = paymentMethod
        self.isActive = isActive
        self.autoRenews = autoRenews
        self.reminderDays = reminderDays
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// UI Compatibility Aliases
    public var nextBillingDate: Date {
        get { nextDueDate }
        set { 
            nextDueDate = newValue 
            lastModifiedDate = Date()
        }
    }

    public var autoRenew: Bool {
        get { autoRenews }
        set { 
            autoRenews = newValue 
            lastModifiedDate = Date()
        }
    }

    public var subscriptionDescription: String? {
        get { provider.isEmpty ? notes : provider }
        set { 
            provider = newValue ?? ""
            lastModifiedDate = Date()
        }
    }

    /// Calculations
    public var monthlyCost: Decimal {
        switch billingCycle {
        case .daily: amount * 30.44
        case .weekly: amount * 4.33
        case .monthly: amount
        case .quarterly: amount / 3
        case .semiAnnually: amount / 6
        case .yearly, .annually: amount / 12
        case .custom: amount
        }
    }

    public var yearlyCost: Decimal {
        switch billingCycle {
        case .daily: amount * 365
        case .weekly: amount * 52
        case .monthly: amount * 12
        case .quarterly: amount * 4
        case .semiAnnually: amount * 2
        case .yearly, .annually: amount
        case .custom: amount * 12
        }
    }

    public var shouldRemind: Bool {
        guard isActive else { return false }
        let reminderDate = Calendar.current.date(byAdding: .day, value: -reminderDays, to: nextDueDate) ?? nextDueDate
        return Date() >= reminderDate && Date() < nextDueDate
    }

    public var daysUntilNextBilling: Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0, 0)
    }

    #if canImport(SwiftData)
        public func processPayment(modelContext: ModelContext) {
            guard isActive else { return }

            let transaction = FinancialTransaction(
                title: "Subscription: \(name)",
                amount: amount,
                date: nextDueDate,
                transactionType: .expense,
                notes: subscriptionDescription,
                category: category,
                account: account,
                currencyCode: currencyCode
            )
            transaction.subscription = self
            
            if let account {
                account.updateBalance(with: transaction)
            }
            
            modelContext.insert(transaction)

            // Update next billing date
            self.updateNextBillingDate()
        }
    #endif

    public func updateNextBillingDate() {
        if let newDate = billingCycle.nextDate(from: nextDueDate) {
            nextDueDate = newDate
            lastModifiedDate = Date()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(provider, forKey: .provider)
        try container.encode(amount, forKey: .amount)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(billingCycle, forKey: .billingCycle)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(nextDueDate, forKey: .nextDueDate)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(paymentMethod, forKey: .paymentMethod)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(autoRenews, forKey: .autoRenews)
        try container.encode(reminderDays, forKey: .reminderDays)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
    }
}

extension Subscription {
    public static var sample: Subscription {
        Subscription(
            name: "Netflix Premium",
            provider: "Streaming service",
            amount: 15.99,
            currencyCode: "USD",
            billingCycle: .monthly,
            nextDueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        )
    }

    public static var sampleAnnual: Subscription {
        Subscription(
            name: "Adobe Creative Cloud",
            provider: "Design software",
            amount: 599.99,
            currencyCode: "USD",
            billingCycle: .annually,
            nextDueDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()) ?? Date()
        )
    }
}

