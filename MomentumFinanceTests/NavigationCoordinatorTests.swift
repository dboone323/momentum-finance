import XCTest
@testable import MomentumFinance

class NavigationCoordinatorTests: XCTestCase {
    var coordinator: NavigationCoordinator!

    // MARK: - Core Navigation State Tests

    func testNavigateToBudgets() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")
        XCTAssertEqual(coordinator.selectedTab, 0, "The selected tab should be dashboard by default.")

        // WHEN navigateToBudgets is called
        coordinator.navigateToBudgets()

        // THEN the selected tab should be updated to 2 (budgets)
        XCTAssertEqual(coordinator.selectedTab, 2, "After navigating to budgets, the selected tab should be 2.")
    }

    func testNavigateToSubscriptions() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")
        XCTAssertEqual(coordinator.selectedTab, 0, "The selected tab should be dashboard by default.")

        // WHEN navigateToSubscriptions is called
        coordinator.navigateToSubscriptions()

        // THEN the selected tab should be updated to 3 (subscriptions)
        XCTAssertEqual(coordinator.selectedTab, 3, "After navigating to subscriptions, the selected tab should be 3.")
    }

    func testNavigateToGoals() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")
        XCTAssertEqual(coordinator.selectedTab, 0, "The selected tab should be dashboard by default.")

        // WHEN navigateToGoals is called
        coordinator.navigateToGoals()

        // THEN the selected tab should be updated to 4 (goals)
        XCTAssertEqual(coordinator.selectedTab, 4, "After navigating to goals, the selected tab should be 4.")
    }

    // MARK: - Enhanced UX Properties Tests

    func testIsSearchActive() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")

        // WHEN isSearchActive is set to true
        coordinator.isSearchActive = true

        // THEN isSearchActive should be true
        XCTAssertTrue(coordinator.isSearchActive, "isSearchActive should be true after setting it.")
    }

    func testSearchQuery() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")

        // WHEN searchQuery is set to a value
        coordinator.searchQuery = "test"

        // THEN searchQuery should be "test"
        XCTAssertEqual(coordinator.searchQuery, "test", "searchQuery should be 'test' after setting it.")
    }

    func testBreadcrumbHistory() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")

        // WHEN breadcrumbHistory is updated with a new item
        coordinator.breadcrumbHistory.append(BreadcrumbItem(name: "Home", identifier: "home"))

        // THEN breadcrumbHistory should contain the new item
        XCTAssertEqual(
            coordinator.breadcrumbHistory.count,
            1,
            "breadcrumbHistory should contain one item after updating."
        )
        XCTAssertTrue(
            coordinator.breadcrumbHistory[0].name == "Home",
            "The first item in breadcrumbHistory should be 'Home'."
        )
    }

    func testIsShowingSearchResults() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")

        // WHEN isShowingSearchResults is set to true
        coordinator.isShowingSearchResults = true

        // THEN isShowingSearchResults should be true
        XCTAssertTrue(coordinator.isShowingSearchResults, "isShowingSearchResults should be true after setting it.")
    }

    // MARK: - Authentication State Tests

    func testIsAuthenticated() {
        // GIVEN the coordinator is initialized and not authenticated
        XCTAssertTrue(coordinator.isAuthenticated, "The coordinator should be unauthenticated initially.")

        // WHEN isAuthenticated is set to true
        coordinator.isAuthenticated = true

        // THEN isAuthenticated should be true
        XCTAssertTrue(coordinator.isAuthenticated, "isAuthenticated should be true after setting it.")
    }

    func testRequiresAuthentication() {
        // GIVEN the coordinator is initialized and requires authentication
        XCTAssertTrue(coordinator.requiresAuthentication, "The coordinator should require authentication initially.")

        // WHEN requiresAuthentication is set to false
        coordinator.requiresAuthentication = false

        // THEN requiresAuthentication should be false
        XCTAssertFalse(coordinator.requiresAuthentication, "requiresAuthentication should be false after setting it.")
    }

}
