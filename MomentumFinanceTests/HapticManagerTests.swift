import XCTest
@testable import MomentumFinance

#if os(iOS)
    import UIKit
#endif

final class HapticManagerTests: XCTestCase {
    var manager: HapticManager!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        manager = HapticManager.shared
        manager.isEnabled = true
    }

    @MainActor
    func testSingleton() {
        let instance1 = HapticManager.shared
        let instance2 = HapticManager.shared
        XCTAssertTrue(instance1 === instance2, "HapticManager should be a singleton")
    }

    @MainActor
    func testHapticToggle() {
        manager.isEnabled = false
        XCTAssertFalse(manager.isEnabled)

        manager.isEnabled = true
        XCTAssertTrue(manager.isEnabled)
    }

    @MainActor
    func testImpactFeedbackExecution() {
        // These should not crash when disabled
        manager.isEnabled = false
        manager.lightImpact()
        manager.mediumImpact()
        manager.heavyImpact()

        // Re-enable
        manager.isEnabled = true
        manager.lightImpact()
        manager.mediumImpact()
        manager.heavyImpact()

        // Test passes if no crashes occur
        XCTAssertTrue(true)
    }

    @MainActor
    func testNotificationFeedback() {
        manager.success()
        manager.warning()
        manager.error()

        // Test passes if no crashes occur
        XCTAssertTrue(true)
    }

    @MainActor
    func testSelectionFeedback() {
        manager.selection()

        // Test passes if no crashes occur
        XCTAssertTrue(true)
    }

    @MainActor
    func testContextualFeedback() {
        manager.transactionFeedback(for: .income)
        manager.transactionFeedback(for: .expense)
        manager.transactionFeedback(for: .transfer)

        manager.budgetFeedback(isOverBudget: true)
        manager.budgetFeedback(isOverBudget: false)

        manager.deletion()
        manager.navigation()
        manager.refresh()

        // Test passes if no crashes occur
        XCTAssertTrue(true)
    }

    @MainActor
    func testAuthenticationFeedback() async {
        manager.authenticationSuccess()

        // Wait for delayed haptics
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        manager.authenticationFailure()

        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s

        XCTAssertTrue(true)
    }

    @MainActor
    func testGoalAchievementPattern() async {
        manager.goalAchievement()

        // Wait for the celebratory pattern to complete
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        XCTAssertTrue(true)
    }
}
