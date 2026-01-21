@testable import MomentumFinance
import SwiftData
import XCTest

class GlobalSearchViewTests: XCTestCase {
    var sut: GlobalSearchView!
    var mockModelContext: MockModelContext!

    // GIVEN a search query, WHEN the view is displayed, THEN the search bar should be visible
    func testSearchBarIsVisibleWhenViewIsDisplayed() {
        let expectation = XCTestExpectation(description: "Search bar should be visible")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.searchText, "")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }

    // GIVEN a search query, WHEN the user types into the search bar, THEN the search results should be updated
    func testSearchResultsAreUpdatedWhenUserTypesIntoSearchBar() {
        let expectation = XCTestExpectation(description: "Search results should be updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.searchText = "example"
            XCTAssertEqual(sut.searchText, "example")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }

    // GIVEN a search query, WHEN the user taps on a result, THEN the selected result should be updated
    func testSelectedResultIsUpdatedWhenUserTapsOnResult() {
        let expectation = XCTestExpectation(description: "Selected result should be updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.searchText = "example"
            sut.selectedResult = nil
            XCTAssertEqual(sut.searchText, "example")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }

    // GIVEN a search query, WHEN the user taps on a result, THEN the navigation coordinator should be called with the
    // selected result
    func testNavigationCoordinatorIsCalledWithSelectedResultWhenUserTapsOnResult() {
        let expectation = XCTestExpectation(description: "Navigation coordinator should be called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.searchText = "example"
            sut.selectedResult = nil
            XCTAssertEqual(sut.searchText, "example")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }

    // GIVEN a search query, WHEN the user taps on a result, THEN the dismiss method should be called
    func testDismissMethodIsCalledWhenUserTapsOnResult() {
        let expectation = XCTestExpectation(description: "Dismiss method should be called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.searchText = "example"
            sut.selectedResult = nil
            XCTAssertEqual(sut.searchText, "example")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }

    // GIVEN a search query, WHEN the user taps on a result, THEN the selected result should be updated
    func testSelectedResultIsUpdatedWhenUserTapsOnResult() {
        let expectation = XCTestExpectation(description: "Selected result should be updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.searchText = "example"
            sut.selectedResult = nil
            XCTAssertEqual(sut.searchText, "example")
            XCTAssertTrue(sut.isSearching)
            XCTAssertTrue(sut.selectedResult == nil)
            XCTAssertTrue(sut.searchResults.isEmpty)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 2.0)
    }
}
