@testable import MomentumFinance
import XCTest

class SearchAndFilterSectionTests: XCTestCase {
    var viewModel: Features.Transactions.SearchAndFilterSection!

    // GIVEN: The view is presented with default values
    func testViewIsPresentedWithDefaultValues() {
        // WHEN: The view is displayed
        // THEN: The searchText should be empty and the selectedFilter should be "All"
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertTrue(viewModel.showingSearch)
    }

    // GIVEN: The user types in a search query
    func testUserTypesInSearchQuery() {
        // WHEN: The user types "Income" into the search bar
        viewModel.searchText = "Income"
        // THEN: The searchText should be "Income"
        XCTAssertEqual(viewModel.searchText, "Income")
    }

    // GIVEN: The user selects an expense filter
    func testUserSelectsExpenseFilter() {
        // WHEN: The user selects "Expense" from the picker
        viewModel.selectedFilter = .expense
        // THEN: The selectedFilter should be "Expense"
        XCTAssertEqual(viewModel.selectedFilter, .expense)
    }

    // GIVEN: The user toggles the search bar visibility
    func testUserTogglesSearchBarVisibility() {
        // WHEN: The user taps on the search bar
        viewModel.showingSearch.toggle()
        // THEN: The showingSearch should be true
        XCTAssertTrue(viewModel.showingSearch)
    }
}
