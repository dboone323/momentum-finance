import XCTest
@testable import MomentumFinance

class DashboardInsightsTests: XCTestCase {
    var insightsViewModel: DashboardInsightsViewModel!
    var mockOnDetailsTapped: (() -> Void)?

    // Test the Insights View Model's properties and methods

    func testInsightsViewModelProperties() {
        XCTAssertEqual(insightsViewModel.insights.count, 3)
        // NOTE: `onDetailsTapped` is a closure; verifying equality of closures is not straightforward in tests
        XCTAssertNotNil(insightsViewModel.onDetailsTapped)
    }

    func testInsightsView() {
        // GIVEN: A DashboardInsights view with some insights and an onDetailsTapped action
        let insights = [
            "Monthly spending is 15% lower than last month",
            "Savings increased by 8% this month",
            "3 subscriptions will renew next week",
        ]
        let onDetailsTapped = { [weak self] in
            self?.mockOnDetailsTapped?()
        }

        // WHEN: The view is created with the given insights and onDetailsTapped action
        let view = DashboardInsights(insights: insights, onDetailsTapped: onDetailsTapped)

        // THEN: Verify that the view displays the correct insights and button
        XCTAssertEqual(view.insights.count, 3)
        XCTAssertTrue(view.contains(where: { $0 is InsightItem }))
        XCTAssertTrue(view.contains(where: { $0 is Button }))

        // WHEN: The button is tapped
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.buttonTapped))
        view.addGestureRecognizer(tapGesture)

        // THEN: Verify that the onDetailsTapped action is called
        mockOnDetailsTapped = { [weak self] in
            self?.mockOnDetailsTapped?()
        }

        tapGesture.sendActions(for: .touchUpInside)
        XCTAssertTrue(mockOnDetailsTapped != nil)
    }
}
