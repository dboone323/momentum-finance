import XCTest
@testable import MomentumFinance

class BreadcrumbNavigationTests: XCTestCase {
    var breadcrumbItems: [BreadcrumbItem]!
    var deepLinks: [DeepLink]!

    override func setUp() {
        super.setUp()
        breadcrumbItems = [
            BreadcrumbItem(title: "Dashboard", destination: nil),
            BreadcrumbItem(title: "Transactions", destination: nil),
            BreadcrumbItem(title: "Budgets", destination: nil),
            BreadcrumbItem(title: "Subscriptions", destination: nil),
            BreadcrumbItem(title: "Goals", destination: nil),
            BreadcrumbItem(title: "Settings", destination: nil)
        ]
        deepLinks = [
            DeepLink.dashboard,
            DeepLink.transactions,
            DeepLink.budgets,
            DeepLink.subscriptions,
            DeepLink.goals,
            DeepLink.settings,
            DeepLink.search(query: "test"),
            DeepLink.transaction(id: UUID()),
            DeepLink.account(id: UUID()),
            DeepLink.subscription(id: UUID()),
            DeepLink.budget(id: UUID()),
            DeepLink.goal(id: UUID())
        ]
    }

    override func tearDown() {
        super.tearDown()
    }

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
