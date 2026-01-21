@testable import MomentumFinance
import XCTest

class SearchTypesTests: XCTestCase {
    // MARK: - Test Cases for SearchFilter enum

    func testSearchFilterCases() {
        let all = SearchFilter.all
        let accounts = SearchFilter.accounts
        let transactions = SearchFilter.transactions
        let subscriptions = SearchFilter.subscriptions
        let budgets = SearchFilter.budgets

        XCTAssertEqual(all.rawValue, "All")
        XCTAssertEqual(accounts.rawValue, "Accounts")
        XCTAssertEqual(transactions.rawValue, "Transactions")
        XCTAssertEqual(subscriptions.rawValue, "Subscriptions")
        XCTAssertEqual(budgets.rawValue, "Budgets")

        XCTAssertTrue(all == all)
        XCTAssertTrue(accounts != transactions)
    }

    func testSearchFilterHash() {
        let hashSet = Set<[String: Any]>()
        let all = SearchFilter.all
        let accounts = SearchFilter.accounts

        let hash1 = HashValue.hash(for: [all.rawValue, "All"])
        let hash2 = HashValue.hash(for: [accounts.rawValue, "Accounts"])

        XCTAssertTrue(hash1 == hash2)
    }

    // MARK: - Test Cases for SearchResult struct

    func testSearchResultInitialization() {
        let id = UUID().uuidString
        let title = "Test Title"
        let subtitle = "Test Subtitle"
        let type = SearchFilter.accounts
        let iconName = "account"
        let data = ["test": "data"]
        let relevanceScore = 0.8

        let result = SearchResult(
            id: id,
            title: title,
            subtitle: subtitle,
            type: type,
            iconName: iconName,
            data: data,
            relevanceScore: relevanceScore
        )

        XCTAssertEqual(result.id, id)
        XCTAssertEqual(result.title, title)
        XCTAssertEqual(result.subtitle, subtitle)
        XCTAssertEqual(result.type, type)
        XCTAssertEqual(result.iconName, iconName)
        XCTAssertEqual(result.data, data)
        XCTAssertEqual(result.relevanceScore, relevanceScore)
    }

    func testSearchResultHash() {
        let hashSet = Set<[String: Any]>()
        let id1 = UUID().uuidString
        let title1 = "Test Title"
        let subtitle1 = "Test Subtitle"
        let type1 = SearchFilter.accounts
        let iconName1 = "account"
        let data1 = ["test": "data"]
        let relevanceScore1 = 0.8

        let id2 = UUID().uuidString
        let title2 = "Test Title"
        let subtitle2 = "Test Subtitle"
        let type2 = SearchFilter.accounts
        let iconName2 = "account"
        let data2 = ["test": "data"]
        let relevanceScore2 = 0.8

        let result1 = SearchResult(
            id: id1,
            title: title1,
            subtitle: subtitle1,
            type: type1,
            iconName: iconName1,
            data: data1,
            relevanceScore: relevanceScore1
        )

        let result2 = SearchResult(
            id: id2,
            title: title2,
            subtitle: subtitle2,
            type: type2,
            iconName: iconName2,
            data: data2,
            relevanceScore: relevanceScore2
        )

        XCTAssertTrue(hashSet.contains([result1.id, "Test Title"]))
        XCTAssertTrue(hashSet.contains([result2.id, "Test Title"]))
    }

    // MARK: - Test Cases for SearchConfiguration struct

    func testSearchConfigurationDefaults() {
        let debounceDelay = SearchConfiguration.searchDebounceDelay
        let maxResults = SearchConfiguration.maxResults
        let minQueryLength = SearchConfiguration.minQueryLength

        XCTAssertEqual(debounceDelay, 0.3)
        XCTAssertEqual(maxResults, 50)
        XCTAssertEqual(minQueryLength, 2)
    }

    // MARK: - Test Cases for ViewModels (if applicable)

    func testViewModelInitialization() {
        // Assuming ViewModel has a constructor that takes parameters
        let viewModel = YourViewModel(
            searchDebounceDelay: SearchConfiguration.searchDebounceDelay,
            maxResults: SearchConfiguration.maxResults,
            minQueryLength: SearchConfiguration.minQueryLength
        )

        XCTAssertEqual(viewModel.searchDebounceDelay, SearchConfiguration.searchDebounceDelay)
        XCTAssertEqual(viewModel.maxResults, SearchConfiguration.maxResults)
        XCTAssertEqual(viewModel.minQueryLength, SearchConfiguration.minQueryLength)
    }
}
