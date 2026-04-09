import Foundation

#if canImport(SwiftData)
    import SwiftData
#endif

/// Priority levels for savings goals
public enum GoalPriority: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    public var sortOrder: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .critical: 3
        }
    }
}

#if canImport(SwiftData)
    @Model
#endif
public final class SavingsGoal: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, goalDescription, targetAmount, currentAmount, targetDate, createdDate,
             isCompleted, priority, category, currencyCode
    }

    public var id: UUID
    public var name: String
    public var goalDescription: String?
    public var targetAmount: Decimal
    public var currentAmount: Decimal
    public var targetDate: Date?
    public var createdDate: Date
    public var isCompleted: Bool = false
    public var priority: GoalPriority = GoalPriority.medium
    public var category: String?
    public var currencyCode: String = "USD"

    #if canImport(SwiftData)
        @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.savingsGoal)
        public var transactions: [FinancialTransaction] = []
    #else
        public var transactions: [FinancialTransaction] = []
    #endif

    public init(
        id: UUID = UUID(),
        name: String,
        goalDescription: String? = nil,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date? = nil,
        createdDate: Date = Date(),
        isCompleted: Bool = false,
        priority: GoalPriority = .medium,
        category: String? = nil,
        currencyCode: String = "USD"
    ) {
        self.id = id
        self.name = name
        self.goalDescription = goalDescription
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.createdDate = createdDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.currencyCode = currencyCode
    }

    /// UI Compatibility Aliases
    public var title: String {
        get { name }
        set { name = newValue }
    }

    public var notes: String? {
        get { goalDescription }
        set { goalDescription = newValue }
    }

    /// Calculations
    public var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        let total = NSDecimalNumber(decimal: targetAmount).doubleValue
        let current = NSDecimalNumber(decimal: currentAmount).doubleValue
        return min((current / total) * 100, 100)
    }

    public var remainingAmount: Decimal {
        max(targetAmount - currentAmount, 0)
    }

    public var isOnTrack: Bool {
        guard let targetDate else { return true }
        let daysRem = daysRemaining ?? 0
        guard daysRem > 0 else { return currentAmount >= targetAmount }
        let requiredDailySavings = remainingAmount / Decimal(daysRem)
        return requiredDailySavings <= 50 // Threshold heuristic
    }

    public var daysRemaining: Int? {
        guard let targetDate else { return nil }
        return max(Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0, 0)
    }

    public var formattedCurrentAmount: String {
        currentAmount.formatted(.currency(code: currencyCode))
    }

    public var formattedTargetAmount: String {
        targetAmount.formatted(.currency(code: currencyCode))
    }

    public var formattedRemainingAmount: String {
        remainingAmount.formatted(.currency(code: currencyCode))
    }

    /// Actions
    public func markCompleted() {
        isCompleted = true
        currentAmount = targetAmount
    }

    public func addAmount(_ amount: Decimal) {
        currentAmount += amount
        if currentAmount >= targetAmount {
            isCompleted = true
        }
    }

    public func addFunds(_ amount: Decimal) {
        addAmount(amount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(goalDescription, forKey: .goalDescription)
        try container.encode(targetAmount, forKey: .targetAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encodeIfPresent(targetDate, forKey: .targetDate)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(priority, forKey: .priority)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(currencyCode, forKey: .currencyCode)
    }
}

extension SavingsGoal {
    public static var sample: SavingsGoal {
        SavingsGoal(
            name: "Emergency Fund",
            goalDescription: "6 months of expenses",
            targetAmount: 15000,
            currentAmount: 8500,
            targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
            priority: .high,
            category: "Emergency"
        )
    }
}

