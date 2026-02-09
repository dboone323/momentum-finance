import XCTest
@testable import MomentumFinance

#if os(macOS)
    final class KeyboardShortcutManagerTests: XCTestCase {
        var manager: KeyboardShortcutManager!

        override func setUp() {
            super.setUp()
            manager = KeyboardShortcutManager.shared
        }

        func testSingleton() {
            let instance1 = KeyboardShortcutManager.shared
            let instance2 = KeyboardShortcutManager.shared
            XCTAssertTrue(instance1 === instance2, "KeyboardShortcutManager should be a singleton")
        }

        func testNavigationShortcutsExist() {
            XCTAssertEqual(manager.dashboardShortcut.key, KeyEquivalent("1"))
            XCTAssertEqual(manager.transactionsShortcut.key, KeyEquivalent("2"))
            XCTAssertEqual(manager.budgetsShortcut.key, KeyEquivalent("3"))
            XCTAssertEqual(manager.subscriptionsShortcut.key, KeyEquivalent("4"))
            XCTAssertEqual(manager.goalsReportsShortcut.key, KeyEquivalent("5"))
        }

        func testActionShortcutsExist() {
            XCTAssertEqual(manager.newTransactionShortcut.key, KeyEquivalent("n"))
            XCTAssertEqual(manager.newBudgetShortcut.key, KeyEquivalent("b"))
            XCTAssertEqual(manager.newSubscriptionShortcut.key, KeyEquivalent("s"))
            XCTAssertEqual(manager.newGoalShortcut.key, KeyEquivalent("g"))
        }

        func testMenuCreation() {
            manager.registerGlobalShortcuts()
            XCTAssertNotNil(NSApp.mainMenu, "Main menu should be created")
            XCTAssertGreaterThan(NSApp.mainMenu?.items.count ?? 0, 0, "Main menu should have items")
        }

        func testNotificationFiring() {
            let expectation = XCTestExpectation(description: "Notification received")
            var receivedNotification = false

            let observer = NotificationCenter.default.addObserver(
                forName: Notification.Name("NewTransaction"),
                object: nil,
                queue: .main
            ) { _ in
                receivedNotification = true
                expectation.fulfill()
            }

            // Simulate menu action
            NSApplication.shared.newTransaction()

            wait(for: [expectation], timeout: 1.0)
            XCTAssertTrue(receivedNotification)

            NotificationCenter.default.removeObserver(observer)
        }
    }
#endif
