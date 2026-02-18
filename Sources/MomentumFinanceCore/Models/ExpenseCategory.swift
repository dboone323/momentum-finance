import Foundation
import SwiftData

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

    public func totalSpent(for month: Date) -> Decimal {
        let calendar = Calendar.current
        let monthComponents = calendar.dateInterval(of: .month, for: month)
        guard let startOfMonth = monthComponents?.start, let endOfMonth = monthComponents?.end
        else { return 0 }
        return
            transactions
                .filter { $0.transactionType == .expense }
                .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
                .reduce(0) { $0 + $1.amount }
    }
}
