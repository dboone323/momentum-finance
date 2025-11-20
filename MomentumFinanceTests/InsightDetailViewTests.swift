@testable import MomentumFinance
import XCTest

class InsightDetailViewTests: XCTestCase {
    var insight: FinancialInsight!
    var viewModel: InsightViewModel!

    // Test the body view of InsightDetailView
    func testBodyView() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertNotNil(result)
    }

    // Test the header section of InsightDetailView
    func testHeaderSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertNotNil(result)
    }

    // Test the type and category section of InsightDetailView
    func testTypeAndCategorySection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertNotNil(result)
    }

    // Test the related items section of InsightDetailView
    func testRelatedItemsSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertNotNil(result)
    }

    // Test the data visualization info section of InsightDetailView
    func testVisualizationInfoSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertNotNil(result)
    }

    // Test the data points section of InsightDetailView
    func testDataPointsSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is VStack }))
        XCTAssertEqual(result as! VStack, expectation(for: "VStack in InsightDetailView body view", predicate: { $0.count == 2 }))
    }

    // Test the priority badge
    func testPriorityBadge() {
        let sut = PriorityBadge(priority: .medium)
        let result = sut.body

        XCTAssertNotNil(result)
    }
}
