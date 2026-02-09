//
// RecurringTransactionServiceTests.swift
// MomentumFinanceTests
//
// Tests for recurring transaction processing
//

import XCTest
@testable import MomentumFinance

final class RecurringTransactionServiceTests: XCTestCase {
    var service: RecurringTransactionService!

    override func setUpWithError() throws {
        service = RecurringTransactionService.shared
    }

    // MARK: - Helper

    private func makeRecurring(
        name: String = "Test",
        amount: Decimal = 100,
        interval: RecurrenceInterval = .monthly,
        daysAgo: Int = 1,
        isActive: Bool = true
    ) -> RecurringTransaction {
        RecurringTransaction(
            id: UUID(),
            name: name,
            amount: amount,
            categoryId: UUID(),
            accountId: UUID(),
            interval: interval,
            startDate: Date(),
            nextDueDate: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!,
            isActive: isActive
        )
    }

    // MARK: - Process Recurring Transactions

    func testProcessDueTransaction() {
        // Given: A recurring transaction that's due
        let recurring = makeRecurring(name: "Rent", amount: 1500, daysAgo: 1)

        // When: Processing
        let transactions = service.processRecurringTransactions(transactions: [recurring])

        // Then: Should generate a transaction
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.amount, 1500)
        XCTAssertEqual(transactions.first?.note, "Rent")
    }

    func testProcessInactiveTransaction() {
        // Given: An inactive recurring transaction
        let recurring = makeRecurring(name: "Canceled Sub", isActive: false)

        // When: Processing
        let transactions = service.processRecurringTransactions(transactions: [recurring])

        // Then: Should not generate any transactions
        XCTAssertTrue(transactions.isEmpty)
    }

    func testProcessFutureTransaction() {
        // Given: A recurring transaction not yet due
        let futureRecurring = RecurringTransaction(
            id: UUID(),
            name: "Future",
            amount: 50,
            categoryId: UUID(),
            accountId: UUID(),
            interval: .monthly,
            startDate: Date(),
            nextDueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            isActive: true
        )

        // When: Processing
        let transactions = service.processRecurringTransactions(transactions: [futureRecurring])

        // Then: Should not generate transactions
        XCTAssertTrue(transactions.isEmpty)
    }

    func testProcessMultipleTransactions() {
        // Given: Multiple due recurring transactions
        let rent = makeRecurring(name: "Rent", amount: 1500)
        let utilities = makeRecurring(name: "Utilities", amount: 150)
        let insurance = makeRecurring(name: "Insurance", amount: 200)

        // When: Processing
        let transactions = service.processRecurringTransactions(transactions: [rent, utilities, insurance])

        // Then: Should generate transactions for all
        XCTAssertEqual(transactions.count, 3)

        let totalAmount = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        XCTAssertEqual(totalAmount, 1850)
    }

    // MARK: - Recurrence Interval Tests

    func testRecurrenceIntervalDaily() {
        let recurring = makeRecurring(interval: .daily)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    func testRecurrenceIntervalWeekly() {
        let recurring = makeRecurring(interval: .weekly)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    func testRecurrenceIntervalBiweekly() {
        let recurring = makeRecurring(interval: .biweekly)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    func testRecurrenceIntervalMonthly() {
        let recurring = makeRecurring(interval: .monthly)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    func testRecurrenceIntervalQuarterly() {
        let recurring = makeRecurring(interval: .quarterly)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    func testRecurrenceIntervalYearly() {
        let recurring = makeRecurring(interval: .yearly)
        let transactions = service.processRecurringTransactions(transactions: [recurring])
        XCTAssertEqual(transactions.count, 1)
    }

    // MARK: - Transaction Properties Tests

    func testTransactionPropertiesPreserved() {
        let categoryId = UUID()
        let accountId = UUID()

        let recurring = RecurringTransaction(
            id: UUID(),
            name: "Test Note",
            amount: 99.99,
            categoryId: categoryId,
            accountId: accountId,
            interval: .monthly,
            startDate: Date(),
            nextDueDate: Date().addingTimeInterval(-86400),
            isActive: true
        )

        let transactions = service.processRecurringTransactions(transactions: [recurring])

        XCTAssertEqual(transactions.first?.categoryId, categoryId)
        XCTAssertEqual(transactions.first?.accountId, accountId)
        XCTAssertEqual(transactions.first?.amount, 99.99)
        XCTAssertEqual(transactions.first?.note, "Test Note")
    }
}
