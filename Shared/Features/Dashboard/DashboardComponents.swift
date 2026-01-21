import Foundation
import MomentumFinanceCore
import SwiftData
import SwiftUI

public struct DashboardSubscriptionsSection: View {
    let subscriptions: [Subscription]
    let onSubscriptionTapped: (Subscription) -> Void
    let onViewAllTapped: () -> Void
    let onAddTapped: () -> Void

    public init(
        subscriptions: [Subscription], onSubscriptionTapped: @escaping (Subscription) -> Void,
        onViewAllTapped: @escaping () -> Void, onAddTapped: @escaping () -> Void
    ) {
        self.subscriptions = subscriptions
        self.onSubscriptionTapped = onSubscriptionTapped
        self.onViewAllTapped = onViewAllTapped
        self.onAddTapped = onAddTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Subscriptions")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onViewAllTapped() }
                    .accessibilityLabel("View All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            ForEach(self.subscriptions.prefix(3)) { subscription in
                HStack {
                    Text(subscription.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(subscription.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { self.onSubscriptionTapped(subscription) }
            }

            Button(action: self.onAddTapped, label: {
                HStack {
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                    Text("Add Subscription").foregroundColor(.blue)
                }.font(.subheadline)
            })
            .accessibilityLabel("Add Subscription")
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardAccountsSummary: View {
    let accounts: [FinancialAccount]
    let onAccountTap: (String) -> Void
    let onViewAllTap: () -> Void

    public init(
        accounts: [FinancialAccount], onAccountTap: @escaping (String) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.accounts = accounts
        self.onAccountTap = onAccountTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All", action: self.onViewAllTap)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(self.accounts) { account in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(account.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)

                                Text(account.balance.formatted(.currency(code: "USD")))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(12)
                        .frame(width: 140, height: 110)
                        .background(platformBackgroundColor())
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                        .onTapGesture { self.onAccountTap(String(describing: account.persistentModelID)) }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8) // Space for shadow
            }
        }
    }
}

public struct DashboardBudgetProgress: View {
    let budgets: [Budget]
    let onBudgetTap: (Budget) -> Void
    let onViewAllTap: () -> Void

    public init(
        budgets: [Budget], onBudgetTap: @escaping (Budget) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.budgets = budgets
        self.onBudgetTap = onBudgetTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budgets")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onViewAllTap() }
                    .accessibilityLabel("View All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            ForEach(self.budgets.prefix(2), id: \.id) { budget in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(budget.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(Int(budget.spentAmount / budget.limitAmount * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: budget.spentAmount / budget.limitAmount)
                        .progressViewStyle(
                            LinearProgressViewStyle(
                                tint: budget.spentAmount > budget.limitAmount ? .red : .green
                            )
                        )
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { self.onBudgetTap(budget) }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardInsights: View {
    let insights: [FinancialInsight]
    let onDetailsTapped: () -> Void

    public init(insights: [FinancialInsight], onDetailsTapped: @escaping () -> Void) {
        self.insights = insights
        self.onDetailsTapped = onDetailsTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onDetailsTapped() }
                    .accessibilityLabel("View All Insights")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            if self.insights.isEmpty {
                Text("No insights available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(self.insights.prefix(2)) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading) {
                            Text(insight.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(insight.insightDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardQuickActions: View {
    let onAddTransaction: () -> Void
    let onPayBills: () -> Void
    let onViewReports: () -> Void
    let onSetGoals: () -> Void

    public init(
        onAddTransaction: @escaping () -> Void, onPayBills: @escaping () -> Void,
        onViewReports: @escaping () -> Void, onSetGoals: @escaping () -> Void
    ) {
        self.onAddTransaction = onAddTransaction
        self.onPayBills = onPayBills
        self.onViewReports = onViewReports
        self.onSetGoals = onSetGoals
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            HStack(spacing: 16) {
                self.quickAction(
                    icon: "plus.circle.fill", title: "Add Transaction", color: .blue,
                    action: self.onAddTransaction
                )
                self.quickAction(
                    icon: "creditcard.fill", title: "Pay Bills", color: .green, action: self.onPayBills
                )
                self.quickAction(
                    icon: "chart.bar.fill", title: "View Reports", color: .purple,
                    action: self.onViewReports
                )
                self.quickAction(icon: "target", title: "Set Goals", color: .orange, action: self.onSetGoals)
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    @ViewBuilder
    private func quickAction(
        icon: String, title: String, color: Color, action: @escaping () -> Void
    ) -> some View {
        VStack {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 24))
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }.onTapGesture(perform: action)
    }
}

// MARK: - Risk Level Enum

/// Risk levels for financial assessments with enhanced AI scoring
public enum RiskLevel: String, CaseIterable, Identifiable, Codable {
    case veryLow
    case low
    case medium
    case high
    case veryHigh
    case critical

    public var id: String { rawValue }

    /// Color associated with the risk level
    public var color: Color {
        switch self {
        case .veryLow: .green
        case .low: .mint
        case .medium: .blue
        case .high: .orange
        case .veryHigh: .red
        case .critical: .purple
        }
    }

    /// System icon for the risk level
    public var icon: String {
        switch self {
        case .veryLow: "checkmark.shield.fill"
        case .low: "checkmark.circle.fill"
        case .medium: "info.circle.fill"
        case .high: "exclamationmark.triangle.fill"
        case .veryHigh: "xmark.octagon.fill"
        case .critical: "flame.fill"
        }
    }

    /// Numeric risk score for calculations (0-100)
    public var score: Double {
        switch self {
        case .veryLow: 10
        case .low: 25
        case .medium: 50
        case .high: 75
        case .veryHigh: 90
        case .critical: 100
        }
    }
}

// MARK: - Insight Priority Enum

/// Priority levels for financial insights with visual styling and AI-enhanced ranking
public enum InsightPriority: String, CaseIterable, Comparable, Identifiable, Codable {
    case critical
    case high
    case medium
    case low

    public var id: String { rawValue }

    /// Color associated with the priority level
    public var color: Color {
        switch self {
        case .critical: .red
        case .high: .orange
        case .medium: .blue
        case .low: .green
        }
    }

    /// System icon for the priority level
    public var icon: String {
        switch self {
        case .critical: "exclamationmark.triangle.fill"
        case .high: "exclamationmark.circle.fill"
        case .medium: "info.circle.fill"
        case .low: "checkmark.circle.fill"
        }
    }

    /// Urgency score for AI ranking (higher = more urgent)
    public var urgencyScore: Int {
        switch self {
        case .critical: 100
        case .high: 75
        case .medium: 50
        case .low: 25
        }
    }

    // MARK: - Comparable Implementation

    /// Comparable implementation (critical > high > medium > low)
    public static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        let order: [InsightPriority] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs)
        else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Insight Type Enum

/// Types of financial insights that can be generated by AI analysis
public enum InsightType: String, CaseIterable, Identifiable, Codable {
    case spendingPattern
    case positiveSpendingTrend
    case anomaly
    case budgetAlert
    case budgetInsight
    case budgetRecommendation
    case subscriptionDetection
    case forecast
    case optimization
    case riskAlert
    case savingsOpportunity
    case investmentAdvice
    case debtManagement
    case taxOptimization
    case emergencyFund

    public var id: String { rawValue }

    /// System icon for the insight type
    public var icon: String {
        switch self {
        case .spendingPattern: "chart.line.uptrend.xyaxis"
        case .positiveSpendingTrend: "arrow.down.circle"
        case .anomaly: "exclamationmark.triangle"
        case .budgetAlert: "chart.pie.fill"
        case .budgetInsight: "chart.bar.fill"
        case .budgetRecommendation: "plus.circle"
        case .subscriptionDetection: "calendar.badge.clock"
        case .forecast: "chart.xyaxis.line"
        case .optimization: "bolt.circle"
        case .riskAlert: "shield.slash"
        case .savingsOpportunity: "dollarsign.circle"
        case .investmentAdvice: "chart.pie"
        case .debtManagement: "creditcard"
        case .taxOptimization: "doc.text"
        case .emergencyFund: "shield"
        }
    }

    /// Category grouping for better organization
    public var category: InsightCategory {
        switch self {
        case .spendingPattern, .positiveSpendingTrend, .anomaly: .spending
        case .budgetAlert, .budgetInsight, .budgetRecommendation: .budgeting
        case .forecast, .optimization, .subscriptionDetection: .planning
        case .riskAlert, .emergencyFund: .risk
        case .savingsOpportunity, .investmentAdvice: .wealth
        case .debtManagement, .taxOptimization: .financial
        }
    }
}

// MARK: - Insight Category Enum

/// Categories for organizing different types of insights
public enum InsightCategory: String, CaseIterable, Identifiable, Codable {
    case spending
    case budgeting
    case planning
    case risk
    case wealth
    case financial

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .spending: "Spending Analysis"
        case .budgeting: "Budget Management"
        case .planning: "Financial Planning"
        case .risk: "Risk Management"
        case .wealth: "Wealth Building"
        case .financial: "Financial Health"
        }
    }

    public var icon: String {
        switch self {
        case .spending: "creditcard"
        case .budgeting: "chart.pie"
        case .planning: "calendar"
        case .risk: "shield"
        case .wealth: "chart.line.uptrend.xyaxis"
        case .financial: "heart.circle"
        }
    }
}

// MARK: - Enhanced Financial Insight Model

/// Data point for chart visualizations
public struct ChartDataPoint: Codable, Identifiable {
    public var id: UUID
    public var label: String
    public var value: Double

    public init(label: String, value: Double) {
        self.id = UUID()
        self.label = label
        self.value = value
    }
}

/// Represents a specific financial insight generated by AI analysis
@Model
public final class FinancialInsight {
    public var id: UUID
    public var title: String
    public var insightDescription: String // Renamed from 'description' to avoid SwiftData conflict
    public var priority: InsightPriority
    public var type: InsightType
    public var confidence: Double // 0.0 to 1.0
    public var createdAt: Date
    public var isRead: Bool
    public var relatedAccountId: String?
    public var relatedTransactionId: String?
    public var relatedCategoryId: String?
    public var relatedBudgetId: String?
    public var actionTaken: Bool

    // Enhanced AI properties
    public var impactScore: Double // 0.0 to 10.0 - measures potential financial impact
    public var actionRecommendations: [String] // AI-generated action items
    public var potentialSavings: Double? // Estimated savings if action is taken
    public var riskLevel: RiskLevel // Associated risk level
    public var aiAnalysisVersion: String // Version of AI model used for analysis
    public var contextualTags: [String] // Tags for better categorization
    public var followUpDate: Date? // When to follow up on this insight
    public var isUserFeedbackPositive: Bool? // User feedback for ML improvement
    public var visualizationType: VisualizationType?
    public var chartData: [ChartDataPoint]?

    public init(
        title: String,
        description: String,
        priority: InsightPriority = .medium,
        type: InsightType,
        confidence: Double = 0.8,
        relatedAccountId: String? = nil,
        relatedTransactionId: String? = nil,
        relatedCategoryId: String? = nil,
        relatedBudgetId: String? = nil,
        impactScore: Double = 5.0,
        actionRecommendations: [String] = [],
        potentialSavings: Double? = nil,
        riskLevel: RiskLevel = .medium,
        visualizationType: VisualizationType? = nil,
        chartData: [ChartDataPoint]? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.insightDescription = description
        self.priority = priority
        self.type = type
        self.confidence = confidence
        self.createdAt = Date()
        self.isRead = false
        self.relatedAccountId = relatedAccountId
        self.relatedTransactionId = relatedTransactionId
        self.relatedCategoryId = relatedCategoryId
        self.relatedBudgetId = relatedBudgetId
        self.actionTaken = false
        self.impactScore = impactScore
        self.actionRecommendations = actionRecommendations
        self.potentialSavings = potentialSavings
        self.riskLevel = riskLevel
        self.aiAnalysisVersion = "v2.1"
        self.contextualTags = []
        self.followUpDate = nil
        self.isUserFeedbackPositive = nil
        self.visualizationType = visualizationType
        self.chartData = chartData
    }
}

// MARK: - AI Confidence Levels

/// Confidence levels for AI-generated insights
public enum AIConfidenceLevel: String, CaseIterable {
    case veryHigh // 90-100%
    case high // 80-89%
    case medium // 60-79%
    case low // 40-59%
    case veryLow // 0-39%

    public var range: ClosedRange<Double> {
        switch self {
        case .veryHigh: 0.90...1.0
        case .high: 0.80...0.89
        case .medium: 0.60...0.79
        case .low: 0.40...0.59
        case .veryLow: 0.0...0.39
        }
    }

    public var displayName: String {
        switch self {
        case .veryHigh: "Very High"
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        case .veryLow: "Very Low"
        }
    }

    public var color: Color {
        switch self {
        case .veryHigh: .green
        case .high: .blue
        case .medium: .orange
        case .low: .yellow
        case .veryLow: .red
        }
    }
}

// MARK: - Visualization Type Enum

/// Types of data visualizations that can be used for insights
public enum VisualizationType: String, CaseIterable, Codable {
    case barChart
    case lineChart
    case pieChart
    case progressBar
    case boxPlot
    case heatmap
    case scatterPlot
    case gauge

    public var displayName: String {
        switch self {
        case .barChart: "Bar Chart"
        case .lineChart: "Line Chart"
        case .pieChart: "Pie Chart"
        case .progressBar: "Progress Bar"
        case .boxPlot: "Box Plot"
        case .heatmap: "Heat Map"
        case .scatterPlot: "Scatter Plot"
        case .gauge: "Gauge"
        }
    }
}

// MARK: - Financial Intelligence Analysis Types

/// Types of AI financial analysis
public enum FinancialAnalysisType: String, CaseIterable {
    case trendAnalysis
    case anomalyDetection
    case predictiveModeling
    case riskAssessment
    case behaviorAnalysis
    case optimizationSuggestions
    case fraudDetection
    case portfolioAnalysis

    public var displayName: String {
        switch self {
        case .trendAnalysis: "Trend Analysis"
        case .anomalyDetection: "Anomaly Detection"
        case .predictiveModeling: "Predictive Modeling"
        case .riskAssessment: "Risk Assessment"
        case .behaviorAnalysis: "Behavior Analysis"
        case .optimizationSuggestions: "Optimization Suggestions"
        case .fraudDetection: "Fraud Detection"
        case .portfolioAnalysis: "Portfolio Analysis"
        }
    }
}
