import XCTest
@testable import MomentumFinance

class SubscriptionsViewTests: XCTestCase {
    var subscriptions: [Subscription]!
    var selectedFilter: SubscriptionFilter = .all
    var showingAddSubscription: Bool = false
    var viewModel: SubscriptionsViewModel!

    func testSubscriptionHeaderView() {
        // GIVEN
        let view = SubscriptionHeaderView(
            subscriptions: subscriptions,
            selectedFilter: $selectedFilter,
            showingAddSubscription: $showingAddSubscription
        )

        // WHEN
        // No actions needed for this test

        // THEN
        XCTAssertEqual(view.body, expectation)
    }

    func testSubscriptionSummaryCard() {
        // GIVEN
        let view = SubscriptionSummaryCard(subscriptions: subscriptions)

        // WHEN
        // No actions needed for this test

        // THEN
        XCTAssertEqual(view.body, expectation)
    }

    func testStatItem() {
        // GIVEN
        let view = StatItem(title: "Active", value: "2", color: .green)

        // WHEN
        // No actions needed for this test

        // THEN
        XCTAssertEqual(view.body, expectation)
    }
}
