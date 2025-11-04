import XCTest
@testable import MomentumFinance

class NavigationTypesTests: XCTestCase {
    // Test setup method to ensure all dependencies are properly initialized
    override func setUp() {
        super.setUp()
        // Initialize any necessary dependencies or objects here
    }

    // Test teardown method to clean up after each test
    override func tearDown() {
        super.tearDown()
        // Clean up any resources used in the tests
    }

    // Test case for TransactionsDestination enum
    func testTransactionsDestinationEnum() {
        // GIVEN: A valid account ID
        let accountId = "12345"
        
        // WHEN: Creating a TransactionsDestination instance with the account ID
        let destination = TransactionsDestination.accountDetail(accountId)
        
        // THEN: The destination should be of type TransactionsDestination and have the correct value
        XCTAssertEqual(destination, .accountDetail(accountId))
    }

    // Test case for BudgetsDestination enum
    func testBudgetsDestinationEnum() {
        // GIVEN: A valid category ID
        let categoryId = "67890"
        
        // WHEN: Creating a BudgetsDestination instance with the category ID
        let destination = BudgetsDestination.categoryDetail(categoryId)
        
        // THEN: The destination should be of type BudgetsDestination and have the correct value
        XCTAssertEqual(destination, .categoryDetail(categoryId))
    }

    // Test case for SubscriptionsDestination enum
    func testSubscriptionsDestinationEnum() {
        // GIVEN: A valid subscription ID
        let subscriptionId = "54321"
        
        // WHEN: Creating a SubscriptionsDestination instance with the subscription ID
        let destination = SubscriptionsDestination.subscriptionDetail(subscriptionId)
        
        // THEN: The destination should be of type SubscriptionsDestination and have the correct value
        XCTAssertEqual(destination, .subscriptionDetail(subscriptionId))
    }

    // Test case for GoalsDestination enum
    func testGoalsDestinationEnum() {
        // GIVEN: A valid goal ID
        let goalId = "98765"
        
        // WHEN: Creating a GoalsDestination instance with the goal ID
        let destination = GoalsDestination.goalDetail(goalId)
        
        // THEN: The destination should be of type GoalsDestination and have the correct value
        XCTAssertEqual(destination, .goalDetail(goalId))
    }

    // Test case for NavigationContext struct
    func testNavigationContextStruct() {
        // GIVEN: A valid breadcrumb title, source module, and optional metadata
        let breadcrumbTitle = "Transactions"
        let sourceModule = "Account"
        let metadata = ["userId": "12345"]
        
        // WHEN: Creating a NavigationContext instance with the provided values
        let context = NavigationContext(breadcrumbTitle: breadcrumbTitle, sourceModule: sourceModule, metadata: metadata)
        
        // THEN: The context should be of type NavigationContext and have the correct values
        XCTAssertEqual(context.breadcrumbTitle, breadcrumbTitle)
        XCTAssertEqual(context.sourceModule, sourceModule)
        XCTAssertEqual(context.metadata, metadata)
    }

    // Test case for SearchResult enum
    func testSearchResultEnum() {
        // GIVEN: A valid category ID and transaction ID
        let categoryId = "12345"
        let transactionId = "67890"
        
        // WHEN: Creating a SearchResult instance with the provided values
        let result = SearchResult(categoryId: categoryId, transactionId: transactionId)
        
        // THEN: The result should be of type SearchResult and have the correct values
        XCTAssertEqual(result.categoryId, categoryId)
        XCTAssertEqual(result.transactionId, transactionId)
    }
}
