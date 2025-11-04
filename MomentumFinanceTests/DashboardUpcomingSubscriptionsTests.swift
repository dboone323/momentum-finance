import XCTest
@testable import MomentumFinance

class DashboardUpcomingSubscriptionsTests: XCTestCase {
    var subscriptions: [Subscription]!
    var colorTheme: ColorTheme!
    var themeComponents: ThemeComponents!
    var onSubscriptionTap: (Subscription) -> Void!
    var onViewAllTap: () -> Void!

    override func setUp() {
        super.setUp()
        
        // Initialize test data
        subscriptions = [
            Subscription(id: 1, name: "Monthly Subscription", icon: "bell", amount: 50.0),
            Subscription(id: 2, name: "Quarterly Subscription", icon: "bell", amount: 100.0),
            Subscription(id: 3, name: "Annual Subscription", icon: "bell", amount: 200.0)
        ]
        
        colorTheme = ColorTheme(categoryColors: [UIColor.blue, UIColor.green, UIColor.red])
        themeComponents = ThemeComponents()
        onSubscriptionTap = { subscription in print("Subscription tapped: \(subscription.name)") }
        onViewAllTap = {}
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test the formattedDateString method
    func testFormattedDateString() {
        let date = Date()
        XCTAssertEqual(DashboardUpcomingSubscriptions().formattedDateString(date), "Aug 19")
    }

    // Test the body of DashboardUpcomingSubscriptions view
    func testBody() {
        let viewModel = Dashboard.UpcomingSubscriptions(subscriptions: subscriptions, colorTheme: colorTheme, themeComponents: themeComponents, onSubscriptionTap: onSubscriptionTap, onViewAllTap: onViewAllTap)
        
        // GIVEN: Subscriptions are present
        XCTAssertEqual(viewModel.subscriptions.count, 3)

        // WHEN: User taps a subscription
        let subscription = viewModel.subscriptions[0]
        viewModel.onSubscriptionTap(subscription)
        
        // THEN: Subscription tap action is called
        XCTAssertTrue(onSubscriptionTap.calledOnce)
    }

    // Test the body of DashboardUpcomingSubscriptions view when no subscriptions are present
    func testBodyNoSubscriptions() {
        let viewModel = Dashboard.UpcomingSubscriptions(subscriptions: [], colorTheme: colorTheme, themeComponents: themeComponents, onSubscriptionTap: onSubscriptionTap, onViewAllTap: onViewAllTap)
        
        // GIVEN: No subscriptions are present
        XCTAssertEqual(viewModel.subscriptions.count, 0)

        // WHEN: User taps a subscription (should not trigger any action)
        let subscription = viewModel.subscriptions[0]
        viewModel.onSubscriptionTap(subscription)
        
        // THEN: Subscription tap action is not called
        XCTAssertTrue(onSubscriptionTap.calledOnce)
    }

    // Test the body of DashboardUpcomingSubscriptions view when there are more than 3 subscriptions
    func testBodyMoreThanThreeSubscriptions() {
        let viewModel = Dashboard.UpcomingSubscriptions(subscriptions: subscriptions, colorTheme: colorTheme, themeComponents: themeComponents, onSubscriptionTap: onSubscriptionTap, onViewAllTap: onViewAllTap)
        
        // GIVEN: More than 3 subscriptions are present
        XCTAssertEqual(viewModel.subscriptions.count, 4)

        // WHEN: User taps a subscription (should trigger the "View All" button)
        let subscription = viewModel.subscriptions[0]
        viewModel.onSubscriptionTap(subscription)
        
        // THEN: View all button is tapped
        XCTAssertTrue(onViewAllTap.calledOnce)
    }
}
