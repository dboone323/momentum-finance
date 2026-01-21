@testable import MomentumFinance
import XCTest

class SearchEngineServiceTests: XCTestCase {
    var service: SearchEngineService!

    // Test searchAll method
    func testSearchAll() throws {
        // GIVEN
        let query = "example"
        let expectedResults = 50 // Assuming we have at least 50 transactions

        // WHEN
        let results = service.search(query: query, filter: .transactions)

        // THEN
        XCTAssertEqual(results.count, expectedResults)
    }

    // Test searchAccounts method
    func testSearchAccounts() throws {
        // GIVEN
        let query = "example"
        let expectedResults = 10 // Assuming we have at least 10 accounts

        // WHEN
        let results = service.search(query: query, filter: .accounts)

        // THEN
        XCTAssertEqual(results.count, expectedResults)
    }

    // Test searchTransactions method
    func testSearchTransactions() throws {
        // GIVEN
        let query = "example"
        let expectedResults = 50 // Assuming we have at least 50 transactions

        // WHEN
        let results = service.search(query: query, filter: .transactions)

        // THEN
        XCTAssertEqual(results.count, expectedResults)
    }

    // Test searchSubscriptions method
    func testSearchSubscriptions() throws {
        // GIVEN
        let query = "example"
        let expectedResults = 10 // Assuming we have at least 10 subscriptions

        // WHEN
        let results = service.search(query: query, filter: .subscriptions)

        // THEN
        XCTAssertEqual(results.count, expectedResults)
    }

    // Test searchBudgets method
    func testSearchBudgets() throws {
        // GIVEN
        let query = "example"
        let expectedResults = 10 // Assuming we have at least 10 budgets

        // WHEN
        let results = service.search(query: query, filter: .budgets)

        // THEN
        XCTAssertEqual(results.count, expectedResults)
    }

    private func calculateRelevance(query: String, text: String) -> Double {
        let normalizedQuery = query.lowercased()
        let normalizedText = text.lowercased()

        return Double(normalizedText.contains(normalizedQuery)) * 0.5 +
            Double(normalizedText.contains(normalizedQuery.replacingOccurrences(
                of: " ",
                with: ""
            ))) * 0.3
    }
}
