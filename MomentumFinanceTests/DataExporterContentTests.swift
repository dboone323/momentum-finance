import MomentumFinanceCore
import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
final class DataExporterContentTests: ExportEngineServiceTestCase {
    func testCSVExportIncludesHeaderAndRows() async throws {
        for i in 0..<3 {
            let transaction = MomentumFinanceCore.FinancialTransaction(
                title: "SeedTx\(i)",
                amount: Double(100 + i),
                date: Date().addingTimeInterval(Double(i) * 60),
                transactionType: i == 2 ? .expense : .income
            )
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
        let settings = MomentumFinanceCore.ExportSettings(
            format: .csv,
            dateRange: .custom,
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

        let content = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(content.contains("TRANSACTIONS"))
        XCTAssertTrue(content.contains("Date,Title,Amount,Type,Category,Account,Notes"))
        return content
    }
}
