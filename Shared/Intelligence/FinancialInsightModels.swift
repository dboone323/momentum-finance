import Foundation
import MomentumFinanceCore
import SwiftUI

// FinancialInsightType is used by FinancialInsight (class)

public enum FinancialInsightType: String, CaseIterable, Identifiable, Hashable, Sendable {
    case spendingPattern, anomaly, budget, forecast, optimization, cashManagement,
        creditUtilization, duplicatePayment
    public var id: String { rawValue }
    public var icon: String {
        switch self {
        case .spendingPattern: "chart.pie.fill"
        case .anomaly: "exclamationmark.triangle.fill"
        case .budget: "chart.bar.fill"
        case .forecast: "chart.line.uptrend.xyaxis"
        case .optimization: "lightbulb.fill"
        case .cashManagement: "banknote"
        case .creditUtilization: "creditcard.fill"
        case .duplicatePayment: "repeat"
        }
    }
}

// FinancialInsightPriority might be duplicated if in Root models.
// Need to check Root first.
