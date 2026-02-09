#if os(macOS)
    import SwiftData
    import XCTest
    @testable import MomentumFinance

    class MacOSUIIntegrationTests: XCTestCase {
        var modelContext: ModelContext!
        var navigationCoordinator: NavigationCoordinator!

        // Test navigateToDetail method
        func testNavigateToDetail() {
            // Create a sample ListableItem for testing
            let sampleListItem = ListableItem(type: .account, id: "12345")

            // Call the navigateToDetail method with the sample item
            navigationCoordinator.navigateToDetail(item: sampleListItem)

            // Assert that the selectedListItem is set correctly
            XCTAssertEqual(navigationCoordinator.selectedListItem, sampleListItem)

            // Assert that the appropriate navigation path is updated
            XCTAssertEqual(navigationCoordinator.transactionsNavPath, [TransactionsDestination.accountDetail(id)])
        }

        // Test clearDetailSelection method
        func testClearDetailSelection() {
            // Set a sample ListableItem for testing
            let sampleListItem = ListableItem(type: .account, id: "12345")

            // Call the navigateToDetail method with the sample item
            navigationCoordinator.navigateToDetail(item: sampleListItem)

            // Assert that the selectedListItem is set correctly
            XCTAssertEqual(navigationCoordinator.selectedListItem, sampleListItem)

            // Clear the detail selection
            navigationCoordinator.clearDetailSelection()

            // Assert that the selectedListItem is cleared
            XCTAssertNil(navigationCoordinator.selectedListItem)
        }

        // Test navigateToDetail with a transaction item
        func testNavigateToTransaction() {
            // Create a sample ListableItem for testing
            let sampleListItem = ListableItem(type: .transaction, id: "67890")

            // Call the navigateToDetail method with the sample item
            navigationCoordinator.navigateToDetail(item: sampleListItem)

            // Assert that the selectedListItem is set correctly
            XCTAssertEqual(navigationCoordinator.selectedListItem, sampleListItem)

            // Assert that the appropriate navigation path is updated
            XCTAssertEqual(navigationCoordinator.transactionsNavPath, [TransactionsDestination.transactionDetail(id)])
        }

        // Test navigateToDetail with a budget item
        func testNavigateToBudget() {
            // Create a sample ListableItem for testing
            let sampleListItem = ListableItem(type: .budget, id: "54321")

            // Call the navigateToDetail method with the sample item
            navigationCoordinator.navigateToDetail(item: sampleListItem)

            // Assert that the selectedListItem is set correctly
            XCTAssertEqual(navigationCoordinator.selectedListItem, sampleListItem)

            // Assert that the appropriate navigation path is updated
            XCTAssertEqual(navigationCoordinator.budgetsNavPath, [BudgetsDestination.categoryDetail(id)])
        }

        // Test navigateToDetail with a subscription item
        func testNavigateToSubscription() {
            // Create a sample ListableItem for testing
            let sampleListItem = ListableItem(type: .subscription, id: "98765")

            // Call the navigateToDetail method with the sample item
            navigationCoordinator.navigateToDetail(item: sampleListItem)

            // Assert that the selectedListItem is set correctly
            XCTAssertEqual(navigationCoordinator.selectedListItem, sampleListItem)

            // Assert that the appropriate navigation path is updated
            XCTAssertEqual(
                navigationCoordinator.subscriptionsNavPath,
                [SubscriptionsDestination.subscriptionDetail(id)]
            )
        }
    }

#endif
