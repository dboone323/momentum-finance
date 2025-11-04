import XCTest
@testable import MomentumFinance

class SubscriptionsViewTests: XCTestCase {
    var subscriptions: [Subscription]!
    var selectedFilter: SubscriptionFilter = .all
    var showingAddSubscription: Bool = false
    var viewModel: SubscriptionsViewModel!

    override func setUp() {
        super.setUp()
        // Initialize test data
        let subscription1 = Subscription(id: 1, name: "Monthly Subscription", isActive: true, dueDate: Date(), amount: 50.0)
        let subscription2 = Subscription(id: 2, name: "Annual Subscription", isActive: false, dueDate: Date().addingTimeInterval(365 * 24 * 60 * 60), amount: 100.0)
        subscriptions = [subscription1, subscription2]
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test data
        subscriptions.removeAll()
    }

    func testSubscriptionHeaderView() {
        // GIVEN
        let view = SubscriptionHeaderView(subscriptions: subscriptions, selectedFilter: $selectedFilter, showingAddSubscription: $showingAddSubscription)

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
