@testable import MomentumFinance
import XCTest

class InsightRowViewTests: XCTestCase {
    var insightRowView: InsightRowView!

    // Test the body of the InsightRowView
    func testBody() {
        // GIVEN
        let mockInsight = FinancialInsight(title: "Test Insight", description: "This is a test insight.", type: .critical, confidence: 0.85)
        let mockAction = { /* Mock action */ }
        insightRowView = InsightRowView(insight: mockInsight) { mockAction }

        // WHEN
        let body = insightRowView.body

        // THEN (basic sanity checks)
        XCTAssertNotNil(body)
        XCTAssertTrue(body.description.contains("Test Insight"))
        XCTAssertTrue(body.description.contains("This is a test insight."))
    }

    // Test the priorityColor method
    func testPriorityColor() {
        // GIVEN
        let mockInsight = FinancialInsight(title: "Test Insight", description: "This is a test insight.", type: .critical, confidence: 0.85)

        // WHEN
        let color = insightRowView.priorityColor

        // THEN
        XCTAssertEqual(color, .red)
    }

    // Test the action method
    func testAction() {
        // GIVEN
        let mockInsight = FinancialInsight(title: "Test Insight", description: "This is a test insight.", type: .critical, confidence: 0.85)
        var called = false

        let mockAction = { called = true }

        insightRowView = InsightRowView(insight: mockInsight) { mockAction }

        // WHEN
        insightRowView.action()

        // THEN
        XCTAssertTrue(called)
    }
}
