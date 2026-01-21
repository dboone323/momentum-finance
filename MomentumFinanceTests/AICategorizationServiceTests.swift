@testable import MomentumFinance
import XCTest

final class AICategorizationServiceTests: XCTestCase {
    // Mock categories for testing
    let food = ExpenseCategory(name: "Food & Dining", iconName: "fork.knife")
    let transport = ExpenseCategory(name: "Transportation", iconName: "car")
    let utilities = ExpenseCategory(name: "Utilities", iconName: "bolt")

    var allCategories: [ExpenseCategory]!

    override func setUp() {
        super.setUp()
        allCategories = [food, transport, utilities]
    }

    func testPredictCategory_KeywordMatch() {
        // Direct keyword matches
        XCTAssertEqual(AICategorizationService.predictCategory(for: "Starbucks Coffee", categories: allCategories), food)
        XCTAssertEqual(AICategorizationService.predictCategory(for: "Uber Trip", categories: allCategories), transport)
        XCTAssertEqual(AICategorizationService.predictCategory(for: "Comcast Bill", categories: allCategories), utilities)
    }

    func testPredictCategory_CaseInsensitive() {
        XCTAssertEqual(AICategorizationService.predictCategory(for: "starbucks", categories: allCategories), food)
        XCTAssertEqual(AICategorizationService.predictCategory(for: "UBER", categories: allCategories), transport)
    }

    func testPredictCategory_CategoryNameMatch() {
        // Fallback to name heuristic
        XCTAssertEqual(AICategorizationService.predictCategory(for: "My Food expense", categories: allCategories), food)
        XCTAssertEqual(AICategorizationService.predictCategory(for: "Utilities payment", categories: allCategories), utilities)
    }

    func testPredictCategory_NoMatch() {
        XCTAssertNil(AICategorizationService.predictCategory(for: "Random Transaction", categories: allCategories))
    }

    func testPredictCategory_PartialMatch() {
        // "Burgers" should match "burger" keyword
        XCTAssertEqual(AICategorizationService.predictCategory(for: "Joe's Burgers", categories: allCategories), food)
    }
}
