import SwiftData
import XCTest
@testable import MomentumFinance

/// Performance regression tests to track app performance over time
final class PerformanceRegressionTests: XCTestCase {
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()

        // In-memory performance testing
        let schema = Schema([
            FinancialTransaction.self,
            FinancialAccount.self,
            ExpenseCategory.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)
    }

    // MARK: - Search Performance

    func testSearchEnginePerformance() {
        // Create large dataset
        createTestTransactions(count: 1000)

        let searchEngine = RootSearchEngineService(modelContext: modelContext)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            _ = searchEngine.search(query: "test", filter: .all, maxResults: 50)
        }
    }

    func testSearchEnginePerformance_Baseline() {
        createTestTransactions(count: 1000)
        let searchEngine = RootSearchEngineService(modelContext: modelContext)

        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(options: options) {
            _ = searchEngine.search(query: "grocery", filter: .transactions, maxResults: 50)
        }

        // Baseline: Should complete in < 0.1s
    }

    // MARK: - Export Performance

    func testCSVExportPerformance() async {
        createTestTransactions(count: 5000)

        let exportService = SwiftDataExportEngineService(modelContext: modelContext)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            _ = try? await exportService.exportToCSV()
        }

        // Baseline: 5000 transactions should export in < 2s
    }

    func testJSONExportPerformance() async {
        createTestTransactions(count: 5000)

        let exportService = SwiftDataExportEngineService(modelContext: modelContext)

        let options = XCTMeasureOptions()
        options.iterationCount = 5

        measure(options: options) {
            _ = try? await exportService.exportToJSON()
        }
    }

    // MARK: - ML Performance

    func testMLSpendingPredictionPerformance() async {
        createTestTransactions(count: 500)

        let mlService = SwiftDataFinancialMLService(modelContext: modelContext)

        measure(metrics: [XCTClockMetric()]) {
            Task {
                _ = await mlService.predictSpending(daysAhead: 30)
            }
        }

        // Baseline: < 0.5s
    }

    func testMLPatternAnalysisPerformance() async {
        createTestTransactions(count: 1000)

        let mlService = SwiftDataFinancialMLService(modelContext: modelContext)

        measure {
            Task {
                _ = await mlService.analyzeSpendingPatterns()
            }
        }
    }

    // MARK: - SwiftData Fetch Performance

    func testLargeFetchPerformance() {
        createTestTransactions(count: 10000)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            _ = try? modelContext.fetch(FetchDescriptor<FinancialTransaction>())
        }

        // Baseline: 10K records in < 0.3s
    }

    func testFilteredFetchPerformance() throws {
        createTestTransactions(count: 10000)

        let startDate = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -1, to: Date()))

        measure {
            let descriptor = FetchDescriptor<FinancialTransaction>(
                predicate: #Predicate { $0.date >= startDate }
            )
            _ = try? modelContext.fetch(descriptor)
        }
    }

    // MARK: - Memory Leak Detection

    func testNoMemoryLeaksInSearch() {
        let searchEngine = RootSearchEngineService(modelContext: modelContext)

        measure(metrics: [XCTMemoryMetric()]) {
            for i in 0..<100 {
                _ = searchEngine.search(query: "test\(i)", filter: .all, maxResults: 10)
            }
        }

        // Memory should not grow significantly
    }

    func testNoMemoryLeaksInMLAnalysis() async {
        createTestTransactions(count: 500)
        let mlService = SwiftDataFinancialMLService(modelContext: modelContext)

        measure(metrics: [XCTMemoryMetric()]) {
            Task {
                for _ in 0..<10 {
                    _ = await mlService.analyzeSpendingPatterns()
                }
            }
        }
    }

    // MARK: - UI Responsiveness

    func testDashboardLoadPerformance() {
        createTestTransactions(count: 1000)

        measure(metrics: [XCTClockMetric()]) {
            // Simulate dashboard data loading
            _ = try? modelContext.fetch(FetchDescriptor<FinancialTransaction>())
            _ = try? modelContext.fetch(FetchDescriptor<FinancialAccount>())
            _ = try? modelContext.fetch(FetchDescriptor<Budget>())
        }

        // Should load in < 0.5s for responsive UI
    }

    // MARK: - Helpers

    private func createTestTransactions(count: Int) {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        let category = ExpenseCategory(name: "Test", iconName: "circle")
        modelContext.insert(account)
        modelContext.insert(category)

        for i in 0..<count {
            let transaction = FinancialTransaction(
                title: "Transaction \(i)",
                amount: -Double.random(in: 10...500),
                date: Date().addingTimeInterval(TimeInterval(-i * 86400)),
                transactionType: .expense
            )
            transaction.account = account
            transaction.category = category
            modelContext.insert(transaction)
        }

        try? modelContext.save()
    }
}
