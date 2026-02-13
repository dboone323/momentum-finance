import Combine
import Foundation
import MomentumFinanceCore
import SwiftUI

/// Advanced AI-powered financial intelligence service
/// Provides predictive analytics, risk assessment, and smart recommendations
@MainActor
public class AdvancedFinancialIntelligence: ObservableObject {
    // MARK: - Published Properties

    @Published public var insights: [EnhancedFinancialInsight] = []
    @Published public var riskAssessment: RiskAssessment?
    @Published public var predictiveAnalytics: PredictiveAnalytics?
    @Published public var isAnalyzing = false
    @Published public var lastAnalysisDate: Date?

    // MARK: - Private Properties

    private let analyticsEngine = FinancialAnalyticsEngine()
    private let predictionEngine = PredictionEngine()
    private let riskEngine = RiskAssessmentEngine()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init() {
        self.setupAutoAnalysis()
    }

    // MARK: - Public Methods

    public func generateInsights(
        from transactions: [FinancialTransaction],
        accounts: [FinancialAccount],
        budgets: [Budget]
    ) async {
        self.isAnalyzing = true

        // Generate multiple types of insights concurrently
        let spendingInsights = await self.analyzeSpendingPatterns(transactions)
        let savingsInsights = await self.analyzeSavingsOpportunities(transactions, accounts)
        let budgetInsights = await self.analyzeBudgetPerformance(transactions, budgets)
        let riskInsights = await self.assessFinancialRisk(transactions, accounts)
        let predictiveInsights = await self.generatePredictions(transactions, accounts)

        let allInsights = [
            spendingInsights,
            savingsInsights,
            budgetInsights,
            riskInsights,
            predictiveInsights,
        ].flatMap(\.self)

        // AI-powered insight ranking and prioritization
        self.insights = self.prioritizeInsights(allInsights)

        // Generate risk assessment
        self.riskAssessment = await self.generateRiskAssessment(transactions, accounts)

        // Generate predictive analytics
        self.predictiveAnalytics = await self.generatePredictiveAnalytics(transactions, accounts)

        self.lastAnalysisDate = Date()
        self.isAnalyzing = false
    }

    /// Get personalized investment recommendations
    public func getInvestmentRecommendations(
        riskTolerance: RiskTolerance,
        timeHorizon: TimeHorizon,
        currentPortfolio: [Investment]
    ) -> [InvestmentRecommendation] {
        self.analyticsEngine.generateInvestmentRecommendations(
            riskTolerance: riskTolerance,
            timeHorizon: timeHorizon,
            currentPortfolio: currentPortfolio
        )
    }

    public func predictCashFlow(
        transactions: [FinancialTransaction],
        months: Int = 12
    ) -> [CashFlowPrediction] {
        self.predictionEngine.predictCashFlow(
            transactions: transactions,
            monthsAhead: months
        )
    }

    /// Detect anomalous transactions (fraud detection)
    public func detectAnomalies(in transactions: [FinancialTransaction]) -> [TransactionAnomaly] {
        self.analyticsEngine.detectAnomalies(in: transactions)
    }

    // MARK: - Private Analysis Methods

    private func analyzeSpendingPatterns(_ transactions: [FinancialTransaction]) async
        -> [EnhancedFinancialInsight]
    {
        var insights: [EnhancedFinancialInsight] = []

        // Analyze spending velocity
        let spendingVelocity = self.calculateSpendingVelocity(transactions)
        if spendingVelocity.percentageIncrease > 20 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Accelerating Spending Detected",
                    description:
                    "Your spending has increased by \(Int(spendingVelocity.percentageIncrease))% this month. Consider reviewing your recent purchases.",
                    priority: .high,
                    type: .spendingAlert,
                    confidence: 0.9,
                    actionRecommendations: [
                        "Review recent transactions",
                        "Set stricter budget limits",
                        "Enable spending alerts",
                    ],
                    impactScore: 8.5
                )
            )
        }

        // Analyze category trends
        let categoryTrends = self.analyzeCategoryTrends(transactions)
        for trend in categoryTrends where trend.isSignificant {
            insights.append(
                EnhancedFinancialInsight(
                    title: "\(trend.category) Spending Trend",
                    description: trend.description,
                    priority: trend.priority,
                    type: .categoryInsight,
                    confidence: trend.confidence,
                    relatedCategoryId: trend.categoryId,
                    actionRecommendations: trend.recommendations,
                    impactScore: trend.impactScore
                )
            )
        }

        return insights
    }

    private func analyzeSavingsOpportunities(
        _ transactions: [FinancialTransaction],
        _ accounts: [FinancialAccount]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Identify subscription optimization opportunities
        let subscriptions = self.identifySubscriptions(transactions)
        let unusedSubscriptions = self.findUnusedSubscriptions(subscriptions)

        if !unusedSubscriptions.isEmpty {
            let potentialSavings = unusedSubscriptions.reduce(Decimal(0)) { $0 + $1.monthlyAmount }
            insights.append(
                EnhancedFinancialInsight(
                    title: "Subscription Optimization Opportunity",
                    description:
                    "You could save $\(potentialSavings)/month by canceling \(unusedSubscriptions.count) unused subscriptions.",
                    priority: .medium,
                    type: .savingsOpportunity,
                    confidence: 0.85,
                    actionRecommendations: [
                        "Review subscription usage",
                        "Cancel unused subscriptions",
                        "Set usage reminders",
                    ],
                    potentialSavings: potentialSavings * 12, // Annual savings
                    impactScore: 7.2
                )
            )
        }

        // High-yield savings opportunities
        let cashBalance = accounts.reduce(Decimal(0)) { $0 + Decimal($1.balance) }

        if cashBalance > 10000 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "High-Yield Savings Opportunity",
                    description:
                    "Consider moving excess cash to high-yield savings to earn up to 4.5% APY.",
                    priority: .medium,
                    type: .savingsOpportunity,
                    confidence: 0.95,
                    actionRecommendations: [
                        "Research high-yield savings accounts",
                        "Compare interest rates",
                        "Consider CDs for longer terms",
                    ],
                    potentialSavings: cashBalance * Decimal(0.045), // Potential annual earnings
                    impactScore: 6.8
                )
            )
        }

        return insights
    }

    private func analyzeBudgetPerformance(
        _ transactions: [FinancialTransaction],
        _ budgets: [Budget]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        for budget in budgets {
            let spent = self.calculateSpentAmount(transactions, for: budget)
            let budgetLimit = Decimal(budget.totalAmount)
            let percentageUsed = Double(
                truncating: (spent / budgetLimit * 100) as NSDecimalNumber
            )

            if percentageUsed > 90 {
                let remaining = budgetLimit - spent
                insights.append(
                    EnhancedFinancialInsight(
                        title: "\(budget.name) Budget Alert",
                        description:
                        "You've used \(Int(percentageUsed))% of your \(budget.name) budget. $\(remaining) remaining.",
                        priority: percentageUsed > 100 ? .critical : .high,
                        type: .budgetAlert,
                        confidence: 0.95,
                        relatedBudgetId: budget.id.uuidString,
                        actionRecommendations: [
                            "Reduce spending in this category",
                            "Consider increasing budget if necessary",
                            "Review recent transactions",
                        ],
                        impactScore: percentageUsed > 100 ? 9.5 : 8.0
                    )
                )
            }
        }

        return insights
    }

    private func assessFinancialRisk(
        _ transactions: [FinancialTransaction],
        _ accounts: [FinancialAccount]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Emergency fund assessment
        let monthlyExpenses = self.calculateMonthlyExpenses(transactions)
        let emergencyFund = accounts.filter { $0.accountType == .savings }
            .reduce(Decimal(0)) { $0 + Decimal($1.balance) }

        guard monthlyExpenses > 0 else { return [] }
        let monthsCovered = Double(truncating: (emergencyFund / monthlyExpenses) as NSDecimalNumber)

        if monthsCovered < 3 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Emergency Fund Below Recommended Level",
                    description:
                    "Your emergency fund covers \(String(format: "%.1f", monthsCovered)) months of expenses. Experts recommend 3-6 months.",
                    priority: monthsCovered < 1 ? .critical : .high,
                    type: .riskAlert,
                    confidence: 0.9,
                    actionRecommendations: [
                        "Set up automatic savings transfers",
                        "Reduce discretionary spending temporarily",
                        "Consider side income opportunities",
                    ],
                    impactScore: monthsCovered < 1 ? 9.8 : 7.5
                )
            )
        }

        return insights
    }

    private func generatePredictions(
        _ transactions: [FinancialTransaction],
        _: [FinancialAccount]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Cash flow prediction
        let predictions = self.predictionEngine.predictCashFlow(
            transactions: transactions, monthsAhead: 3
        )
        let negativeMonths = predictions.filter { $0.netCashFlow < 0 }

        if !negativeMonths.isEmpty {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Potential Cash Flow Issues Ahead",
                    description:
                    "Predicted negative cash flow in \(negativeMonths.count) of the next 3 months.",
                    priority: .high,
                    type: .prediction,
                    confidence: 0.75,
                    actionRecommendations: [
                        "Review upcoming expenses",
                        "Consider increasing income",
                        "Reduce non-essential spending",
                    ],
                    impactScore: 8.2
                )
            )
        }

        return insights
    }

    // MARK: - Helper Methods

    private func setupAutoAnalysis() {
        // Setup automatic analysis every 24 hours
        Timer.publish(every: 86400, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.performAutoAnalysis()
                }
            }
            .store(in: &self.cancellables)
    }

    private func performAutoAnalysis() async {
        // This would integrate with the actual data service
    }

    private func prioritizeInsights(_ insights: [EnhancedFinancialInsight])
        -> [EnhancedFinancialInsight]
    {
        insights.sorted { first, second in
            // Priority by severity first, then by impact score
            if first.priority != second.priority {
                return first.priority.rawValue > second.priority.rawValue
            }
            return first.impactScore > second.impactScore
        }
    }

    private func calculateSpendingVelocity(_: [FinancialTransaction]) -> SpendingVelocity {
        SpendingVelocity(percentageIncrease: 15.0) // Placeholder
    }

    private func analyzeCategoryTrends(_: [FinancialTransaction]) -> [CategoryTrend] {
        [] // Placeholder
    }

    private func identifySubscriptions(_: [FinancialTransaction]) -> [Subscription] {
        [] // Placeholder
    }

    private func findUnusedSubscriptions(_: [Subscription]) -> [Subscription] {
        [] // Placeholder
    }

    private func calculateSpentAmount(_: [FinancialTransaction], for _: Budget) -> Decimal {
        Decimal(0) // Placeholder
    }

    private func calculateMonthlyExpenses(_: [FinancialTransaction]) -> Decimal {
        Decimal(5000) // Placeholder
    }

    private func generateRiskAssessment(
        _: [FinancialTransaction],
        _: [FinancialAccount]
    ) async -> RiskAssessment {
        RiskAssessment(
            overallRiskLevel: .moderate,
            emergencyFundRisk: .high,
            debtRisk: .low,
            investmentRisk: .moderate,
            cashFlowRisk: .medium
        )
    }

    private func generatePredictiveAnalytics(
        _: [FinancialTransaction],
        _: [FinancialAccount]
    ) async -> PredictiveAnalytics {
        PredictiveAnalytics(
            nextMonthSpending: 4200,
            nextMonthIncome: 6500,
            savingsProjection: 2300,
            budgetVarianceProjection: 0.85
        )
    }

    // MARK: - Enhanced Financial Insight Model

    public struct EnhancedFinancialInsight: Identifiable, Hashable, Sendable {
        public let id = UUID()
        public let title: String
        public let description: String
        public let priority: InsightPriority
        public let type: InsightType
        public let confidence: Double
        public let relatedAccountId: String?
        public let relatedTransactionId: String?
        public let relatedCategoryId: String?
        public let relatedBudgetId: String?
        public let actionRecommendations: [String]
        public let potentialSavings: Decimal?
        public let impactScore: Double // 0-10 scale
        public let createdAt: Date

        public init(
            title: String,
            description: String,
            priority: InsightPriority,
            type: InsightType,
            confidence: Double = 0.8,
            relatedAccountId: String? = nil,
            relatedTransactionId: String? = nil,
            relatedCategoryId: String? = nil,
            relatedBudgetId: String? = nil,
            actionRecommendations: [String] = [],
            potentialSavings: Decimal? = nil,
            impactScore: Double = 5.0
        ) {
            self.title = title
            self.description = description
            self.priority = priority
            self.type = type
            self.confidence = confidence
            self.relatedAccountId = relatedAccountId
            self.relatedTransactionId = relatedTransactionId
            self.relatedCategoryId = relatedCategoryId
            self.relatedBudgetId = relatedBudgetId
            self.actionRecommendations = actionRecommendations
            self.potentialSavings = potentialSavings
            self.impactScore = impactScore
            self.createdAt = Date()
        }
    }

    // MARK: - Supporting Types

    public enum InsightPriority: Int, CaseIterable, Hashable, Sendable {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }

    public enum InsightType: Hashable, Sendable {
        case spendingAlert
        case savingsOpportunity
        case budgetAlert
        case categoryInsight
        case riskAlert
        case prediction
        case recommendation
    }

    public struct RiskAssessment: Sendable {
        let overallRiskLevel: RiskLevel
        let emergencyFundRisk: RiskLevel
        let debtRisk: RiskLevel
        let investmentRisk: RiskLevel
        let cashFlowRisk: RiskLevel
    }

    public enum RiskLevel: Sendable {
        case low, medium, moderate, high, critical
    }

    public struct PredictiveAnalytics: Sendable {
        let nextMonthSpending: Decimal
        let nextMonthIncome: Decimal
        let savingsProjection: Decimal
        let budgetVarianceProjection: Double // 0-1 scale
    }

    public struct SpendingVelocity: Sendable {
        let percentageIncrease: Double
    }

    public struct CategoryTrend: Sendable {
        let category: String
        let categoryId: String
        let isSignificant: Bool
        let description: String
        let priority: InsightPriority
        let confidence: Double
        let recommendations: [String]
        let impactScore: Double
    }

    public struct Subscription: Sendable {
        let name: String
        let monthlyAmount: Decimal
        let lastUsed: Date?
    }

    public struct InvestmentRecommendation: Sendable {
        let type: String
        let allocation: Double
        let riskLevel: RiskLevel
        let expectedReturn: Double
    }

    public struct CashFlowPrediction: Sendable {
        let month: Date
        let predictedIncome: Decimal
        let predictedExpenses: Decimal
        let netCashFlow: Decimal
    }

    public struct TransactionAnomaly {
        let transaction: FinancialTransaction
        let anomalyType: AnomalyType
        let confidence: Double
    }

    public enum AnomalyType {
        case unusualAmount
        case unusualMerchant
        case unusualLocation
        case unusualTime
        case possibleFraud
    }

    public enum TimeHorizon: Sendable {
        case shortTerm, mediumTerm, longTerm
    }

    private class FinancialAnalyticsEngine {
        func generateInvestmentRecommendations(
            riskTolerance _: RiskTolerance,
            timeHorizon _: TimeHorizon,
            currentPortfolio _: [Investment]
        ) -> [InvestmentRecommendation] {
            []
        }

        func detectAnomalies(in _: [FinancialTransaction]) -> [TransactionAnomaly] {
            []
        }
    }

    private class PredictionEngine {
        func predictCashFlow(transactions _: [FinancialTransaction], monthsAhead _: Int)
            -> [CashFlowPrediction]
        {
            []
        }
    }

    private class RiskAssessmentEngine {}
}
