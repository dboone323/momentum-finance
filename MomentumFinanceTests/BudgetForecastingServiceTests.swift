import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
final class BudgetForecastingServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var forecastingService: BudgetForecastingService!
    let category = ExpenseCategory(name: "Food", iconName: "cart")

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: FinancialTransaction.self,
            ExpenseCategory.self,
            configurations: config
        )
        modelContext = modelContainer.mainContext
        forecastingService = BudgetForecastingService(modelContext: modelContext)
    }

    func testForecastNextMonth_Empty() async {
        let forecast = await forecastingService.forecastNextMonth()
        XCTAssertEqual(forecast.amount, 0)
        XCTAssertEqual(forecast.trend, .stable)
    }

    func testForecastNextMonth_StableSpending() async throws {
        // Given: 3 months of consistent spending ($100 each month)
        let dates = [
            Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
        ]

        for date in dates {
            let transaction = FinancialTransaction(
                title: "Grocery",
                amount: -100.0,
                date: date,
                transactionType: .expense
            )
            transaction.category = category
            modelContext.insert(transaction)
        }

        // When
        let forecast = await forecastingService.forecastNextMonth()

        // Then
        // Baseline is 100. Trend is stable (0).
        // Seasonal factor might apply depending on current month, but roughly 100.
        XCTAssertEqual(forecast.trend, .stable)
        XCTAssertEqual(forecast.amount, 100.0 * seasonalFactor(), accuracy: 5.0)
    }

    func testForecastNextMonth_IncreasingTrend() async throws {
        // Given: Spending increasing over 3 months (50 -> 100 -> 150)
        let today = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today)!
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: today)!
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: today)!

        let t1 = FinancialTransaction(title: "T1", amount: -50, date: threeMonthsAgo, transactionType: .expense)
        t1.category = category
        let t2 = FinancialTransaction(title: "T2", amount: -100, date: twoMonthsAgo, transactionType: .expense)
        t2.category = category
        let t3 = FinancialTransaction(title: "T3", amount: -150, date: oneMonthAgo, transactionType: .expense)
        t3.category = category

        modelContext.insert(t1)
        modelContext.insert(t2)
        modelContext.insert(t3)

        // When
        let forecast = await forecastingService.forecastNextMonth()

        // Then
        XCTAssertEqual(forecast.trend, .increasing)
        XCTAssertGreaterThan(forecast.amount, 100) // Expectation is it continues rising
    }

    // Helper to match service logic
    private func seasonalFactor() -> Double {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 11, 12: return 1.3
        case 8, 9: return 1.1
        case 1: return 0.9
        default: return 1.0
        }
    }
}
