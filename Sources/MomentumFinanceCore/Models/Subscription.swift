import Foundation
import SwiftData

@Model
public final class Subscription: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, provider, amount, currencyCode, billingCycle, startDate, nextDueDate, notes,
             paymentMethod, isActive, autoRenews
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
    public var category: ExpenseCategory?

    public var account: FinancialAccount?

    public init(
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
        autoRenews: Bool = true
    ) {
        self.id = UUID()
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
    }

    public func processPayment(modelContext: ModelContext) {
        let transaction = FinancialTransaction(
            title: "Subscription: \(name)",
            amount: amount,
            date: Date(),
            transactionType: .expense,
            notes: "Automatic payment for \(name)"
        )
        transaction.account = account
        transaction.category = category
        modelContext.insert(transaction)

        // Update next due date
        let calendar = Calendar.current
        let component: Calendar.Component =
            switch billingCycle {
            case .daily: .day
            case .weekly: .weekday
            case .monthly: .month
            case .quarterly: .month
            case .yearly: .year
            }

        let value = billingCycle == .quarterly ? 3 : 1
        self.nextDueDate =
            calendar.date(byAdding: component, value: value, to: nextDueDate) ?? nextDueDate
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
        try container.encode(notes, forKey: .notes)
        try container.encode(paymentMethod, forKey: .paymentMethod)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(autoRenews, forKey: .autoRenews)
    }

    public var monthlyEquivalent: Decimal {
        switch billingCycle {
        case .daily: amount * 30
        case .weekly: amount * Decimal(4.33)
        case .monthly: amount
        case .quarterly: amount / 3
        case .yearly: amount / 12
        }
    }
}
