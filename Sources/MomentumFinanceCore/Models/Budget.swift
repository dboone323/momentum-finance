import Foundation

#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @Model
#endif
public final class Budget: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, budgetDescription, totalAmount, spentAmount, period, startDate, endDate,
             isActive, createdDate, lastModifiedDate, rolloverEnabled, maxRolloverPercentage,
             rolledOverAmount, currencyCode
    }

    public var id: UUID
    public var name: String
    public var budgetDescription: String?
    public var totalAmount: Decimal
    public var spentAmount: Decimal
    public var period: BudgetPeriod
    public var startDate: Date
    public var endDate: Date
    public var isActive: Bool
    public var category: ExpenseCategory?
    public var colorHex: String?
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Rollover properties
    public var rolloverEnabled: Bool = false
    public var maxRolloverPercentage: Double = 0.0
    public var rolledOverAmount: Decimal = 0.0
    public var currencyCode: String = "USD"

    #if canImport(SwiftData)
        @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.budget)
        public var transactions: [FinancialTransaction] = []
    #endif

    public init(
        id: UUID = UUID(),
        name: String,
        budgetDescription: String? = nil,
        totalAmount: Decimal,
        spentAmount: Decimal = 0,
        period: BudgetPeriod = .monthly,
        startDate: Date,
        endDate: Date,
        isActive: Bool = true,
        category: ExpenseCategory? = nil,
        colorHex: String? = nil,
        currencyCode: String = "USD",
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.budgetDescription = budgetDescription
        self.totalAmount = totalAmount
        self.spentAmount = spentAmount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.category = category
        self.colorHex = colorHex
        self.currencyCode = currencyCode
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Convenience for UI compatibility
    public var limitAmount: Decimal {
        get { totalAmount }
        set { 
            totalAmount = newValue
            lastModifiedDate = Date()
        }
    }

    public var month: Date {
        get { startDate }
        set { 
            startDate = newValue 
            lastModifiedDate = Date()
        }
    }

    public var effectiveLimit: Decimal {
        totalAmount + rolledOverAmount
    }

    public var isOverBudget: Bool {
        spentAmount > effectiveLimit
    }

    public var progress: Double {
        guard effectiveLimit > 0 else { return 0.0 }
        let total = NSDecimalNumber(decimal: effectiveLimit).doubleValue
        let spent = NSDecimalNumber(decimal: spentAmount).doubleValue
        return min(1.0, spent / total)
    }

    public var utilizationPercentage: Double {
        progress * 100
    }

    public var remainingAmount: Decimal {
        max(0, effectiveLimit - spentAmount)
    }

    public var isNearLimit: Bool {
        let threshold = effectiveLimit * Decimal(0.9)
        return spentAmount >= threshold && spentAmount <= effectiveLimit
    }

    public var dailySpendingRate: Decimal {
        let daysRem = daysRemaining
        guard daysRem > 0 else { return remainingAmount }
        return remainingAmount / Decimal(daysRem)
    }

    public var daysRemaining: Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0, 0)
    }

    public var isExpired: Bool {
        Date() > endDate
    }

    public func addTransaction(amount: Decimal) {
        spentAmount += amount
        lastModifiedDate = Date()
    }

    public func removeTransaction(amount: Decimal) {
        spentAmount = max(spentAmount - amount, 0)
        lastModifiedDate = Date()
    }

    public func resetForNewPeriod(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        spentAmount = 0
        lastModifiedDate = Date()
    }

    public func calculateRolloverAmount() -> Decimal {
        guard rolloverEnabled else { return 0.0 }
        let remaining = effectiveLimit - spentAmount
        let maxRollover = totalAmount * Decimal(maxRolloverPercentage)
        return min(max(0, remaining), maxRollover)
    }

    public func createNextPeriodBudget(for date: Date) -> Budget {
        let rolledAmount = calculateRolloverAmount()
        let nextPeriod = period.nextPeriod(from: date)
        
        let nextBudget = Budget(
            name: self.name,
            budgetDescription: self.budgetDescription,
            totalAmount: self.totalAmount,
            period: self.period,
            startDate: nextPeriod.start,
            endDate: nextPeriod.end,
            isActive: self.isActive,
            category: self.category,
            colorHex: self.colorHex,
            currencyCode: self.currencyCode
        )
        
        // Copy rollover settings
        nextBudget.rolloverEnabled = self.rolloverEnabled
        nextBudget.maxRolloverPercentage = self.maxRolloverPercentage
        nextBudget.rolledOverAmount = rolledAmount
        
        return nextBudget
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(budgetDescription, forKey: .budgetDescription)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(spentAmount, forKey: .spentAmount)
        try container.encode(period, forKey: .period)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
        try container.encode(rolloverEnabled, forKey: .rolloverEnabled)
        try container.encode(rolledOverAmount, forKey: .rolledOverAmount)
        try container.encode(maxRolloverPercentage, forKey: .maxRolloverPercentage)
        try container.encode(currencyCode, forKey: .currencyCode)
    }
}

extension Budget {
    public static var sample: Budget {
        let start = Date()
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? start
        return Budget(
            name: "Monthly Expenses",
            budgetDescription: "General monthly spending",
            totalAmount: 2000,
            spentAmount: 1450,
            period: .monthly,
            startDate: start,
            endDate: end,
            colorHex: "#007AFF"
        )
    }

    public static var sampleOverBudget: Budget {
        let start = Date()
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? start
        return Budget(
            name: "Dining Out",
            budgetDescription: "Restaurant budget",
            totalAmount: 400,
            spentAmount: 520,
            period: .monthly,
            startDate: start,
            endDate: end,
            colorHex: "#FF3B30"
        )
    }
}

