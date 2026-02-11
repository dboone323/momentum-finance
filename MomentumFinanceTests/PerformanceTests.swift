//
//  PerformanceTests.swift
//  MomentumFinanceTests
//
//  Created by Quantum Workspace Automation on 2026-02-09.
//

import XCTest
@testable import MomentumFinance

final class PerformanceTests: XCTestCase {
    var modelContext: ModelContext!
    var testDataGenerator: TestDataGenerator!

    override func setUp() {
        super.setUp()
        modelContext = createInMemoryModelContext()
        testDataGenerator = TestDataGenerator(modelContext: modelContext)
    }

    override func tearDown() {
        modelContext = nil
        testDataGenerator = nil
        super.tearDown()
    }

    // MARK: - Transaction Performance Tests

    func testTransactionCreationPerformance() {
        measure {
            let transactions = testDataGenerator.generateTransactions(count: 1000)
            XCTAssertEqual(transactions.count, 1000)
        }
    }

    func testTransactionFilteringPerformance() {
        // Given: Large dataset
        let transactions = testDataGenerator.generateTransactions(count: 10000)

        // When: Filter by type
        measure {
            let incomeTransactions = transactions.filter { $0.transactionType == .income }
            XCTAssertGreaterThan(incomeTransactions.count, 0)
        }
    }

    func testTransactionSortingPerformance() {
        // Given: Large dataset
        let transactions = testDataGenerator.generateTransactions(count: 5000)

        // When: Sort by date
        measure {
            let sortedTransactions = transactions.sorted { $0.date > $1.date }
            XCTAssertEqual(sortedTransactions.count, 5000)
        }
    }

    // MARK: - Dashboard Performance Tests

    func testDashboardDataLoadingPerformance() {
        // Given: Large dataset
        testDataGenerator.generateTransactions(count: 2000)
        testDataGenerator.generateAccounts(count: 10)
        testDataGenerator.generateBudgets(count: 20)

        let viewModel = DashboardViewModel()
        viewModel.setModelContext(modelContext)

        // When: Load dashboard data
        measure {
            viewModel.refreshData()
        }
    }

    func testDashboardCalculationsPerformance() {
        // Given: Large dataset
        let transactions = testDataGenerator.generateTransactions(count: 10000)

        // When: Calculate totals
        measure {
            let totalIncome = transactions
                .filter { $0.transactionType == .income }
                .reduce(0) { $0 + $1.amount }

            let totalExpenses = transactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }

            XCTAssertGreaterThan(totalIncome, 0)
            XCTAssertGreaterThan(totalExpenses, 0)
        }
    }

    // MARK: - Search Performance Tests

    func testGlobalSearchPerformance() {
        // Given: Large dataset
        testDataGenerator.generateTransactions(count: 5000)

        let searchEngine = SearchEngineService()
        searchEngine.setModelContext(modelContext)

        // When: Search for term
        measure {
            let results = searchEngine.search("test", in: [.transactions])
            XCTAssertGreaterThanOrEqual(results.count, 0)
        }
    }

    // MARK: - Data Export Performance Tests

    func testDataExportPerformance() {
        // Given: Large dataset
        let transactions = testDataGenerator.generateTransactions(count: 2000)

        let exporter = DataExporter()

        // When: Export to CSV
        measure {
            let csvData = exporter.exportTransactionsToCSV(transactions)
            XCTAssertGreaterThan(csvData.count, 0)
        }
    }

    // MARK: - Financial Intelligence Performance Tests

    func testFinancialAnalysisPerformance() {
        // Given: Large dataset
        let transactions = testDataGenerator.generateTransactions(count: 3000)

        let intelligence = AdvancedFinancialIntelligence()

        // When: Analyze spending patterns
        measure {
            let insights = intelligence.analyzeSpendingPatterns(transactions: transactions)
            XCTAssertGreaterThanOrEqual(insights.count, 0)
        }
    }

    // MARK: - Memory Performance Tests

    func testMemoryUsageDuringLargeOperations() {
        // Given: Memory pressure test
        var transactions: [FinancialTransaction] = []

        measure {
            autoreleasepool {
                transactions = testDataGenerator.generateTransactions(count: 10000)
                // Force processing
                _ = transactions.filter { $0.amount > 100 }
            }
        }

        XCTAssertEqual(transactions.count, 10000)
    }

    // MARK: - UI Rendering Performance Tests

    func testTransactionListRenderingPerformance() {
        let transactions = testDataGenerator.generateTransactions(count: 1000)

        measure {
            // Simulate UI rendering performance
            let viewModel = TransactionsViewModel()
            viewModel.setModelContext(modelContext)

            // Force data processing that would happen during rendering
            let groupedTransactions = Dictionary(grouping: transactions) { transaction in
                Calendar.current.startOfDay(for: transaction.date)
            }

            XCTAssertGreaterThan(groupedTransactions.count, 0)
        }
    }

    // MARK: - Concurrent Operations Performance Tests

    func testConcurrentDataOperationsPerformance() {
        let expectation = XCTestExpectation(description: "Concurrent operations")

        measure {
            let group = DispatchGroup()

            // Simulate concurrent operations
            for i in 0..<10 {
                group.enter()
                DispatchQueue.global().async {
                    let transactions = self.testDataGenerator.generateTransactions(count: 100)
                    _ = transactions.filter { $0.amount > Double(i * 10) }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}

// MARK: - Test Data Generator

class TestDataGenerator {
    private let modelContext: ModelContext
    private let categories = ["Food", "Transportation", "Entertainment", "Utilities", "Healthcare"]
    private let transactionTypes: [TransactionType] = [.income, .expense, .transfer]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func generateTransactions(count: Int) -> [FinancialTransaction] {
        var transactions: [FinancialTransaction] = []

        for i in 0..<count {
            let transaction = FinancialTransaction(
                title: "Test Transaction \(i)",
                amount: Double.random(in: 1...1000),
                date: Date().addingTimeInterval(Double(i) * 86400), // Spread over days
                transactionType: transactionTypes.randomElement()!
            )

            if transaction.transactionType == .expense {
                transaction.category = ExpenseCategory(
                    name: categories.randomElement()!,
                    color: "#FF0000",
                    icon: "circle"
                )
            }

            transactions.append(transaction)
        }

        return transactions
    }

    func generateAccounts(count: Int) -> [FinancialAccount] {
        var accounts: [FinancialAccount] = []

        for i in 0..<count {
            let account = FinancialAccount(
                name: "Test Account \(i)",
                accountType: .checking,
                balance: Double.random(in: 0...10000),
                currency: "USD"
            )
            accounts.append(account)
        }

        return accounts
    }

    func generateBudgets(count: Int) -> [Budget] {
        var budgets: [Budget] = []

        for i in 0..<count {
            let budget = Budget(
                name: "Test Budget \(i)",
                amount: Double.random(in: 100...1000),
                spent: Double.random(in: 0...500),
                category: categories.randomElement()!,
                period: .monthly
            )
            budgets.append(budget)
        }

        return budgets
    }
}

// MARK: - Helper Functions

private func createInMemoryModelContext() -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: [FinancialTransaction.self, FinancialAccount.self, Budget.self],
        configurations: config
    )
    return ModelContext(container)
}
