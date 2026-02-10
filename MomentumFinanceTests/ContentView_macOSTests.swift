import XCTest
@testable import MomentumFinance

class ContentViewMacOSTests: XCTestCase {
    var contentView: ContentView!

    /// macOS-specific view modifiers and optimizations
    func test_macOSOptimizations() {
        let frameModifier = contentView.macOSOptimizations

        XCTAssertEqual(frameModifier.minWidth, 800)
        XCTAssertEqual(frameModifier.minHeight, 600)
        XCTAssertEqual(frameModifier.preferredColorScheme, .automatic)
        XCTAssertEqual(frameModifier.tint, .blue)
    }

    /// macOS-specific UI components and helpers
    func test_macOSSpecificViews() {
        let configureWindow = macOSSpecificViews.configureWindow
        let configureToolbar = macOSSpecificViews.configureToolbar

        // Test window configuration
        let window = NSApp.mainWindow!
        XCTAssertEqual(window.frame.width, 800)
        XCTAssertEqual(window.frame.height, 600)

        // Test toolbar configuration
        let toolbar = configureToolbar()
        XCTAssertTrue(!toolbar.items.isEmpty)
    }

    /// macOS-specific view extensions
    func test_macOSSheetPresentation() {
        let sheetPresentation = contentView.macOSSheetPresentation()

        XCTAssertEqual(sheetPresentation.frame.width, 600)
        XCTAssertEqual(sheetPresentation.frame.height, 400)
    }

    /// Settings view for macOS
    func test_SettingsView() {
        let settingsView = SettingsView(
            defaultCurrency: .defaultCurrency,
            enableNotifications: .enableNotifications,
            autoBackup: .autoBackup
        )

        // Test tab items
        XCTAssertEqual(settingsView.tabItems.count, 3)

        // Test general settings view
        let generalSettingsView = GeneralSettingsView(
            defaultCurrency: .defaultCurrency,
            enableNotifications: .enableNotifications,
            autoBackup: .autoBackup
        )

        // Test data settings view
        let dataSettingsView = DataSettingsView()

        // Test advanced settings view
        let advancedSettingsView = AdvancedSettingsView()
    }
}
