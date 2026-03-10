import Foundation
import SharedKit
import MomentumFinanceCore

@available(macOS 15.0, *)
@main
struct BudgetAudit {
    static func main() async {
        print(">>> [MomentumFinance Agent] Starting Budget Analysis task...")

        // Initialize agent
        let agent = BudgetAgent()

        // Mock transaction context
        let context: [String: Sendable] = [
            "transactions": [
                CoreTransaction(id: UUID(), amount: 150.0, date: Date(), note: "Unusual subscription payment", categoryId: UUID(), accountId: UUID()),
                CoreTransaction(id: UUID(), amount: 45.0, date: Date().addingTimeInterval(-86400), note: "Grocery", categoryId: UUID(), accountId: UUID())
            ]
        ]

        print(">>> [Task] Running autonomous budget audit on 2 transactions...")
        do {
            let result = try await agent.execute(context: context)
            print("\n--- Agent Result: \(result.agentId) ---")
            print("Status: \(result.success ? "SUCCESS" : "FAILURE")")
            print("Summary: \(result.summary)")
            print("Anomalies Detected: \(result.detail["anomaly_count"] ?? "0")")
            print("Recommendation: \(result.detail["recommendation"] ?? "None")")
            print("Timestamp: \(result.timestamp)")
        } catch {
            print("Error executing agent: \(error)")
        }

        print("\n>>> [MomentumFinance Agent] Task completed.")
    }
}
