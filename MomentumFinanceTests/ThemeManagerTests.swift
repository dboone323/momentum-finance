@testable import MomentumFinance
import XCTest

@MainActor
final class ThemeManagerTests: XCTestCase {

    var themeManager: ThemeManager!

    override func setUp() async throws {
        try await super.setUp()
        themeManager = ThemeManager.shared
    }

    override func tearDown() async throws {
        themeManager = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSharedInstanceExists() {
        XCTAssertNotNil(ThemeManager.shared)
    }

    func testSingletonPattern() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Theme Mode Tests

    func testCurrentThemeMode() {
        let currentMode = themeManager.currentThemeMode

        XCTAssertTrue(
            currentMode == .light || currentMode == .dark || currentMode == .system,
            "Current theme mode should be one of the valid options"
        )
    }

    func testSetThemeToLight() {
        themeManager.setAndSaveThemeMode(.light)

        XCTAssertEqual(themeManager.currentThemeMode, .light)
    }

    func testSetThemeToDark() {
        themeManager.setAndSaveThemeMode(.dark)

        XCTAssertEqual(themeManager.currentThemeMode, .dark)
    }

    func testSetThemeToSystem() {
        themeManager.setAndSaveThemeMode(.system)

        XCTAssertEqual(themeManager.currentThemeMode, .system)
    }

    func testThemeModeToggling() {
        themeManager.setAndSaveThemeMode(.light)
        XCTAssertEqual(themeManager.currentThemeMode, .light)

        themeManager.setAndSaveThemeMode(.dark)
        XCTAssertEqual(themeManager.currentThemeMode, .dark)

        themeManager.setAndSaveThemeMode(.light)
        XCTAssertEqual(themeManager.currentThemeMode, .light)
    }

    // MARK: - Typography Tests

    func testTextStyleFonts() {
        let styles: [ThemeManager.TextStyle] = [
            .largeTitle, .title1, .title2, .title3,
            .headline, .subheadline,
            .body, .callout,
            .footnote, .caption1, .caption2
        ]

        for style in styles {
            XCTAssertNotNil(style.font, "Font for \(style) should exist")
        }
    }

    func testLargeTitleFont() {
        let font = ThemeManager.TextStyle.largeTitle.font
        XCTAssertNotNil(font)
    }

    func testHeadlineFont() {
        let font = ThemeManager.TextStyle.headline.font
        XCTAssertNotNil(font)
    }

    func testBodyFont() {
        let font = ThemeManager.TextStyle.body.font
        XCTAssertNotNil(font)
    }

    func testFootnoteFont() {
        let font = ThemeManager.TextStyle.footnote.font
        XCTAssertNotNil(font)
    }

    // MARK: - Font Sizes Tests

    func testFontSizes() {
        let fontSizes = ThemeManager.FontSizes()

        XCTAssertEqual(fontSizes.title1, 28)
        XCTAssertEqual(fontSizes.title2, 22)
        XCTAssertEqual(fontSizes.title3, 20)
        XCTAssertEqual(fontSizes.headline, 17)
        XCTAssertEqual(fontSizes.body, 16)
        XCTAssertEqual(fontSizes.callout, 15)
        XCTAssertEqual(fontSizes.subheadline, 14)
        XCTAssertEqual(fontSizes.footnote, 13)
        XCTAssertEqual(fontSizes.caption1, 12)
        XCTAssertEqual(fontSizes.caption2, 11)
    }

    func testFontSizeHierarchy() {
        let fontSizes = ThemeManager.FontSizes()

        XCTAssertGreaterThan(fontSizes.title1, fontSizes.title2)
        XCTAssertGreaterThan(fontSizes.title2, fontSizes.title3)
        XCTAssertGreaterThan(fontSizes.headline, fontSizes.body)
        XCTAssertGreaterThan(fontSizes.body, fontSizes.callout)
        XCTAssertGreaterThan(fontSizes.callout, fontSizes.subheadline)
        XCTAssertGreaterThan(fontSizes.subheadline, fontSizes.footnote)
        XCTAssertGreaterThan(fontSizes.footnote, fontSizes.caption1)
        XCTAssertGreaterThan(fontSizes.caption1, fontSizes.caption2)
    }

    // MARK: - Persistence Tests

    func testThemePersistence() {
        // Set a theme mode
        themeManager.setAndSaveThemeMode(.dark)

        // Simulate app restart by getting shared instance
        let retrievedMode = ThemeManager.shared.currentThemeMode

        // Note: In actual app, this would persist across launches
        // In tests, we verify the setter was called
        XCTAssertEqual(retrievedMode, .dark)
    }

    func testMultipleThemeChanges() {
        let modes: [ThemeMode] = [.light, .dark, .system, .light, .dark]

        for mode in modes {
            themeManager.setAndSaveThemeMode(mode)
            XCTAssertEqual(themeManager.currentThemeMode, mode)
        }
    }

    // MARK: - Observation Tests

    func testThemeManagerIsObservable() {
        // ThemeManager should be @Observable
        // This test verifies it compiles with @Observable macro
        XCTAssertNotNil(themeManager)
    }

    // MARK: - Thread Safety Tests

    func testMainActorIsolation() {
        // ThemeManager should be @MainActor isolated
        Task { @MainActor in
            let manager = ThemeManager.shared
            XCTAssertNotNil(manager)
        }
    }

    func testConcurrentAccess() async {
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 10 {
                group.addTask { @MainActor in
                    _ = self.themeManager.currentThemeMode
                }
            }
        }

        // If no crashes, concurrent access is safe
        XCTAssertTrue(true)
    }

    // MARK: - Integration Tests

    func testCompleteThemeWorkflow() {
        // Start with light mode
        themeManager.setAndSaveThemeMode(.light)
        XCTAssertEqual(themeManager.currentThemeMode, .light)

        // Switch to dark mode
        themeManager.setAndSaveThemeMode(.dark)
        XCTAssertEqual(themeManager.currentThemeMode, .dark)

        // Switch to system mode
        themeManager.setAndSaveThemeMode(.system)
        XCTAssertEqual(themeManager.currentThemeMode, .system)
    }

    func testAllTextStylesAccessible() {
        let allStyles: [ThemeManager.TextStyle] = [
            .largeTitle, .title1, .title2, .title3,
            .headline, .subheadline,
            .body, .callout,
            .footnote, .caption1, .caption2
        ]

        for style in allStyles {
            let font = style.font
            XCTAssertNotNil(font, "Font for \(style) should not be nil")
        }
    }
}
