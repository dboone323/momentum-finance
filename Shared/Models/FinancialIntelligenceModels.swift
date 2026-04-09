import Foundation
import MomentumFinanceCore
import SwiftUI

// MARK: - Financial Intelligence Types

/// Represents the type of financial insight
public enum SimpleInsightType: Sendable {
    case spendingPattern, anomaly, budgetAlert, forecast, optimization, budgetRecommendation,
         positiveSpendingTrend

    public var displayName: String {
        switch self {
        case .spendingPattern: "Spending Pattern"
        case .anomaly: "Anomaly"
        case .budgetAlert: "Budget Alert"
        case .forecast: "Forecast"
        case .optimization: "Optimization"
        case .budgetRecommendation: "Budget Recommendation"
        case .positiveSpendingTrend: "Positive Spending Trend"
        }
    }

    public var icon: String {
        switch self {
        case .spendingPattern: "chart.line.uptrend.xyaxis"
        case .anomaly: "exclamationmark.triangle"
        case .budgetAlert: "bell"
        case .forecast: "chart.xyaxis.line"
        case .optimization: "arrow.up.right.circle"
        case .budgetRecommendation: "lightbulb"
        case .positiveSpendingTrend: "arrow.down.circle"
        }
    }
}

/// Represents a financial insight
public struct SimpleFinancialInsight: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let type: SimpleInsightType
    public let priority: SimpleInsightPriority
    public let confidence: Double
    public let value: Double?
    public let category: String?
    public let dateGenerated: Date
    public let actionable: Bool

    public init(
        title: String,
        description: String,
        type: SimpleInsightType,
        priority: SimpleInsightPriority,
        confidence: Double = 0.8,
        value: Double? = nil,
        category: String? = nil,
        dateGenerated: Date = Date(),
        actionable: Bool = false
    ) {
        self.title = title
        self.description = description
        self.type = type
        self.priority = priority
        self.confidence = confidence
        self.value = value
        self.category = category
        self.dateGenerated = dateGenerated
        self.actionable = actionable
    }
}

/// Priority levels for insights
public enum SimpleInsightPriority: Int, CaseIterable, Sendable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3

    public static func < (lhs: SimpleInsightPriority, rhs: SimpleInsightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var color: Color {
        switch self {
        case .low: .gray
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }
}

/// Represents forecast data
public struct ForecastData: Identifiable, Sendable {
    public let id = UUID()
    public let date: Date
    public let predictedBalance: Double
    public let confidence: Double

    public init(date: Date, predictedBalance: Double, confidence: Double) {
        self.date = date
        self.predictedBalance = predictedBalance
        self.confidence = confidence
    }
}

/// Represents an investment recommendation
public struct InvestmentRecommendation: Identifiable, Sendable {
    public let id = UUID()
    public let assetName: String
    public let action: String
    public let reasoning: String
    public let riskLevel: String

    public init(assetName: String, action: String, reasoning: String, riskLevel: String) {
        self.assetName = assetName
        self.action = action
        self.reasoning = reasoning
        self.riskLevel = riskLevel
    }
}

/// Represents a cash flow prediction
public struct CashFlowPrediction: Identifiable, Sendable {
    public let id = UUID()
    public let month: Date
    public let predictedIncome: Double
    public let predictedExpenses: Double

    public init(month: Date, predictedIncome: Double, predictedExpenses: Double) {
        self.month = month
        self.predictedIncome = predictedIncome
        self.predictedExpenses = predictedExpenses
    }
}

/// Represents a data point for charts
/// Represents a data point for charts
public struct ChartDataPoint: Identifiable, Sendable, Codable {
    public let id: UUID
    public let label: String
    public let value: Double
    public let colorHex: String?

    public var color: Color? {
        guard colorHex != nil else { return nil }
        // Simplified stub: return .blue if hex not empty.
        // In real app, parse hex.
        return .blue
    }

    public init(label: String, value: Double, color: Color? = nil) {
        self.id = UUID()
        self.label = label
        self.value = value
        // Convert color to hex not implemented in this stub, identifying by nil for now
        self.colorHex = nil
    }
}
