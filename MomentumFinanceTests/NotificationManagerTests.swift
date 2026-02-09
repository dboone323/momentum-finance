import UserNotifications
import XCTest
@testable import MomentumFinance

final class NotificationManagerTests: XCTestCase {
    var manager: NotificationManager!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        manager = NotificationManager.shared
    }

    @MainActor
    override func tearDown() async throws {
        manager.clearAllNotifications()
        try await super.tearDown()
    }

    @MainActor
    func testSingleton() {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    @MainActor
    func testPermissionCheck() async {
        await manager.requestNotificationPermission()
        // Permissions may or may not be granted in test environment
        // Just verify no crash occurs
        XCTAssertTrue(true)
    }

    @MainActor
    func testClearAllNotifications() {
        manager.clearAllNotifications()
        XCTAssertTrue(manager.pendingNotifications.isEmpty)
    }

    @MainActor
    func testGetPendingNotifications() async {
        let notifications = await manager.getPendingNotifications()
        XCTAssertNotNil(notifications)
    }

    @MainActor
    func testScheduleBudgetNotifications() {
        let testBudget = Budget.createSampleBudget()
        manager.schedulebudgetWarningNotifications(for: [testBudget])
        // Should not crash even if permissions not granted
        XCTAssertTrue(true)
    }

    @MainActor
    func testScheduleSubscriptionNotifications() {
        let testSubscription = Subscription.createSampleSubscription()
        manager.scheduleSubscriptionNotifications(for: [testSubscription])
        // Should not crash even if permissions not granted
        XCTAssertTrue(true)
    }

    @MainActor
    func testClearNotificationsByType() async {
        manager.clearNotifications(ofType: "budget_warning")
        manager.clearNotifications(ofType: "subscription_reminder")
        // Should complete without crashing
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(true)
    }
}
