import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
final class DataExporterContentTests: XCTestCase {
    var modelContext: ModelContext!
    var service: ExportEngineService!

    override func setUp() {
        super.setUp()

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
        self.modelContext = ModelContext(container)
        self.service = ExportEngineService(modelContext: modelContext)
    }

    override func tearDown() {
        self.service = nil
        self.modelContext = nil
        super.tearDown()
    }

    func testCSVExportIncludesHeaderAndRows() async throws {
        let account = FinancialAccount(name: "Checking", balance: 1000, accountType: .checking)
        self.modelContext.insert(account)

        for i in 0..<3 {
            let transaction = FinancialTransaction(
                title: "SeedTx\(i)",
                amount: Decimal(100 + i),
                date: Date().addingTimeInterval(Double(i) * 60),
                transactionType: i == 2 ? .expense : .income
            )
            transaction.account = account
            self.modelContext.insert(transaction)
        }

        let settings = ExportSettings(
            format: .csv,
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date().addingTimeInterval(86400),
            includeTransactions: true,
            includeAccounts: false,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        let url = try await self.service.export(settings: settings)
        defer { try? FileManager.default.removeItem(at: url) }

        let content = try String(contentsOf: url)
        XCTAssertTrue(content.contains("TRANSACTIONS"))
        XCTAssertTrue(content.contains("Date,Title,Amount,Type,Category,Account,Notes"))
        XCTAssertTrue(content.contains("SeedTx0"))
    }

    func testCSVExportWithNoTransactionsKeepsSectionHeaders() async throws {
        let settings = ExportSettings(
            format: .csv,
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date().addingTimeInterval(86400),
            includeTransactions: true,
            includeAccounts: false,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        let url = try await self.service.export(settings: settings)
        defer { try? FileManager.default.removeItem(at: url) }

        let content = try String(contentsOf: url)
        XCTAssertTrue(content.contains("TRANSACTIONS"))
        XCTAssertTrue(content.contains("Date,Title,Amount,Type,Category,Account,Notes"))
        XCTAssertFalse(content.contains("SeedTx"))
    }
}
