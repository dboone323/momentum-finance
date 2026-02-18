import Foundation
import SwiftData

@Model
public final class Budget: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, limitAmount, month, createdDate, rolloverEnabled, rolledOverAmount,
             maxRolloverPercentage, currencyCode
    }

    public var id: UUID
    public var name: String
    public var limitAmount: Decimal
    public var spentAmount: Decimal
    public var month: Date
    public var createdDate: Date
    public var category: ExpenseCategory?

    // Rollover properties
    public var rolloverEnabled: Bool = false
    public var maxRolloverPercentage: Double = 0.0
    public var rolledOverAmount: Decimal = 0.0
    public var currencyCode: String = "USD"

    public init(
        name: String, limitAmount: Decimal, spentAmount: Decimal = 0, month: Date,
        currencyCode: String = "USD"
    ) {
        self.id = UUID()
        self.name = name
        self.limitAmount = limitAmount
        self.spentAmount = spentAmount
        self.month = month
        self.createdDate = Date()
        self.currencyCode = currencyCode
    }

    public var effectiveLimit: Decimal {
        limitAmount + rolledOverAmount
    }

    public var isOverBudget: Bool {
        spentAmount > effectiveLimit
    }

    public var progress: Double {
        guard effectiveLimit > 0 else { return 0.0 }
        return min(1.0, Double(truncating: (spentAmount / effectiveLimit) as NSDecimalNumber))
    }

    public var remainingAmount: Decimal {
        max(0, effectiveLimit - spentAmount)
    }

    public func calculateRolloverAmount() -> Decimal {
        guard rolloverEnabled else { return 0.0 }
        let remaining = effectiveLimit - spentAmount
        let maxRollover = limitAmount * Decimal(maxRolloverPercentage)
        return min(max(0, remaining), maxRollover)
    }

    public func createNextPeriodBudget(for date: Date) -> Budget {
        let rolledAmount = calculateRolloverAmount()
        let nextBudget = Budget(
            name: self.name,
            limitAmount: self.limitAmount,
            month: date,
            currencyCode: self.currencyCode
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
        try container.encode(currencyCode, forKey: .currencyCode)
    }
}
