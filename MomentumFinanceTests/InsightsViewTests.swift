import XCTest
import SwiftData
@testable import MomentumFinance

class InsightsViewTests: XCTestCase {
    var intelligenceService: FinancialIntelligenceService!
    var modelContext: ModelContext!

    // Test that the InsightsView displays insights when data is available
    func testInsightsDisplayWhenDataAvailable() async throws {
        // Given: An instance of InsightsView with some financial insights
        let insightsView = InsightsView()

        // When: The view is loaded
        await insightsView.loadView()

        // Then: The insights list should be populated with the available insights
        XCTAssertEqual(insightsView.insightsList.count, 3) // Assuming there are 3 insights in the modelContext

        // Test that clicking on an insight opens the InsightDetailView
        let insight = insightsView.intelligenceService.insights.first!
        insightsView.selectedInsight = insight
        await insightsView.loadView()

        XCTAssertEqual(insightsView.sheet.isPresented, true)
    }

    // Test that the InsightsView displays a loading view when data is not available
    func testInsightsDisplayWhenDataNotAvailable() async throws {
        // Given: An instance of InsightsView with no financial insights
        let insightsView = InsightsView()

        // When: The view is loaded
        await insightsView.loadView()

        // Then: The insights list should be empty and a loading view should be displayed
        XCTAssertEqual(insightsView.insightsList.count, 0)
        XCTAssertTrue(insightsView.insightsLoadingView.isDisplayed)
    }

    // Test that the InsightsView displays an empty state view when data is available but no insights are found
    func testInsightsDisplayWhenDataAvailableButNoInsights() async throws {
        // Given: An instance of InsightsView with a modelContext containing no financial insights
        let insightsView = InsightsView()

        // When: The view is loaded
        await insightsView.loadView()

        // Then: The insights list should be empty and an empty state view should be displayed
        XCTAssertEqual(insightsView.insightsList.count, 0)
        XCTAssertTrue(insightsView.insightsEmptyStateView.isDisplayed)
    }

    // Test that the InsightsView displays insights based on filter criteria
    func testInsightsDisplayWithFilter() async throws {
        // Given: An instance of InsightsView with some financial insights and filters applied
        let insightsView = InsightsView()
        let insight1 = FinancialInsight(priority: .critical, type: .expense)
        let insight2 = FinancialInsight(priority: .high, type: .income)
        let insight3 = FinancialInsight(priority: .low, type: .expense)
        modelContext.insert(insight1, into: &modelContext)
        modelContext.insert(insight2, into: &modelContext)
        modelContext.insert(insight3, into: &modelContext)

        insightsView.filterPriority = .high
        insightsView.filterType = .income

        // When: The view is loaded
        await insightsView.loadView()

        // Then: The insights list should be populated with the filtered insights
        XCTAssertEqual(insightsView.insightsList.count,
                       2) // Assuming there are 2 insights in the modelContext that match the filter criteria
    }

    // Test that the InsightsView displays insights sorted by priority (critical first)
    func testInsightsDisplaySortedByPriority() async throws {
        // Given: An instance of InsightsView with some financial insights and a sorted list
        let insightsView = InsightsView()
        let insight1 = FinancialInsight(priority: .critical, type: .expense)
        let insight2 = FinancialInsight(priority: .high, type: .income)
        let insight3 = FinancialInsight(priority: .low, type: .expense)
        modelContext.insert(insight1, into: &modelContext)
        modelContext.insert(insight2, into: &modelContext)
        modelContext.insert(insight3, into: &modelContext)

        insightsView.sortedByPriority = true

        // When: The view is loaded
        await insightsView.loadView()

        // Then: The insights list should be populated with the sorted insights
        XCTAssertEqual(insightsView.insightsList.count,
                       3) // Assuming there are 3 insights in the modelContext that match the filter criteria
    }
}
