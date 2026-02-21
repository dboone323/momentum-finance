import MomentumFinanceCore
import SwiftData
import XCTest
@testable import MomentumFinance

class ExportEngineServiceTestCase: XCTestCase {
    var modelContext: ModelContext!
    var service: ExportEngineService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([
            MomentumFinanceCore.FinancialTransaction.self,
            MomentumFinanceCore.FinancialAccount.self,
            MomentumFinanceCore.Budget.self,
            MomentumFinanceCore.Subscription.self,
            MomentumFinanceCore.SavingsGoal.self,
            MomentumFinanceCore.ExpenseCategory.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        self.modelContext = ModelContext(container)
        self.service = ExportEngineService(modelContainer: container)
    }

    override func tearDownWithError() throws {
        self.service = nil
        self.modelContext = nil
        try super.tearDownWithError()
    }
}

final class DataExporterDateRangeTests: ExportEngineServiceTestCase {

    @MainActor
    func testExportFiltersByDateRange() async throws {
        let now = Date()
        for dayOffset in -5...5 {
            let date = try XCTUnwrap(
                Calendar.current.date(byAdding: .day, value: dayOffset, to: now)
            )
            let transaction = MomentumFinanceCore.FinancialTransaction(
                title: "T\(dayOffset)",
                amount: -10,
                date: date,
                transactionType: .expense
            )
            self.modelContext.insert(transaction)
        }

        let start = try XCTUnwrap(
            Calendar.current.date(byAdding: .day, value: -2, to: now)
        )
        let end = try XCTUnwrap(
            Calendar.current.date(byAdding: .day, value: 2, to: now)
        )
        let settings = ExportSettings(
            format: .json,
            dateRange: .custom,
            startDate: start,
            endDate: end,
            includeTransactions: true,
            includeAccounts: false,
            includeBudgets: false,
            includeSubscriptions: false,
            includeGoals: false
        )

        let url = try await self.service.export(settings: settings)
        defer { try? FileManager.default.removeItem(at: url) }

        let data = try Data(contentsOf: url)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let json = try XCTUnwrap(jsonObject as? [String: Any])
        let transactions = try XCTUnwrap(json["transactions"] as? [[String: Any]])
        XCTAssertEqual(transactions.count, 5)
    }
}
