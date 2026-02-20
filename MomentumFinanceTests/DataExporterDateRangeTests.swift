import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
final class DataExporterDateRangeTests: XCTestCase {
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

    func testExportFiltersByDateRange() async throws {
        let account = FinancialAccount(name: "Range Account", balance: 0, accountType: .checking)
        self.modelContext.insert(account)

        for dayOffset in -5...5 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            let transaction = FinancialTransaction(
                title: "T\(dayOffset)",
                amount: -10,
                date: date,
                transactionType: .expense
            )
            transaction.account = account
            self.modelContext.insert(transaction)
        }

        let start = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let end = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
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
