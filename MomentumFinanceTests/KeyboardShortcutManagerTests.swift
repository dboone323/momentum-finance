@testable import MomentumFinance
import XCTest

class KeyboardShortcutManagerTests: XCTestCase {
    var keyboardShortcutManager: KeyboardShortcutManager!

    // Test the registerGlobalShortcuts method
    func testRegisterGlobalShortcuts() {
        // Arrange
        let expectedMenu = NSMenu()

        // Act
        keyboardShortcutManager.registerGlobalShortcuts()

        // Assert
        XCTAssertEqual(NSApp.mainMenu, expectedMenu)
    }

    // Test the dashboardShortcut property
    func testDashboardShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("1", modifiers: [.command])

        // Act
        let shortcut = keyboardShortcutManager.dashboardShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "1")
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    // Test the transactionsShortcut property
    func testTransactionsShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("2", modifiers: [.command])

        // Act
        let shortcut = keyboardShortcutManager.transactionsShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "2")
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    // Test the budgetsShortcut property
    func testBudgetsShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("3", modifiers: [.command])

        // Act
        let shortcut = keyboardShortcutManager.budgetsShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "3")
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    // Test the subscriptionsShortcut property
    func testSubscriptionsShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("4", modifiers: [.command])

        // Act
        let shortcut = keyboardShortcutManager.subscriptionsShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "4")
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    // Test the goalsReportsShortcut property
    func testGoalsReportsShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("5", modifiers: [.command])

        // Act
        let shortcut = keyboardShortcutManager.goalsReportsShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "5")
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    // Test the newTransactionShortcut property
    func testNewTransactionShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("n", modifiers: [.command, .shift])

        // Act
        let shortcut = keyboardShortcutManager.newTransactionShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "n")
        XCTAssertEqual(shortcut.modifiers, [.command, .shift])
    }

    // Test the newBudgetShortcut property
    func testNewBudgetShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("b", modifiers: [.command, .shift])

        // Act
        let shortcut = keyboardShortcutManager.newBudgetShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "b")
        XCTAssertEqual(shortcut.modifiers, [.command, .shift])
    }

    // Test the newSubscriptionShortcut property
    func testNewSubscriptionShortcut() {
        // Arrange
        let expectedShortcut = KeyboardShortcut("s", modifiers: [.command, .shift])

        // Act
        let shortcut = keyboardShortcutManager.newSubscriptionShortcut

        // Assert
        XCTAssertEqual(shortcut.key, "s")
        XCTAssertEqual(shortcut.modifiers, [.command, .shift])
    }

}
