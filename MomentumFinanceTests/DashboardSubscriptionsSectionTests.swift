import XCTest
@testable import MomentumFinance

class DashboardSubscriptionsSectionTests: XCTestCase {
    var subscriptions: [Subscription]!
    var onSubscriptionTapped: (Subscription) -> Void!
    var onViewAllTapped: () -> Void!
    var onAddTapped: () -> Void!

    override func setUp() {
        super.setUp()
        // Initialize test data
        let subscription1 = Subscription(
            name: "Netflix", amount: 15.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 3)
        )
        let subscription2 = Subscription(
            name: "Spotify", amount: 9.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 7)
        )

        subscriptions = [subscription1, subscription2]
        onSubscriptionTapped = { _ in }
        onViewAllTapped = {}
        onAddTapped = {}
    }

    override func tearDown() {
        super.tearDown()
        // Clean up test data
        subscriptions = []
        onSubscriptionTapped = nil
        onViewAllTapped = nil
        onAddTapped = nil
    }

    // Test case for the body of DashboardSubscriptionsSection
    func testBody() {
        let view = DashboardSubscriptionsSection(
            subscriptions: subscriptions,
            onSubscriptionTapped: onSubscriptionTapped,
            onViewAllTapped: onViewAllTapped,
            onAddTapped: onAddTapped
        )

        // GIVEN the view is displayed
        // WHEN the body is rendered
        let result = view.body

        // THEN the view should contain the correct number of subscriptions
        XCTAssertEqual(result.subscribers.count, 2)

        // AND each subscription should be displayed correctly
        for (index, subscription) in subscriptions.enumerated() {
            let subscriber = result.subscribers[index]
            XCTAssertEqual(subscriber.name, subscription.name)
            XCTAssertEqual(subscriber.amount, subscription.amount)
            XCTAssertEqual(subscriber.billingCycle, subscription.billingCycle)
            XCTAssertEqual(subscriber.nextDueDate, subscription.nextDueDate)

            // AND the icon should be correct
            let icon = subscriber.category?.iconName ?? "repeat"
            XCTAssertEqual(subscriber.icon, icon)

            // AND the text should be correctly formatted
            let dateString = subscriber.formattedDateString(subscription.nextDueDate)
            XCTAssertEqual(subscriber.dateString, dateString)
        }

        // AND the view should have the correct spacing and padding
        XCTAssertEqual(result.spacing, 16)
        XCTAssertEqual(result.padding.horizontal, 16)

        // AND the view should have the correct background color
        XCTAssertEqual(result.backgroundColor, .regularMaterial)
        XCTAssertEqual(result.background.inset(cornerRadius: 12), Color.secondary.opacity(0.3))
    }

    // Test case for the categoryColor method
    func testCategoryColor() {
        let colors = [.blue, .green, .orange, .purple, .pink, .red]
        for index in 0..<colors.count {
            let color = DashboardSubscriptionsSection.categoryColor(for: index)
            XCTAssertEqual(color, colors[index])
        }
    }

    // Test case for the subscriptionIcon method
    func testSubscriptionIcon() {
        let subscription1 = Subscription(
            name: "Netflix", amount: 15.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 3)
        )
        let subscription2 = Subscription(
            name: "Spotify", amount: 9.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 7)
        )

        XCTAssertEqual(DashboardSubscriptionsSection.subscriptionIcon(subscription1), "tv")
        XCTAssertEqual(DashboardSubscriptionsSection.subscriptionIcon(subscription2), "music.note")
    }

    // Test case for the formattedDateString method
    func testFormattedDateString() {
        let date = Date().addingTimeInterval(86400 * 3)
        let dateString = DashboardSubscriptionsSection.formattedDateString(date)
        XCTAssertEqual(dateString, "Mar 19")
    }
}
