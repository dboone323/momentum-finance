import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
final class DataExporterContentTests: ExportEngineServiceTestCase {
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

        let content = try await self.exportCSVContent()
        XCTAssertTrue(content.contains("SeedTx0"))
    }

    func testCSVExportWithNoTransactionsKeepsSectionHeaders() async throws {
        let content = try await self.exportCSVContent()
        XCTAssertFalse(content.contains("SeedTx"))
    }

    private func exportCSVContent() async throws -> String {
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
        return content
    }
}
