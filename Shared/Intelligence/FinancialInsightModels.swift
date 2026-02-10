//
//  FinancialInsightModels.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// Financial insight types
public enum FinancialInsightType: String, Codable, CaseIterable {
    case spendingPattern = "Spending Pattern"
    case budgetAlert = "Budget Alert"
    case savingsOpportunity = "Savings Opportunity"
    case incomeOptimization = "Income Optimization"
    case expenseReduction = "Expense Reduction"
    case investmentSuggestion = "Investment Suggestion"
    case anomaly = "Anomaly"
    case trend = "Trend"
    case goalProgress = "Goal Progress"
    case subscriptionReview = "Subscription Review"

    public var displayName: String {
        rawValue
    }

    public var iconName: String {
        switch self {
        case .spendingPattern: return "chart.bar.fill"
        case .budgetAlert: return "exclamationmark.triangle.fill"
        case .savingsOpportunity: return "dollarsign.circle.fill"
        case .incomeOptimization: return "arrow.up.circle.fill"
        case .expenseReduction: return "arrow.down.circle.fill"
        case .investmentSuggestion: return "chart.line.uptrend.xyaxis"
        case .anomaly: return "exclamationmark.circle.fill"
        case .trend: return "chart.line.uptrend.xyaxis"
        case .goalProgress: return "target"
        case .subscriptionReview: return "calendar.badge.exclamationmark"
        }
    }

    public var colorHex: String {
        switch self {
        case .spendingPattern: return "#007AFF"
        case .budgetAlert: return "#FF3B30"
        case .savingsOpportunity: return "#34C759"
        case .incomeOptimization: return "#5AC8FA"
        case .expenseReduction: return "#FF9500"
        case .investmentSuggestion: return "#AF52DE"
        case .anomaly: return "#FF2D55"
        case .trend: return "#FFCC00"
        case .goalProgress: return "#32D74B"
        case .subscriptionReview: return "#BF5AF2"
        }
    }
}

/// Priority levels for financial insights
public enum InsightPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    public var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }

    public var colorHex: String {
        switch self {
        case .low: return "#8E8E93"
        case .medium: return "#FF9500"
        case .high: return "#FF3B30"
        case .critical: return "#FF2D55"
        }
    }
}

/// Financial insight model
public struct FinancialInsight: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: FinancialInsightType
    public var title: String
    public var description: String
    public var priority: InsightPriority
    public var category: String?
    public var amount: Double?
    public var percentage: Double?
    public var dateGenerated: Date
    public var isRead: Bool
    public var actionRequired: Bool
    public var suggestedAction: String?
    public var relatedTransactionIds: [UUID]
    public var metadata: [String: String]

    public init(
        id: UUID = UUID(),
        type: FinancialInsightType,
        title: String,
        description: String,
        priority: InsightPriority = .medium,
        category: String? = nil,
        amount: Double? = nil,
        percentage: Double? = nil,
        dateGenerated: Date = Date(),
        isRead: Bool = false,
        actionRequired: Bool = false,
        suggestedAction: String? = nil,
        relatedTransactionIds: [UUID] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
        self.amount = amount
        self.percentage = percentage
        self.dateGenerated = dateGenerated
        self.isRead = isRead
        self.actionRequired = actionRequired
        self.suggestedAction = suggestedAction
        self.relatedTransactionIds = relatedTransactionIds
        self.metadata = metadata
    }

    /// Formatted amount string
    public var formattedAmount: String? {
        guard let amount = amount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount))
    }

    /// Formatted percentage string
    public var formattedPercentage: String? {
        guard let percentage = percentage else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: percentage / 100))
    }

    /// Mark as read
    public mutating func markAsRead() {
        isRead = true
    }

    /// Time ago string
    public var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: dateGenerated, relativeTo: Date())
    }
}

/// Spending pattern insight
public struct SpendingPatternInsight: Codable {
    public let category: String
    public let averageAmount: Double
    public let trend: TrendDirection
    public let changePercentage: Double
    public let period: String
    public let recommendations: [String]

    public init(
        category: String,
        averageAmount: Double,
        trend: TrendDirection,
        changePercentage: Double,
        period: String,
        recommendations: [String] = []
    ) {
        self.category = category
        self.averageAmount = averageAmount
        self.trend = trend
        self.changePercentage = changePercentage
        self.period = period
        self.recommendations = recommendations
    }
}

/// Trend direction
public enum TrendDirection: String, Codable {
    case increasing = "Increasing"
    case decreasing = "Decreasing"
    case stable = "Stable"

    public var displayName: String {
        rawValue
    }

    public var colorHex: String {
        switch self {
        case .increasing: return "#FF3B30" // Red for increasing spending
        case .decreasing: return "#34C759" // Green for decreasing spending
        case .stable: return "#FF9500" // Orange for stable
        }
    }
}

/// Budget alert insight
public struct BudgetAlertInsight: Codable {
    public let budgetName: String
    public let currentSpent: Double
    public let budgetLimit: Double
    public let percentageUsed: Double
    public let daysRemaining: Int
    public let projectedOverspend: Double?
    public let recommendations: [String]

    public init(
        budgetName: String,
        currentSpent: Double,
        budgetLimit: Double,
        percentageUsed: Double,
        daysRemaining: Int,
        projectedOverspend: Double? = nil,
        recommendations: [String] = []
    ) {
        self.budgetName = budgetName
        self.currentSpent = currentSpent
        self.budgetLimit = budgetLimit
        self.percentageUsed = percentageUsed
        self.daysRemaining = daysRemaining
        self.projectedOverspend = projectedOverspend
        self.recommendations = recommendations
    }
}

/// Savings opportunity insight
public struct SavingsOpportunityInsight: Codable {
    public let category: String
    public let potentialSavings: Double
    public let currentSpending: Double
    public let averageSavings: Double
    public let timeframe: String
    public let suggestions: [String]

    public init(
        category: String,
        potentialSavings: Double,
        currentSpending: Double,
        averageSavings: Double,
        timeframe: String,
        suggestions: [String] = []
    ) {
        self.category = category
        self.potentialSavings = potentialSavings
        self.currentSpending = currentSpending
        self.averageSavings = averageSavings
        self.timeframe = timeframe
        self.suggestions = suggestions
    }
}

/// Anomaly detection insight
public struct AnomalyInsight: Codable {
    public let transactionId: UUID
    public let transactionTitle: String
    public let amount: Double
    public let expectedRange: ClosedRange<Double>
    public let deviation: Double
    public let reason: String
    public let confidence: Double

    public init(
        transactionId: UUID,
        transactionTitle: String,
        amount: Double,
        expectedRange: ClosedRange<Double>,
        deviation: Double,
        reason: String,
        confidence: Double
    ) {
        self.transactionId = transactionId
        self.transactionTitle = transactionTitle
        self.amount = amount
        self.expectedRange = expectedRange
        self.deviation = deviation
        self.reason = reason
        self.confidence = confidence
    }
}

extension FinancialInsight {
    /// Sample insights for previews and testing
    public static var sampleSpendingAlert: FinancialInsight {
        FinancialInsight(
            type: .budgetAlert,
            title: "Budget Alert: Dining Out",
            description: "You've spent 85% of your monthly dining budget. Consider reducing restaurant expenses for the rest of the month.",
            priority: .high,
            category: "Dining",
            amount: 340.00,
            percentage: 85.0,
            actionRequired: true,
            suggestedAction: "Review dining expenses and set daily limits"
        )
    }

    public static var sampleSavingsOpportunity: FinancialInsight {
        FinancialInsight(
            type: .savingsOpportunity,
            title: "Coffee Savings",
            description: "You spend $120/month on coffee. Switching to home brewing could save you $80/month.",
            priority: .medium,
            category: "Coffee",
            amount: 80.00,
            percentage: 66.7,
            suggestedAction: "Try making coffee at home 3 days per week"
        )
    }

    public static var sampleAnomaly: FinancialInsight {
        FinancialInsight(
            type: .anomaly,
            title: "Unusual Transaction",
            description: "A $500 transaction at 'Electronics Store' is 300% higher than your average electronics spending.",
            priority: .high,
            category: "Electronics",
            amount: 500.00,
            actionRequired: true,
            suggestedAction: "Verify this transaction with your bank"
        )
    }
}
