@testable import MomentumFinance
import XCTest
import SwiftData

@MainActor
final class SubscriptionPaymentIntegrationTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            Subscription.self,
            FinancialAccount.self,
            FinancialTransaction.self,
            SubscriptionPayment.self,
            ExpenseCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    func testProcessPayment_UpdatesBalanceAndDueDate() throws {
        // Given
        let account = FinancialAccount(
            name: "Test Checking",
            balance: 1000.0,
            iconName: "bank",
            accountType: .checking
        )
        modelContext.insert(account)

        let startDate = Date()
        let subscription = Subscription(
            name: "Test Sub",
            amount: 10.0,
            billingCycle: .monthly,
            nextDueDate: startDate
        )
        subscription.account = account
        modelContext.insert(subscription)

        // When
        subscription.processPayment(modelContext: modelContext)

        // Then
        // 1. Balance should decrease by 10
        XCTAssertEqual(account.balance, 990.0, "Account balance should decrease by subscription amount")

        // 2. Next due date should be 1 month later
        let expectedDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        XCTAssertEqual(subscription.nextDueDate.timeIntervalSince1970, expectedDate.timeIntervalSince1970, accuracy: 1.0, "Next due date should be advanced by 1 month")

        // 3. Transaction should be created
        let descriptor = FetchDescriptor<FinancialTransaction>()
        let transactions = try modelContext.fetch(descriptor)
        XCTAssertEqual(transactions.count, 1, "A transaction should be created")
        XCTAssertEqual(transactions.first?.amount, 10.0, "Transaction amount should match subscription")
        XCTAssertEqual(transactions.first?.title, "Test Sub", "Transaction title should match subscription name")
    }

    func testProcessPayment_WeeklyCycle() throws {
        // Given
        let startDate = Date()
        let subscription = Subscription(
            name: "Weekly Sub",
            amount: 5.0,
            billingCycle: .weekly,
            nextDueDate: startDate
        )
        modelContext.insert(subscription)

        // When
        subscription.processPayment(modelContext: modelContext)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        XCTAssertEqual(subscription.nextDueDate.timeIntervalSince1970, expectedDate.timeIntervalSince1970, accuracy: 1.0, "Next due date should be advanced by 1 week")
    }

    func testProcessPayment_YearlyCycle() throws {
        // Given
        let startDate = Date()
        let subscription = Subscription(
            name: "Yearly Sub",
            amount: 100.0,
            billingCycle: .yearly,
            nextDueDate: startDate
        )
        modelContext.insert(subscription)

        // When
        subscription.processPayment(modelContext: modelContext)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        XCTAssertEqual(subscription.nextDueDate.timeIntervalSince1970, expectedDate.timeIntervalSince1970, accuracy: 1.0, "Next due date should be advanced by 1 year")
    }
}
