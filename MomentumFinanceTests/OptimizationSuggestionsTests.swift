//
// OptimizationSuggestionsTests.swift
// MomentumFinance
//

import SharedKit
import XCTest
@testable import MomentumFinance

@MainActor
final class OptimizationSuggestionsTests: XCTestCase {
    func testBudgetAgentInsights() async throws {
        let agent = BudgetAgent()

        // Mock context with an anomaly
        let transactions = [
            CoreTransaction(amount: -100, note: "Regular"),
            CoreTransaction(amount: -100, note: "Regular"),
            CoreTransaction(amount: -100, note: "Regular"),
            CoreTransaction(amount: -2000, note: "Anomaly"),
        ]

        let context: [String: Sendable] = ["transactions": transactions]
        let result = try await agent.execute(context: context)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.summary.contains("Detected 1 spending anomalies"))
        XCTAssertEqual(result.detail["anomaly_count"], "1")
    }

    func testBudgetAgentIdleState() async throws {
        let agent = BudgetAgent()
        let result = try await agent.execute(context: [:])

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.summary.contains("No recent transactions found"))
    }
}
