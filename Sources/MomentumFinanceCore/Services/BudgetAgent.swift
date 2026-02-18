import Foundation
import SharedKit
import SwiftData

/// Agent specializing in budget analysis and predictive finance for 2026.
public final class BudgetAgent: BaseAgent {
    public let id = "budget_agent_001"
    public let name = "Finance Strategy Agent"

    public init() {}

    public func execute(context: [String: Sendable]) async throws -> AgentResult {
        // Log start
        NSLog("[\(name)] Starting autonomous budget analysis...")

        // 1. Analyze spending patterns
        // Ideally, we'd pull from SwiftData context, but for now we look for transactions in the context dictionary
        let transactions = context["transactions"] as? [CoreTransaction] ?? []

        guard !transactions.isEmpty else {
            return AgentResult(
                agentId: id,
                success: true,
                summary:
                "No recent transactions found for analysis. Settle more data for insights.",
                detail: ["status": "idle"],
                requiresApproval: false
            )
        }

        // 2. Generate insights using SpendingAnalyzer
        let burnRate = await SpendingAnalyzer.shared.calculateMonthlyBurnRate(
            transactions: transactions
        )
        let anomalies = await SpendingAnalyzer.shared.detectSpendingAnomalies(
            transactions: transactions
        )

        let summary: String
        var detail: [String: String] = [:]

        if anomalies.isEmpty {
            summary =
                "Spending profile is stable. Average monthly burn rate is \(burnRate.description)."
            detail["burn_rate"] = burnRate.description
        } else {
            summary =
                "Detected \(anomalies.count) spending anomalies! Average burn rate: \(burnRate.description)."
            detail["anomaly_count"] = "\(anomalies.count)"
            detail["burn_rate"] = burnRate.description
            detail["recommendation"] =
                "Review large unusual transactions to maintain budget health."
        }

        return AgentResult(
            agentId: id,
            success: true,
            summary: summary,
            detail: detail,
            requiresApproval: false
        )
    }
}
