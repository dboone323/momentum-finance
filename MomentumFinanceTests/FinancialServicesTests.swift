import SwiftData
import XCTest
@testable import MomentumFinance

final class FinancialServicesTests: XCTestCase {
    var modelContext: ModelContext!
    var entityManager: SwiftDataEntityManager!
    var exportService: SwiftDataExportEngineService!
    var mlService: SwiftDataFinancialMLService!
    var patternAnalyzer: SwiftDataTransactionPatternAnalyzer!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        // Create in-memory model container
        let schema = Schema([
            FinancialTransaction.self,
            FinancialAccount.self,
            Budget.self,
            Subscription.self,
            SavingsGoal.self,
            ExpenseCategory.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        // Initialize all services with DI
        entityManager = SwiftDataEntityManager(modelContext: modelContext)
        exportService = SwiftDataExportEngineService(modelContext: modelContext)
        mlService = SwiftDataFinancialMLService(modelContext: modelContext)
        patternAnalyzer = SwiftDataTransactionPatternAnalyzer(modelContext: modelContext)
    }

    override func tearDown() {
        modelContext = nil
        entityManager = nil
        exportService = nil
        mlService = nil
        patternAnalyzer = nil
        super.tearDown()
    }

    // MARK: - EntityManager DI Tests

    func testEntityManagerDependencyInjection() {
        XCTAssertNotNil(entityManager)
    }

    func testEntityManagerSave() async throws {
        let account = FinancialAccount(name: "Test", balance: 100, accountType: .checking)
        modelContext.insert(account)

        try await entityManager.save()

        let accounts: [FinancialAccount] = try await entityManager.fetch(FinancialAccount.self)
        XCTAssertEqual(accounts.count, 1)
    }

    func testEntityManagerDelete() async throws {
        let account = FinancialAccount(name: "Test", balance: 100, accountType: .checking)
        modelContext.insert(account)
        try await entityManager.save()

        try await entityManager.delete(account)

        let accounts: [FinancialAccount] = try await entityManager.fetch(FinancialAccount.self)
        XCTAssertEqual(accounts.count, 0)
    }

    func testEntityManagerFetch() async throws {
        // Create test data
        let account1 = FinancialAccount(name: "Test1", balance: 100, accountType: .checking)
        let account2 = FinancialAccount(name: "Test2", balance: 200, accountType: .savings)
        modelContext.insert(account1)
        modelContext.insert(account2)
        try await entityManager.save()

        let accounts: [FinancialAccount] = try await entityManager.fetch(FinancialAccount.self)
        XCTAssertEqual(accounts.count, 2)
    }

    // MARK: - ExportService DI Tests

    func testExportServiceDependencyInjection() {
        XCTAssertNotNil(exportService)
    }

    func testExportServiceCSVExport() async throws {
        // Create test transaction
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        let transaction = FinancialTransaction(title: "Test", amount: -50, date: Date(), transactionType: .expense)
        transaction.account = account
        modelContext.insert(transaction)
        try modelContext.save()

        // Export to CSV
        let csvURL = try await exportService.exportToCSV()

        XCTAssertTrue(FileManager.default.fileExists(atPath: csvURL.path))

        let csvContent = try String(contentsOf: csvURL, encoding: .utf8)
        XCTAssertTrue(csvContent.contains("Date,Title,Amount"))

        // Cleanup
        try? FileManager.default.removeItem(at: csvURL)
    }

    func testExportServiceJSONExport() async throws {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        let transaction = FinancialTransaction(title: "Test", amount: -50, date: Date(), transactionType: .expense)
        transaction.account = account
        modelContext.insert(transaction)
        try modelContext.save()

        // Export to JSON via settings
        let settings = ["format": "json"]
        let jsonURL = try await exportService.export(settings: settings)

        XCTAssertTrue(FileManager.default.fileExists(atPath: jsonURL.path))

        // Cleanup
        try? FileManager.default.removeItem(at: jsonURL)
    }

    // MARK: - ML Service DI Tests

    func testMLServiceDependencyInjection() {
        XCTAssertNotNil(mlService)
    }

    func testMLServiceSpendingPrediction() async {
        // Create historical transactions
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        for i in 1...30 {
            let transaction = FinancialTransaction(
                title: "Expense \(i)",
                amount: -50,
                date: Date().addingTimeInterval(TimeInterval(-i * 86400)),
                transactionType: .expense
            )
            transaction.account = account
            modelContext.insert(transaction)
        }
        try? modelContext.save()

        let prediction = await mlService.predictSpending(daysAhead: 7)
        XCTAssertGreaterThan(prediction, 0)
    }

    func testMLServiceSpendingPatterns() async {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        modelContext.insert(account)
        modelContext.insert(category)

        let transaction = FinancialTransaction(
            title: "Groceries",
            amount: -100,
            date: Date(),
            transactionType: .expense
        )
        transaction.account = account
        transaction.category = category
        modelContext.insert(transaction)
        try? modelContext.save()

        let patterns = await mlService.analyzeSpendingPatterns()
        XCTAssertGreaterThan(patterns.count, 0)
    }

    func testMLServiceAnomalyDetection() async {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        // Normal transaction
        let normal = FinancialTransaction(title: "Normal", amount: -50, date: Date(), transactionType: .expense)
        normal.account = account
        modelContext.insert(normal)

        // Anomalous transaction (high amount)
        let anomalous = FinancialTransaction(title: "Expensive", amount: -2000, date: Date(), transactionType: .expense)
        anomalous.account = account
        modelContext.insert(anomalous)
        try? modelContext.save()

        let anomalies = await mlService.detectAnomalies()
        XCTAssertGreaterThan(anomalies.count, 0)
        XCTAssertTrue(anomalies.contains { $0.transaction.title == "Expensive" })
    }

    // MARK: - Pattern Analyzer DI Tests

    func testPatternAnalyzerDependencyInjection() {
        XCTAssertNotNil(patternAnalyzer)
    }

    func testPatternAnalyzerRecurringDetection() async {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        // Create recurring transaction
        for i in 1...3 {
            let transaction = FinancialTransaction(
                title: "Netflix Subscription",
                amount: -15.99,
                date: Date().addingTimeInterval(TimeInterval(-i * 30 * 86400)),
                transactionType: .expense
            )
            transaction.account = account
            modelContext.insert(transaction)
        }
        try? modelContext.save()

        let patterns = await patternAnalyzer.analyzePatterns()
        XCTAssertGreaterThan(patterns.count, 0)
        XCTAssertTrue(patterns.first?.isRecurring == true)
    }

    func testPatternAnalyzerCategorySuggestions() async {
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        // Uncategorized transaction
        let transaction = FinancialTransaction(
            title: "Whole Foods Market",
            amount: -75,
            date: Date(),
            transactionType: .expense
        )
        transaction.account = account
        modelContext.insert(transaction)
        try? modelContext.save()

        let suggestions = await patternAnalyzer.suggestCategories()
        XCTAssertGreaterThan(suggestions.count, 0)
        XCTAssertEqual(suggestions.first?.suggestedCategory, "Food & Dining")
    }

    // MARK: - Service Integration Tests

    func testServiceIntegration_CompleteWorkflow() async throws {
        // 1. Create data via EntityManager
        let account = FinancialAccount(name: "Integration Test", balance: 1000, accountType: .checking)
        modelContext.insert(account)
        try await entityManager.save()

        // 2. Add transactions
        for i in 1...10 {
            let transaction = FinancialTransaction(
                title: "Transaction \(i)",
                amount: -Double(i * 10),
                date: Date(),
                transactionType: .expense
            )
            transaction.account = account
            modelContext.insert(transaction)
        }
        try await entityManager.save()

        // 3. Analyze with ML Service
        let prediction = await mlService.predictSpending(daysAhead: 30)
        XCTAssertGreaterThan(prediction, 0)

        // 4. Export data
        let exportURL = try await exportService.exportToCSV()
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))

        // Cleanup
        try? FileManager.default.removeItem(at: exportURL)
    }
}
