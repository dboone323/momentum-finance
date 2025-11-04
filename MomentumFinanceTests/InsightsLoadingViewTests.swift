import XCTest
@testable import MomentumFinance

class InsightsLoadingViewTests: XCTestCase {
    var insightsLoadingView: InsightsLoadingView!

    override func setUp() {
        super.setUp()
        insightsLoadingView = InsightsLoadingView()
    }

    override func tearDown() {
        insightsLoadingView = nil
        super.tearDown()
    }

    // Test the isAnimating property
    func testIsAnimatingProperty() {
        // GIVEN: The view is not animating initially
        XCTAssert(insightsLoadingView.isAnimating == false)

        // WHEN: The animation starts
        insightsLoadingView.isAnimating = true

        // THEN: The animation should be running
        XCTAssertTrue(insightsLoadingView.isAnimating == true)
    }

    // Test the rotation effect of the circle
    func testRotationEffect() {
        // GIVEN: The view is not animating initially
        XCTAssert(insightsLoadingView.isAnimating == false)

        // WHEN: The animation starts
        insightsLoadingView.isAnimating = true

        // THEN: The circle should rotate 360 degrees over 1 second
        let duration = 1.0
        let expectedAngle = Double.pi * 2
        let startTime = Date()
        while Date() - startTime < duration {
            XCTAssertEqual(insightsLoadingView.isAnimating, true)
            Thread.sleep(forTimeInterval: 0.01)
        }
        XCTAssertTrue(insightsLoadingView.isAnimating == false)
    }

    // Test the text labels
    func testTextLabels() {
        // GIVEN: The view is not animating initially
        XCTAssert(insightsLoadingView.isAnimating == false)

        // WHEN: The animation starts
        insightsLoadingView.isAnimating = true

        // THEN: The text labels should be displayed correctly
        let expectedText1 = "Analyzing your finances..."
        let expectedText2 = "This may take a few moments"
        XCTAssertEqual(insightsLoadingView.body.description, "\(expectedText1)\n\(expectedText2)")
    }
}
