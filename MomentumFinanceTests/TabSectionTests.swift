@testable import MomentumFinance
import XCTest

class TabSectionTests: XCTestCase {
    // Test setup method to ensure all dependencies are properly initialized

    // Test teardown method to clean up after each test

    // Test case for title property of AppTabSection enum
    func testTitleProperty() {
        // GIVEN - An instance of AppTabSection
        let tabSection = AppTabSection.dashboard

        // WHEN - Accessing the title property
        let expectedTitle = "Dashboard"

        // THEN - Assert that the title matches the expected value
        XCTAssertEqual(tabSection.title, expectedTitle)
    }

    // Test case for title property with different values
    func testTitlePropertyWithDifferentValues() {
        // GIVEN - An instance of AppTabSection
        let tabSection = AppTabSection.transactions

        // WHEN - Accessing the title property
        let expectedTitle = "Transactions"

        // THEN - Assert that the title matches the expected value
        XCTAssertEqual(tabSection.title, expectedTitle)
    }

    // Test case for title property with default value
    func testTitlePropertyWithDefaultValue() {
        // GIVEN - An instance of AppTabSection with a default value
        let tabSection = AppTabSection.budgets

        // WHEN - Accessing the title property
        let expectedTitle = "Budgets"

        // THEN - Assert that the title matches the expected value
        XCTAssertEqual(tabSection.title, expectedTitle)
    }

    // Test case for title property with invalid value
    func testTitlePropertyWithInvalidValue() {
        // GIVEN - An instance of AppTabSection with an invalid value
        let tabSection = AppTabSection.unknown

        // WHEN - Accessing the title property
        let expectedTitle = "Unknown"

        // THEN - Assert that the title matches the expected value
        XCTAssertEqual(tabSection.title, expectedTitle)
    }
}
