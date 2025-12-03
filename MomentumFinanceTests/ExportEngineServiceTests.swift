import SwiftData
import XCTest
@testable import MomentumFinance

final class ExportEngineServiceTests: XCTestCase {

    var modelContext: ModelContext!
    var service: ExportEngineService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        // Create in-memory model container for testing
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

        service = ExportEngineService(modelContext: modelContext)
    }

    override func tearDown() {
        modelContext = nil
        service = nil
        super.tearDown()
    }

    // MARK: - CSV Export Tests

    func testExportToCSV_CreatesFile() async throws {
        // Given: Some test data
        let account = FinancialAccount(name: "Test Account", balance: 1000, accountType: .checking)
        modelContext.insert(account)

        let settings = ExportSettings(
            format: .csv,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date(),
            includeTransactions: false,
            includeAccounts: true,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        // When: Exporting to CSV
        let fileURL = try await service.export(settings: settings)

        // Then: File should be created
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

        // Cleanup
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testCSV_EscapesCommasInFields() async throws {
        // Given: Data with commas
        let account = FinancialAccount(name: "Test, Account", balance: 1000, accountType: .checking)
        modelContext.insert(account)

        let settings = ExportSettings(
            format: .csv,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date(),
            includeTransactions: false,
            includeAccounts: true,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        // When: Exporting
        let fileURL = try await service.export(settings: settings)
        let csvContent = try String(contentsOf: fileURL, encoding: .utf8)

        // Then: Commas should be escaped with quotes
        XCTAssertTrue(csvContent.contains("\"Test, Account\""))

        // Cleanup
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - JSON Export Tests

    func testExportToJSON_CreatesValidJSON() async throws {
        // Given: Test account
        let account = FinancialAccount(name: "Checking", balance: 5000, accountType: .checking)
        modelContext.insert(account)

        let settings = ExportSettings(
            format: .json,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date(),
            includeTransactions: false,
            includeAccounts: true,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        // When: Exporting to JSON
        let fileURL = try await service.export(settings: settings)
        let jsonData = try Data(contentsOf: fileURL)

        // Then: Should be valid JSON
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["exportInfo"])
        XCTAssertNotNil(json?["accounts"])

        // Cleanup
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testJSON_IncludesExportMetadata() async throws {
        // Given: Empty data
        let settings = ExportSettings(
            format: .json,
            startDate: Date().addingTimeInterval(-86400 * 7),
            endDate: Date(),
            includeTransactions: false,
            includeAccounts: false,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        // When: Exporting
        let fileURL = try await service.export(settings: settings)
        let jsonData = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

        // Then: Should contain metadata
        let exportInfo = json?["exportInfo"] as? [String: String]
        XCTAssertNotNil(exportInfo)
        XCTAssertEqual(exportInfo?["app"], "Momentum Finance")
        XCTAssertNotNil(exportInfo?["date"])

        // Cleanup
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Date Range Filtering Tests

    func testExport_FiltersTransactionsByDateRange() async throws {
        // Given: Transactions on different dates
        let account = FinancialAccount(name: "Test", balance: 0, accountType: .checking)
        modelContext.insert(account)

        let oldDate = Date().addingTimeInterval(-86400 * 60) // 60 days ago
        let recentDate = Date().addingTimeInterval(-86400 * 10) // 10 days ago

        let oldTx = FinancialTransaction(title: "Old", amount: -50, date: oldDate, transactionType: .expense)
        oldTx.account = account
        modelContext.insert(oldTx)

        let recentTx = FinancialTransaction(title: "Recent", amount: -30, date: recentDate, transactionType: .expense)
        recentTx.account = account
        modelContext.insert(recentTx)

        let settings = ExportSettings(
            format: .json,
            startDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            endDate: Date(),
            includeTransactions: true,
            includeAccounts: false,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        // When: Exporting
        let fileURL = try await service.export(settings: settings)
        let jsonData = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

        // Then: Should only include recent transaction
        let transactions = json?["transactions"] as? [[String: Any]]
        XCTAssertEqual(transactions?.count, 1)

        let transaction = transactions?.first
        XCTAssertEqual(transaction?["title"] as? String, "Recent")

        // Cleanup
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Error Handling Tests

    func testPDFExport_ThrowsOnIOS() async {
        #if os(iOS)
            let settings = ExportSettings(
                format: .pdf,
                startDate: Date().addingTimeInterval(-86400 * 30),
                endDate: Date(),
                includeTransactions: true,
                includeAccounts: true,
                includeBudgets: true,
                includeSubscriptions: true,
                includeGoals: true
            )

            // When/Then: Should throw error on iOS
            do {
                _ = try await service.export(settings: settings)
                XCTFail("Should have thrown error on iOS")
            } catch {
                // Expected to throw
                XCTAssertTrue(true)
            }
        #endif
    }
}
