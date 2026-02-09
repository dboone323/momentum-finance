import SwiftData
import XCTest
@testable import MomentumFinance

final class RootSearchEngineServiceTests: XCTestCase {
    var modelContext: ModelContext!
    var service: SearchEngineService!

    override func setUp() {
        super.setUp()

        // Create in-memory model container
        let schema = Schema([
            FinancialAccount.self,
            FinancialTransaction.self,
            Budget.self,
            Subscription.self,
            ExpenseCategory.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        service = SearchEngineService(modelContext: modelContext)
    }

    override func tearDown() {
        modelContext = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(service)
    }

    func testSetModelContext() {
        let newService = SearchEngineService()
        newService.setModelContext(modelContext)

        // Should be able to perform search after setting context
        let results = newService.search(query: "test", filter: .all)
        XCTAssertNotNil(results)
    }

    // MARK: - Empty Query Tests

    func testSearchWithEmptyQuery() {
        let results = service.search(query: "", filter: .all)
        XCTAssertEqual(results.count, 0)
    }

    func testSearchWithWhitespaceQuery() {
        let results = service.search(query: "   ", filter: .all)
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Account Search Tests

    func testSearchAccounts() {
        // Given: Test accounts
        let checking = FinancialAccount(name: "Checking Account", balance: 1000, accountType: .checking)
        let savings = FinancialAccount(name: "Savings Account", balance: 5000, accountType: .savings)
        modelContext.insert(checking)
        modelContext.insert(savings)

        // When: Searching for "checking"
        let results = service.search(query: "checking", filter: .accounts)

        // Then: Should find checking account
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Checking Account")
        XCTAssertEqual(results.first?.type, .account)
    }

    func testSearchAccountsCaseInsensitive() {
        let account = FinancialAccount(name: "Checking Account", balance: 1000, accountType: .checking)
        modelContext.insert(account)

        let results = service.search(query: "CHECKING", filter: .accounts)

        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Transaction Search Tests

    func testSearchTransactions() {
        // Given: Test account and transactions
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        let tx1 = FinancialTransaction(
            title: "Groceries at Whole Foods",
            amount: -50,
            date: Date(),
            transactionType: .expense
        )
        tx1.account = account
        modelContext.insert(tx1)

        let tx2 = FinancialTransaction(title: "Salary Payment", amount: 5000, date: Date(), transactionType: .income)
        tx2.account = account
        modelContext.insert(tx2)

        // When: Searching for "groceries"
        let results = service.search(query: "groceries", filter: .transactions)

        // Then: Should find the grocery transaction
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.title.contains("Groceries") == true)
        XCTAssertEqual(results.first?.type, .transaction)
    }

    // MARK: - Budget Search Tests

    func testSearchBudgets() {
        // Given: Test budget
        let budget = Budget(name: "Monthly Food Budget", limitAmount: 500, month: Date())
        modelContext.insert(budget)

        // When: Searching for "food"
        let results = service.search(query: "food", filter: .budgets)

        // Then: Should find the budget
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.title.contains("Food") == true)
        XCTAssertEqual(results.first?.type, .budget)
    }

    // MARK: - Subscription Search Tests

    func testSearchSubscriptions() {
        // Given: Test subscription
        let subscription = Subscription(
            name: "Netflix Premium",
            amount: 15.99,
            billingCycle: .monthly,
            nextDueDate: Date()
        )
        modelContext.insert(subscription)

        // When: Searching for "netflix"
        let results = service.search(query: "netflix", filter: .subscriptions)

        // Then: Should find the subscription
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.title.contains("Netflix") == true)
        XCTAssertEqual(results.first?.type, .subscription)
    }

    // MARK: - All Filter Tests

    func testSearchAllFilters() {
        // Given: Multiple data types
        let account = FinancialAccount(name: "Test Account", balance: 1000, accountType: .checking)
        modelContext.insert(account)

        let transaction = FinancialTransaction(
            title: "Test Transaction",
            amount: -50,
            date: Date(),
            transactionType: .expense
        )
        transaction.account = account
        modelContext.insert(transaction)

        let budget = Budget(name: "Test Budget", limitAmount: 500, month: Date())
        modelContext.insert(budget)

        // When: Searching with "all" filter
        let results = service.search(query: "test", filter: .all)

        // Then: Should find items from all categories
        XCTAssertGreaterThan(results.count, 0)

        // Verify different types are present
        let types = Set(results.map(\.type))
        XCTAssertTrue(types.contains(.account))
    }

    // MARK: - Result Ordering Tests

    func testResultsOrderedByRelevance() {
        // Given: Multiple accounts with varying relevance
        let exactMatch = FinancialAccount(name: "Checking", balance: 1000, accountType: .checking)
        let partialMatch = FinancialAccount(name: "My Checking Account", balance: 2000, accountType: .checking)
        modelContext.insert(exactMatch)
        modelContext.insert(partialMatch)

        // When: Searching
        let results = service.search(query: "checking", filter: .accounts)

        // Then: Results should be ordered (exact match typically has higher relevance)
        XCTAssertGreaterThan(results.count, 0)
        // First result should have higher or equal relevance score
        if results.count > 1 {
            XCTAssertGreaterThanOrEqual(results[0].relevanceScore, results[1].relevanceScore)
        }
    }

    // MARK: - Max Results Tests

    func testMaxResultsLimit() {
        // Given: More items than max results
        for i in 0..<100 {
            let account = FinancialAccount(name: "Account \(i)", balance: Double(i * 100), accountType: .checking)
            modelContext.insert(account)
        }

        // When: Searching with broad query
        let results = service.search(query: "account", filter: .accounts)

        // Then: Should respect max results limit (typically 50)
        XCTAssertLessThanOrEqual(results.count, SearchConfiguration.maxResults)
    }
}
