import MomentumFinanceCore
import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
class ExportEngineServiceTestCase: XCTestCase {
    var modelContext: ModelContext!
    var service: ExportEngineService!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([
            FinancialTransaction.self,
            FinancialAccount.self,
            Budget.self,
            Subscription.self,
            SavingsGoal.self,
            ExpenseCategory.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        self.modelContext = ModelContext(container)
        self.service = ExportEngineService(modelContainer: container)
    }

    @MainActor
    override func tearDownWithError() throws {
        self.service = nil
        self.modelContext = nil
        try super.tearDownWithError()
    }
}

@MainActor
final class DataExporterDateRangeTests: ExportEngineServiceTestCase {

    func testExportFiltersByDateRange() async throws {
        let account = FinancialAccount(name: "Range Account", balance: 0, accountType: .checking)
        self.modelContext.insert(account)

        let now = Date()
        for dayOffset in -5...5 {
            let date = try XCTUnwrap(
                Calendar.current.date(byAdding: .day, value: dayOffset, to: now)
            )
            let transaction = FinancialTransaction(
                title: "T\(dayOffset)",
                amount: -10,
                date: date,
                transactionType: .expense
            )
            transaction.account = account
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
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let transactions = json?["transactions"] as? [[String: Any]]

        XCTAssertEqual(transactions?.count, 5)
    }
}
