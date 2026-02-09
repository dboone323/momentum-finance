import SwiftData
import XCTest
@testable import MomentumFinance

class FeaturesTests: XCTestCase {
    // Test the Dashboard namespace
    func testDashboardNamespace() {
        // GIVEN: A valid instance of Dashboard
        let dashboard = Features.Dashboard()

        // WHEN: The dashboard is accessed
        // THEN: It should be an instance of Dashboard
        XCTAssertTrue(dashboard is Features.Dashboard)
    }

    // Test the Transactions namespace
    func testTransactionsNamespace() {
        // GIVEN: A valid instance of Transactions
        let transactions = Features.Transactions()

        // WHEN: The transactions are accessed
        // THEN: It should be an instance of Transactions
        XCTAssertTrue(transactions is Features.Transactions)
    }

    // Test the Budgets namespace
    func testBudgetsNamespace() {
        // GIVEN: A valid instance of Budgets
        let budgets = Features.Budgets()

        // WHEN: The budgets are accessed
        // THEN: It should be an instance of Budgets
        XCTAssertTrue(budgets is Features.Budgets)
    }

    // Test the Subscriptions namespace
    func testSubscriptionsNamespace() {
        // GIVEN: A valid instance of Subscriptions
        let subscriptions = Features.Subscriptions()

        // WHEN: The subscriptions are accessed
        // THEN: It should be an instance of Subscriptions
        XCTAssertTrue(subscriptions is Features.Subscriptions)
    }

    // Test the GoalsAndReports namespace
    func testGoalsAndReportsNamespace() {
        // GIVEN: A valid instance of GoalsAndReports
        let goalsAndReports = Features.GoalsAndReports()

        // WHEN: The goals and reports are accessed
        // THEN: It should be an instance of GoalsAndReports
        XCTAssertTrue(goalsAndReports is Features.GoalsAndReports)
    }

    // Test the Theme namespace
    func testThemeNamespace() {
        // GIVEN: A valid instance of Theme
        let theme = Features.Theme()

        // WHEN: The theme is accessed
        // THEN: It should be an instance of Theme
        XCTAssertTrue(theme is Features.Theme)
    }

    // Test the GlobalSearch namespace
    func testGlobalSearchNamespace() {
        // GIVEN: A valid instance of GlobalSearch
        let globalSearch = Features.GlobalSearch()

        // WHEN: The global search is accessed
        // THEN: It should be an instance of GlobalSearch
        XCTAssertTrue(globalSearch is Features.GlobalSearch)
    }

    // Test the GlobalSearchView
    func testGlobalSearchView() {
        // GIVEN: A valid instance of GlobalSearchView
        let view = GlobalSearchView()

        // WHEN: The view is accessed
        // THEN: It should be an instance of GlobalSearchView
        XCTAssertTrue(view is GlobalSearchView)

        // GIVEN: Real data for testing
        let container = try! ModelContainer(
            for: FinancialAccount.self, FinancialTransaction.self
        )
        _searchEngine = StateObject(
            wrappedValue: SearchEngineService(modelContext: ModelContext(container))
        )

        // WHEN: The view is loaded
        // THEN: It should display the search bar and filter picker
        XCTAssertTrue(view.searchBar.isShowing)
        XCTAssertTrue(view.filterPicker.selected == .all)

        // GIVEN: A search query
        let searchText = "example"
        view.searchText = searchText

        // WHEN: The search is performed
        // THEN: It should update the search results
        XCTAssertEqual(view.searchResults.count, 1)
        XCTAssertEqual(view.searchResults[0].title, "Example Account")
    }
}
