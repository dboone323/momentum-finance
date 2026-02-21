import Foundation
#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @Model
#endif
public final class SavingsGoal: Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, targetAmount, currentAmount, targetDate, createdDate, currencyCode
    }

    public var id: UUID
    public var name: String
    public var targetAmount: Decimal
    public var currentAmount: Decimal
    public var targetDate: Date
    public var createdDate: Date
    public var notes: String? = ""
    public var currencyCode: String = "USD"

    public init(
        name: String, targetAmount: Decimal, currentAmount: Decimal = 0, targetDate: Date,
        notes: String? = "",
        currencyCode: String = "USD"
    ) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.createdDate = Date()
        self.notes = notes
        self.currencyCode = currencyCode
    }

    public var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    public var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(1.0, Double(truncating: (currentAmount / targetAmount) as NSDecimalNumber))
    }

    public func addFunds(_ amount: Decimal) {
        currentAmount += amount
    }

    public var formattedCurrentAmount: String {
        currentAmount.formatted(.currency(code: currencyCode))
    }

    public var formattedTargetAmount: String {
        targetAmount.formatted(.currency(code: currencyCode))
    }

    public var formattedRemainingAmount: String {
        max(0, targetAmount - currentAmount).formatted(.currency(code: currencyCode))
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
        try container.encode(currencyCode, forKey: .currencyCode)
    }
}
