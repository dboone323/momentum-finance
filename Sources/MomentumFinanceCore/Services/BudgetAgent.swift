import Foundation
import SharedKit
import SwiftData

/// Agent specializing in budget analysis and predictive finance for 2026.
public final class BudgetAgent: BaseAgent {
    public let id = "budget_agent_001"
    public let name = "Finance Strategy Agent"
    private let ollamaClient: OllamaClient

    @MainActor
    public init(ollamaClient: OllamaClient = OllamaClient()) {
        self.ollamaClient = ollamaClient
    }

    public func execute(context: [String: any Sendable]) async throws -> AgentResult {
        // Log start
        NSLog("[\(name)] Starting autonomous budget analysis...")

        // 1. Analyze spending patterns
        let transactions = context["transactions"] as? [CoreTransaction] ?? []

        guard !transactions.isEmpty else {
            return AgentResult(
                agentId: id,
                success: true,
                summary: "No recent transactions found for analysis. Settle more data for insights.",
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

        // 3. Perform Autonomous Reasoning
        let reasoningResult = await performAutonomousReasoning(
            transactions: transactions,
            burnRate: burnRate,
            anomalies: anomalies
        )

        var detail: [String: String] = [:]
        detail["burn_rate"] = burnRate.description
        detail["anomaly_count"] = "\(anomalies.count)"
        detail["tactical_advice"] = reasoningResult.advice

        return AgentResult(
            agentId: id,
            success: true,
            summary: reasoningResult.summary,
            detail: detail,
            requiresApproval: reasoningResult.requiresAction
        )
    }

    private func performAutonomousReasoning(
        transactions: [CoreTransaction],
        burnRate: Double,
        anomalies: [CoreTransaction]
    ) async -> (summary: String, advice: String, requiresAction: Bool) {
        let transactionSummary = transactions.prefix(5).map { "\($0.merchant): \($0.amount)" }.joined(separator: ", ")
        let anomalySummary = anomalies.map { "\($0.merchant): \($0.amount)" }.joined(separator: ", ")

        let prompt = """
        Strategic Financial Analysis Request:
        Burn Rate: \(burnRate)
        Detected Anomalies: \(anomalySummary.isEmpty ? "None" : anomalySummary)
        Recent Sample: \(transactionSummary)

        Provide a concise strategic summary and tactical advice for the user. Focus on real-world financial implications.
        Return EXCLUSIVELY a JSON object with:
        - "summary": String
        - "advice": String
        - "requiresAction": Boolean (true if anomalies are severe)
        """

        do {
            let response = try await ollamaClient.generate(
                model: nil,
                prompt: prompt,
                temperature: 0.4,
                maxTokens: 500,
                useCache: true
            )

            // Robust JSON extraction
            let cleanedResponse = if let range = response.range(of: "\\{.*\\}", options: .regularExpression) {
                String(response[range])
            } else {
                response
            }

            guard let data = cleanedResponse.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let summary = json["summary"] as? String,
                  let advice = json["advice"] as? String,
                  let requiresAction = json["requiresAction"] as? Bool
            else {
                return (
                    summary: "Financial analysis inconclusive due to processing errors.",
                    advice: "Please review your transactions manually in the app while we recalibrate the AI engine.",
                    requiresAction: !anomalies.isEmpty
                )
            }
            return (summary, advice, requiresAction)
        } catch {
            return (
                summary: "AI Financial Analysis Engine offline.",
                advice: "Standard burn rate analysis is \(burnRate). Check for anomalies manually: \(anomalies.count) detected.",
                requiresAction: !anomalies.isEmpty
            )
        }
    }
}
