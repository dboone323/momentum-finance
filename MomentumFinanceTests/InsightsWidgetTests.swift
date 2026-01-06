import XCTest
import SwiftData
@testable import MomentumFinance

class InsightsWidgetTests: XCTestCase {
    var insightsService: FinancialIntelligenceService!
    var modelContext: ModelContext!

    // Test that the InsightsWidget displays the correct header and buttons
    func testInsightsWidgetDisplay() {
        let widget = InsightsWidget()

        XCTAssertEqual(widget.headerLabel, "Financial Insights")
        XCTAssertTrue(widget.showAllButton)
    }

    // Test that the InsightsWidget shows loading content while analyzing data
    func testLoadingContent() {
        insightsService.isAnalyzing = true

        let widget = InsightsWidget()
        let view = widget.loadingContent

        XCTAssertEqual(view.title, "Analyzing your finances...")
        XCTAssertTrue(view.progressView.isIndeterminate)
    }

    // Test that the InsightsWidget shows an empty content when no insights are available
    func testEmptyContent() {
        insightsService.insights.removeAll()

        let widget = InsightsWidget()
        let view = widget.emptyContent

        XCTAssertEqual(view.title, "No insights yet")
        XCTAssertTrue(view.chartBarDocHorizontalImage.isShowing)
    }

    // Test that the InsightsWidget displays the correct insights content
    func testInsightsContent() {
        let insight1 = FinancialInsight(priority: .high, description: "High Risk Investment", value: 5000.00)
        let insight2 = FinancialInsight(priority: .medium, description: "Medium Risk Investment", value: 3000.00)
        insightsService.insights.append(insight1)
        insightsService.insights.append(insight2)

        let widget = InsightsWidget()
        let view = widget.insightsContent

        XCTAssertEqual(view.count, 2)
        XCTAssertTrue(view[0].priority.color == insight1.priority.color)
        XCTAssertTrue(view[0].description == insight1.description)
        XCTAssertTrue(view[0].value == insight1.value)
    }

    // Test that the InsightsWidget displays all insights when showAllButton is tapped
    func testShowAllInsights() {
        insightsService.insights.removeAll()

        let insight1 = FinancialInsight(priority: .high, description: "High Risk Investment", value: 5000.00)
        let insight2 = FinancialInsight(priority: .medium, description: "Medium Risk Investment", value: 3000.00)
        insightsService.insights.append(insight1)
        insightsService.insights.append(insight2)

        let widget = InsightsWidget()
        let view = widget.insightsContent

        XCTAssertEqual(view.count, 2)

        widget.showAllButton = true
        let newView = widget.insightsContent

        XCTAssertTrue(newView.count > 2)
    }
}
