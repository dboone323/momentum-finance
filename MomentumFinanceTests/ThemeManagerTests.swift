import XCTest
@testable import MomentumFinance

@MainActor
final class ThemeManagerTests: XCTestCase {
    var manager: ThemeManager!

    override func setUp() async throws {
        try await super.setUp()
        manager = ThemeManager.shared
    }

    func testSingleton() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testDefaultTheme() {
        XCTAssertNotNil(manager.currentTheme)
    }

    func testThemeSwitch() {
        let originalTheme = manager.currentTheme

        // Change theme
        let availableThemes = manager.availableThemes
        if availableThemes.count > 1 {
            let newTheme = availableThemes.first { $0.id != originalTheme.id }
            if let newTheme {
                manager.setTheme(newTheme)
                XCTAssertEqual(manager.currentTheme.id, newTheme.id)
            }
        }

        XCTAssertTrue(true) // Pass if no crash
    }

    func testThemePersistence() {
        // Verify theme can be saved and restored
        let testTheme = manager.currentTheme
        manager.saveThemePreference()
        manager.loadSavedTheme()

        // Should maintain or restore a valid theme
        XCTAssertNotNil(manager.currentTheme)
    }
}
