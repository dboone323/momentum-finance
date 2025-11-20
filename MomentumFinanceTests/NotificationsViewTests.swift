@testable import MomentumFinance
import XCTest

class NotificationsViewTests: XCTestCase {
    var notificationsView: NotificationsView!

    // MARK: - Test LoadNotifications()

    func testLoadNotifications() async throws {
        // GIVEN: A mock notification manager that returns a list of scheduled notifications
        let mockNotificationManager = MockNotificationManager()
        mockNotificationManager.scheduledNotifications = [
            ScheduledNotification(title: "Alert 1", body: "Your budget is low!", date: Date(), identifier: "alert1"),
            ScheduledNotification(title: "Payment Due", body: "Pay your bill now!", date: Date().addingTimeInterval(3600), identifier: "paymentDue")
        ]

        // WHEN: The loadNotifications method is called
        await notificationsView.loadNotifications()

        // THEN: The pendingNotifications state should be updated with the mock notifications
        XCTAssertEqual(notificationsView.pendingNotifications, mockNotificationManager.scheduledNotifications)
    }

    // MARK: - Test Filter Notifications

    func testFilterNotifications() {
        // GIVEN: A list of scheduled notifications and a selected filter
        let mockNotifications = [
            ScheduledNotification(title: "Alert 1", body: "Your budget is low!", date: Date(), identifier: "alert1"),
            ScheduledNotification(title: "Payment Due", body: "Pay your bill now!", date: Date().addingTimeInterval(3600), identifier: "paymentDue")
        ]
        let selectedFilter = .all

        // WHEN: The filterNotifications method is called
        notificationsView.filterNotifications(selectedFilter)

        // THEN: The filteredNotifications state should be updated with the mock notifications
        XCTAssertEqual(notificationsView.filteredNotifications, mockNotifications)
    }

    // MARK: - Test Clear All Notifications

    func testClearAllNotifications() async throws {
        // GIVEN: A mock notification manager that returns a list of scheduled notifications
        let mockNotificationManager = MockNotificationManager()
        mockNotificationManager.scheduledNotifications = [
            ScheduledNotification(title: "Alert 1", body: "Your budget is low!", date: Date(), identifier: "alert1"),
            ScheduledNotification(title: "Payment Due", body: "Pay your bill now!", date: Date().addingTimeInterval(3600), identifier: "paymentDue")
        ]

        // WHEN: The clearAllNotifications method is called
        await notificationsView.clearAllNotifications()

        // THEN: The pendingNotifications state should be empty
        XCTAssertTrue(notificationsView.pendingNotifications.isEmpty)
    }

    // MARK: - Test Notification Row

    func testNotificationRow() {
        // GIVEN: A scheduled notification and a tap action
        let mockNotification = ScheduledNotification(title: "Alert 1", body: "Your budget is low!", date: Date(), identifier: "alert1")
        let onTap = { () in }
        let onDismiss = { () in }

        // WHEN: The NotificationRow view is created
        let notificationRow = NotificationRow(notification: mockNotification, onTap: onTap, onDismiss: onDismiss)

        // THEN: The notification title and body should be displayed correctly
        XCTAssertEqual(notificationRow.title, mockNotification.title)
        XCTAssertEqual(notificationRow.body, mockNotification.body)
    }

    // MARK: - Test Empty State View

    func testEmptyStateView() {
        // GIVEN: An empty list of scheduled notifications
        let mockNotifications = []

        // WHEN: The emptyStateView is created
        let emptyStateView = NotificationsView(filteredNotifications: mockNotifications)

        // THEN: The notification title and body should be displayed correctly
        XCTAssertEqual(emptyStateView.title, "No Notifications")
        XCTAssertEqual(emptyStateView.body, "You're all caught up! Notifications will appear here when you have budget alerts, upcoming payments, or goal milestones.")
    }
}
