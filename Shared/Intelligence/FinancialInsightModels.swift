import Foundation

public struct FinancialInsight: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let title: String
    public let insightDescription: String
    public let type: FinancialInsightType

    public init(
        id: UUID = UUID(),
        title: String,
        insightDescription: String,
        type: FinancialInsightType = .general
    ) {
        self.id = id
        self.title = title
        self.insightDescription = insightDescription
        self.type = type
    }
}

public enum FinancialInsightType: String, CaseIterable, Sendable {
    case spending
    case savings
    case budget
    case subscription
    case goal
    case general

    public var icon: String {
        switch self {
        case .spending: "chart.pie.fill"
        case .savings: "banknote.fill"
        case .budget: "calendar"
        case .subscription: "repeat"
        case .goal: "flag.checkered"
        case .general: "lightbulb.fill"
        }
    }
}
