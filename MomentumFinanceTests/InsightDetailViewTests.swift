import XCTest
@testable import MomentumFinance

class InsightDetailViewTests: XCTestCase {
    var insight: FinancialInsight!
    var viewModel: InsightViewModel!

    override func setUp() {
        super.setUp()
        insight = FinancialInsight(title: "Test Insight", description: "This is a test insight.", priority: .medium, relatedAccountId: "12345", relatedTransactionId: "67890", relatedCategoryId: "abcde", relatedBudgetId: "fghij", visualizationType: .barChart, data: ["key1": 10.5, "key2": 20.7])
        viewModel = InsightViewModel(insight: insight)
    }

    override func tearDown() {
        super.tearDown()
        insight = nil
        viewModel = nil
    }

    // Test the body view of InsightDetailView
    func testBodyView() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is ScrollView }))
        XCTAssertEqual(result as! ScrollView, expectation(for: "ScrollView in InsightDetailView body view", predicate: { $0.contentSize.width > 0 && $0.contentSize.height > 0 }))
    }

    // Test the header section of InsightDetailView
    func testHeaderSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is VStack }))
        XCTAssertEqual(result as! VStack, expectation(for: "VStack in InsightDetailView body view", predicate: { $0.count == 2 }))
    }

    // Test the type and category section of InsightDetailView
    func testTypeAndCategorySection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is HStack }))
        XCTAssertEqual(result as! HStack, expectation(for: "HStack in InsightDetailView body view", predicate: { $0.count == 2 }))
    }

    // Test the related items section of InsightDetailView
    func testRelatedItemsSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is VStack }))
        XCTAssertEqual(result as! VStack, expectation(for: "VStack in InsightDetailView body view", predicate: { $0.count == 2 }))
    }

    // Test the data visualization info section of InsightDetailView
    func testVisualizationInfoSection() {
        let sut = InsightDetailView(insight: insight)
        let result = sut.body

        XCTAssertEqual(result, expectation(for: "InsightDetailView body view", predicate: { $0 is VStack }))
        XCTAssertEqual(result as! VStack, expectation(for: "VStack in InsightDetailView body view", predicate: { $0.count == 2 }))
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

        XCTAssertEqual(result, expectation(for: "PriorityBadge view", predicate: { $0 is Text }))
        XCTAssertEqual(result as! Text, expectation(for: "Text in PriorityBadge view", predicate: { $0 == "Medium" }))
    }
}
