#if os(macOS)
import XCTest
@testable import MomentumFinance

class MacOSNavigationTypesTests: XCTestCase {
    // Test SidebarItem enum
    func testSidebarItems() {
        // GIVEN
        let expectedSidebarItems = [
            .dashboard,
            .transactions,
            .budgets,
            .subscriptions,
            .goalsAndReports,
        ]

        // WHEN
        let sidebarItems = SidebarItem.allCases

        // THEN
        XCTAssertEqual(sidebarItems.count, 5)
        for (index, item) in sidebarItems.enumerated() {
            XCTAssertEqual(item, expectedSidebarItems[index])
        }
    }

    // Test ListableItem struct
    func testListableItemIdentifiers() {
        // GIVEN
        let items = [
            ListableItem(id: "123", name: "Account 1", type: .account),
            ListableItem(id: nil, name: "Transaction 2", type: .transaction),
            ListableItem(id: "456", name: "Budget 3", type: .budget),
        ]

        // WHEN
        for item in items {
            let identifier = item.identifier

            // THEN
            XCTAssertEqual(identifier, "\(item.type)_\(item.id ?? "unknown")")
        }
    }

    // Test ListItemType enum
    func testListItemTypes() {
        // GIVEN
        let expectedListItemTypes = [
            .account,
            .transaction,
            .budget,
            .subscription,
            .goal,
            .report,
        ]

        // WHEN
        let listItemTypes = ListItemType.allCases

        // THEN
        XCTAssertEqual(listItemTypes.count, 6)
        for (index, item) in listItemTypes.enumerated() {
            XCTAssertEqual(item, expectedListItemTypes[index])
        }
    }

    // Test SidebarItem and ListableItem with real test data
    func testSidebarItemsWithRealData() {
        // GIVEN
        let sidebarItems = [
            .dashboard,
            .transactions,
            .budgets,
            .subscriptions,
            .goalsAndReports,
        ]

        // WHEN
        for item in sidebarItems {
            // THEN
            XCTAssertEqual(item, SidebarItem(rawValue: "Dashboard") ?? .unknown)
        }
    }

    func testListableItemIdentifiersWithRealData() {
        // GIVEN
        let items = [
            ListableItem(id: "123", name: "Account 1", type: .account),
            ListableItem(id: nil, name: "Transaction 2", type: .transaction),
            ListableItem(id: "456", name: "Budget 3", type: .budget),
        ]

        // WHEN
        for item in items {
            let identifier = item.identifier

            // THEN
            XCTAssertEqual(identifier, "\(item.type)_\(item.id ?? "unknown")")
        }
    }

    func testListItemTypesWithRealData() {
        // GIVEN
        let expectedListItemTypes = [
            .account,
            .transaction,
            .budget,
            .subscription,
            .goal,
            .report,
        ]

        // WHEN
        let listItemTypes = ListItemType.allCases

        // THEN
        XCTAssertEqual(listItemTypes.count, 6)
        for (index, item) in listItemTypes.enumerated() {
            XCTAssertEqual(item, ListItemType(rawValue: "Account") ?? .unknown)
        }
    }

    func testSidebarItemsWithRealDataAndNullId() {
        // GIVEN
        let sidebarItems = [
            .dashboard,
            .transactions,
            .budgets,
            .subscriptions,
            .goalsAndReports,
        ]

        // WHEN
        for item in sidebarItems {
            // THEN
            XCTAssertEqual(item, SidebarItem(rawValue: "Dashboard") ?? .unknown)
        }
    }

    func testListableItemIdentifiersWithRealDataAndNullId() {
        // GIVEN
        let items = [
            ListableItem(id: nil, name: "Transaction 2", type: .transaction),
            ListableItem(id: "456", name: "Budget 3", type: .budget),
        ]

        // WHEN
        for item in items {
            let identifier = item.identifier

            // THEN
            XCTAssertEqual(identifier, "\(item.type)_\(item.id ?? "unknown")")
        }
    }

    func testListItemTypesWithRealDataAndNullId() {
        // GIVEN
        let expectedListItemTypes = [
            .transaction,
            .budget,
            .subscription,
            .goal,
            .report,
        ]

        // WHEN
        let listItemTypes = ListItemType.allCases

        // THEN
        XCTAssertEqual(listItemTypes.count, 5)
        for (index, item) in listItemTypes.enumerated() {
            XCTAssertEqual(item, ListItemType(rawValue: "Transaction") ?? .unknown)
        }
    }

}

#endif
