@testable import MomentumFinance
import XCTest

class NotificationCenterViewTests: XCTestCase {
    var notificationManager: NotificationManager!
    var mockNotificationCenter: UNUserNotificationCenter!

    // Test that the view loads notifications correctly
    func testLoadNotifications() async throws {
        // Arrange
        let expectedNotifications = [
            ScheduledNotification(id: "1", title: "Monthly Income Alert", scheduledDate: Date()),
            ScheduledNotification(id: "2", title: "Emergency Fund Alert", scheduledDate: Date().addingTimeInterval(3600))
        ]

        // Act
        await notificationManager.loadNotifications()

        // Assert
        XCTAssertEqual(notificationManager.pendingNotifications.count, expectedNotifications.count)
        for i in 0 ..< expectedNotifications.count {
            XCTAssertEqual(notificationManager.pendingNotifications[i].id, expectedNotifications[i].id)
            XCTAssertEqual(notificationManager.pendingNotifications[i].title, expectedNotifications[i].title)
            XCTAssertEqual(notificationManager.pendingNotifications[i].scheduledDate, expectedNotifications[i].scheduledDate)
        }
    }

    // Test that the view displays notifications correctly
    func testNotificationsList() throws {
        // Arrange
        let expectedNotifications = [
            ScheduledNotification(id: "1", title: "Monthly Income Alert", scheduledDate: Date()),
            ScheduledNotification(id: "2", title: "Emergency Fund Alert", scheduledDate: Date().addingTimeInterval(3600))
        ]

        notificationManager.pendingNotifications = expectedNotifications

        // Act
        let view = NotificationCenterView(notificationManager: notificationManager)

        // Assert
        XCTAssertEqual(view.notificationsList.count, expectedNotifications.count)
        for i in 0 ..< expectedNotifications.count {
            XCTAssertEqual(view.notificationsList[i].notification.id, expectedNotifications[i].id)
            XCTAssertEqual(view.notificationsList[i].notification.title, expectedNotifications[i].title)
            XCTAssertEqual(view.notificationsList[i].notification.scheduledDate, expectedNotifications[i].scheduledDate)
        }
    }

    // Test that the view dismisses notifications correctly
    func testDismissNotification() throws {
        // Arrange
        let notification = ScheduledNotification(id: "1", title: "Monthly Income Alert", scheduledDate: Date())
        notificationManager.pendingNotifications.append(notification)

        // Act
        notificationManager.dismissNotification(notification)

        // Assert
        XCTAssertEqual(notificationManager.pendingNotifications.count, 0)
        XCTAssertEqual(mockNotificationCenter.getPendingNotificationRequests(withIdentifiers: ["1"]).count, 0)
    }

    // Test that the view handles empty notifications correctly
    func testEmptyNotificationsView() throws {
        // Arrange
        notificationManager.pendingNotifications = []

        // Act
        let view = NotificationCenterView(notificationManager: notificationManager)

        // Assert
        XCTAssertEqual(view.notificationsList.count, 0)
        XCTAssertEqual(view.emptyNotificationsView.title, "No Notifications")
        XCTAssertEqual(view.emptyNotificationsView.description, "You're all caught up! Any important financial alerts will appear here.")
    }
}
