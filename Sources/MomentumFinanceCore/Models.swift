import Foundation
import SwiftData

// MARK: - Core Domain Types

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

// MARK: - Models

@Model
public final class FinancialTransaction: Encodable {
    enum CodingKeys: String, CodingKey {
        case title, amount, date, transactionType, notes, isReconciled, isRecurring, location,
            subcategory, category, account
    }

    public var title: String
    public var amount: Double
    public var date: Date
    public var transactionType: TransactionType
    public var notes: String?
    public var isReconciled: Bool = false
    public var isRecurring: Bool = false
    public var location: String?
    public var subcategory: String?

    public var category: ExpenseCategory?
    public var account: FinancialAccount?

    public init(
        title: String,
        amount: Double,
        date: Date,
        transactionType: TransactionType,
        notes: String? = nil,
        isReconciled: Bool = false,
        isRecurring: Bool = false,
        location: String? = nil,
        subcategory: String? = nil,
        category: ExpenseCategory? = nil,
        account: FinancialAccount? = nil
    ) {

        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
        self.isReconciled = isReconciled
        self.isRecurring = isRecurring
        self.location = location
        self.subcategory = subcategory
        self.category = category
        self.account = account
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(transactionType, forKey: .transactionType)
        try container.encode(notes, forKey: .notes)
        try container.encode(isReconciled, forKey: .isReconciled)
        try container.encode(isRecurring, forKey: .isRecurring)
        try container.encode(location, forKey: .location)
        try container.encode(subcategory, forKey: .subcategory)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(account, forKey: .account)
    }

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let sign = transactionType == .income ? "+" : "-"
        let formattedValue = formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
        return "\(sign)\(formattedValue)"
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

@Model
public final class FinancialAccount: Hashable, Encodable {
    enum CodingKeys: String, CodingKey {
        case name, balance, iconName, createdDate, accountType, currencyCode, creditLimit
    }

    public var name: String
    public var balance: Double
    public var iconName: String
    public var createdDate: Date
    public var accountType: AccountType
    public var currencyCode: String
    public var creditLimit: Double?

    @Relationship(deleteRule: .cascade)
    public var transactions: [FinancialTransaction] = []

    @Relationship(deleteRule: .cascade)
    public var subscriptions: [Subscription] = []

    public init(
        name: String,
        balance: Double,
        iconName: String,
        accountType: AccountType = .checking,
        currencyCode: String = "USD",
        creditLimit: Double? = nil
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

@Model
public final class ExpenseCategory: Hashable, Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, createdDate
    }

    public var id: UUID
    public var name: String
    public var iconName: String
    public var createdDate: Date

    @Relationship(deleteRule: .cascade, inverse: \FinancialTransaction.category)
    public var transactions: [FinancialTransaction] = []

    public init(name: String, iconName: String = "tag") {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.createdDate = Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(createdDate, forKey: .createdDate)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }

    public func totalSpent(for month: Date) -> Double {
        let calendar = Calendar.current
        let monthComponents = calendar.dateInterval(of: .month, for: month)
        guard let startOfMonth = monthComponents?.start, let endOfMonth = monthComponents?.end
        else { return 0.0 }
        return
            transactions
            .filter { $0.transactionType == .expense }
            .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
}

@Model
public final class Budget: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, limitAmount, month, createdDate, rolloverEnabled, rolledOverAmount,
            maxRolloverPercentage
    }

    public var id: UUID
    public var name: String
    public var limitAmount: Double
    public var spentAmount: Double
    public var month: Date
    public var createdDate: Date
    public var category: ExpenseCategory?

    // Rollover properties
    public var rolloverEnabled: Bool = false
    public var maxRolloverPercentage: Double = 0.0
    public var rolledOverAmount: Double = 0.0

    public init(name: String, limitAmount: Double, spentAmount: Double = 0, month: Date) {
        self.id = UUID()
        self.name = name
        self.limitAmount = limitAmount
        self.spentAmount = spentAmount
        self.month = month
        self.createdDate = Date()
    }

    public var effectiveLimit: Double {
        limitAmount + rolledOverAmount
    }

    public var isOverBudget: Bool {
        spentAmount > effectiveLimit
    }

    public var progress: Double {
        guard effectiveLimit > 0 else { return 0.0 }
        return min(1.0, spentAmount / effectiveLimit)
    }

    public var remainingAmount: Double {
        max(0, effectiveLimit - spentAmount)
    }

    public func calculateRolloverAmount() -> Double {
        guard rolloverEnabled else { return 0.0 }
        let remaining = effectiveLimit - spentAmount
        let maxRollover = limitAmount * maxRolloverPercentage
        return min(max(0, remaining), maxRollover)
    }

    public func createNextPeriodBudget(for date: Date) -> Budget {
        let rolledAmount = calculateRolloverAmount()
        let nextBudget = Budget(
            name: self.name,
            limitAmount: self.limitAmount,
            month: date
        )
        // Copy settings
        nextBudget.rolloverEnabled = self.rolloverEnabled
        nextBudget.maxRolloverPercentage = self.maxRolloverPercentage
        nextBudget.rolledOverAmount = rolledAmount
        nextBudget.category = self.category

        return nextBudget
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(limitAmount, forKey: .limitAmount)
        try container.encode(month, forKey: .month)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(rolloverEnabled, forKey: .rolloverEnabled)
        try container.encode(rolledOverAmount, forKey: .rolledOverAmount)
        try container.encode(maxRolloverPercentage, forKey: .maxRolloverPercentage)
    }
}

@Model
public final class Subscription: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, provider, amount, currencyCode, billingCycle, startDate, nextDueDate, notes,
            paymentMethod, isActive, autoRenews
    }

    public var id: UUID
    public var name: String
    public var provider: String
    public var amount: Double
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
        amount: Double,
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
        let component: Calendar.Component
        switch billingCycle {
        case .daily: component = .day
        case .weekly: component = .weekday
        case .monthly: component = .month
        case .quarterly: component = .month
        case .yearly: component = .year
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

    public var monthlyEquivalent: Double {
        switch billingCycle {
        case .daily: return amount * 30
        case .weekly: return amount * 4.33
        case .monthly: return amount
        case .quarterly: return amount / 3
        case .yearly: return amount / 12
        }
    }
}

@Model
public final class SavingsGoal: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, targetAmount, currentAmount, targetDate, createdDate
    }

    public var id: UUID
    public var name: String
    public var targetAmount: Double
    public var currentAmount: Double
    public var targetDate: Date
    public var createdDate: Date
    public var notes: String? = ""

    public init(
        name: String, targetAmount: Double, currentAmount: Double = 0, targetDate: Date,
        notes: String? = ""
    ) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.createdDate = Date()
        self.notes = notes
    }

    public var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    public var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(1.0, currentAmount / targetAmount)
    }

    public func addFunds(_ amount: Double) {
        currentAmount += amount
    }

    public var formattedCurrentAmount: String {
        currentAmount.formatted(.currency(code: "USD"))
    }

    public var formattedTargetAmount: String {
        targetAmount.formatted(.currency(code: "USD"))
    }

    public var formattedRemainingAmount: String {
        max(0, targetAmount - currentAmount).formatted(.currency(code: "USD"))
    }

    public var daysRemaining: Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(targetAmount, forKey: .targetAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encode(targetDate, forKey: .targetDate)
        try container.encode(createdDate, forKey: .createdDate)
    }
}
