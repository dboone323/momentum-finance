import XCTest
@testable import MomentumFinance

class InsightsEmptyStateViewTests: XCTestCase {
    // Mocks for dependencies if needed

    override func setUp() {
        super.setUp()
        // Initialize any necessary objects or mocks here
    }

    override func tearDown() {
        super.tearDown()
        // Clean up any resources here
    }

    // Test case to check the appearance of the image and text
    func testInsightsEmptyStateViewAppearance() {
        let view = InsightsEmptyStateView()

        // Assert that the image is displayed correctly
        XCTAssertEqual(view.image.systemName, "lightbulb")
        XCTAssertEqual(view.image.font.size, 64)
        XCTAssertEqual(view.image.foregroundColor.opacity, 0.5)

        // Assert that the text is displayed correctly
        XCTAssertEqual(view.text1.font.size, 20)
        XCTAssertEqual(view.text1.font.weight, .semibold)
        XCTAssertEqual(view.text1.textColor.opacity, 0.5)

        XCTAssertEqual(view.text2.font.size, 16)
        XCTAssertEqual(view.text2.font.weight, .body)
        XCTAssertEqual(view.text2.textColor.opacity, 0.5)

        XCTAssertEqual(view.text3.font.size, 14)
        XCTAssertEqual(view.text3.font.weight, .subheadline)
        XCTAssertEqual(view.text3.textColor.opacity, 0.5)
    }

    // Test case to check the appearance of the tips section
    func testInsightsEmptyStateViewTipsSection() {
        let view = InsightsEmptyStateView()

        // Assert that the tips section is displayed correctly
        XCTAssertEqual(view.tipsLabel.font.size, 16)
        XCTAssertEqual(view.tipsLabel.font.weight, .semibold)

        XCTAssertEqual(view.tip1.label.text, "Add more transactions")
        XCTAssertEqual(view.tip2.label.text, "Set up budgets and track spending")
        XCTAssertEqual(view.tip3.label.text, "Add subscription tracking")

        XCTAssertEqual(view.tip1.icon.image.systemName, "checkmark.circle.fill")
        XCTAssertEqual(view.tip1.icon.image.font.size, 16)
        XCTAssertEqual(view.tip1.icon.image.foregroundColor.opacity, 0.5)

        XCTAssertEqual(view.tip2.icon.image.systemName, "checkmark.circle.fill")
        XCTAssertEqual(view.tip2.icon.image.font.size, 16)
        XCTAssertEqual(view.tip2.icon.image.foregroundColor.opacity, 0.5)

        XCTAssertEqual(view.tip3.icon.image.systemName, "checkmark.circle.fill")
        XCTAssertEqual(view.tip3.icon.image.font.size, 16)
        XCTAssertEqual(view.tip3.icon.image.foregroundColor.opacity, 0.5)
    }

    // Test case to check the appearance of the background and corner radius
    func testInsightsEmptyStateViewBackgroundAndCornerRadius() {
        let view = InsightsEmptyStateView()

        // Assert that the background color is set correctly
        XCTAssertEqual(view.background.color, Color.gray.opacity(0.1))

        // Assert that the corner radius is set correctly
        XCTAssertEqual(view.cornerRadius, 12)
    }

    // Test case to check the appearance of the padding
    func testInsightsEmptyStateViewPadding() {
        let view = InsightsEmptyStateView()

        // Assert that the horizontal padding is set correctly
        XCTAssertEqual(view.padding.horizontal, 16)

        // Assert that the vertical padding is set correctly
        XCTAssertEqual(view.padding.vertical, 20)
    }
}
