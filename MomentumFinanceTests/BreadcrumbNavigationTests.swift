@testable import MomentumFinance
import XCTest

class BreadcrumbNavigationTests: XCTestCase {
    var breadcrumbItems: [BreadcrumbItem]!
    var deepLinks: [DeepLink]!

    // Test BreadcrumbItem properties
    func testBreadcrumbItemTitle() {
        XCTAssertEqual(breadcrumbItems[0].title, "Dashboard")
    }

    func testBreadcrumbItemDestination() {
        XCTAssertNil(breadcrumbItems[0].destination)
    }

    func testBreadcrumbItemTimestamp() {
        let timestamp = breadcrumbItems[0].timestamp
        XCTAssertTrue(timestamp > Date())
    }

    // Test BreadcrumbItem hashable property
    func testBreadcrumbItemHashable() {
        XCTAssertEqual(breadcrumbItems[0].hashValue, breadcrumbItems[1].hashValue)
    }

    // Test DeepLink properties
    func testDeepLinkPath() {
        XCTAssertEqual(deepLinks[0].path, "/dashboard")
    }

    func testDeepLinkHashable() {
        XCTAssertEqual(deepLinks[0].hashValue, deepLinks[1].hashValue)
    }
}
