@testable import MomentumFinance
import XCTest

class TransactionPatternDetectionTests: XCTestCase {
    var transactions: [FinancialTransaction]!

    // MARK: - findRecurringTransactions

    func testFindRecurringTransactionsWithMonthlyPattern() {
        let recurringTransactions = fi_findRecurringTransactions(transactions)
        XCTAssertEqual(recurringTransactions.count, 2)
        XCTAssertEqual(recurringTransactions[0].title, "Monthly Rent")
        XCTAssertEqual(recurringTransactions[1].title, "Groceries")
    }

    func testFindRecurringTransactionsWithWeeklyPattern() {
        let recurringTransactions = fi_findRecurringTransactions(transactions)
        XCTAssertEqual(recurringTransactions.count, 2)
        XCTAssertEqual(recurringTransactions[0].title, "Monthly Rent")
        XCTAssertEqual(recurringTransactions[1].title, "Groceries")
    }

    func testFindRecurringTransactionsWithYearlyPattern() {
        let recurringTransactions = fi_findRecurringTransactions(transactions)
        XCTAssertEqual(recurringTransactions.count, 2)
        XCTAssertEqual(recurringTransactions[0].title, "Monthly Rent")
        XCTAssertEqual(recurringTransactions[1].title, "Groceries")
    }

    func testFindRecurringTransactionsWithNoPattern() {
        let transactionsWithoutPattern = [
            FinancialTransaction(title: "Car Payment", amount: -300, date: Date().addingTimeInterval(24 * 60 * 60)),
            FinancialTransaction(title: "Monthly Rent", amount: -1000, date: Date()),
            FinancialTransaction(title: "Groceries", amount: -500, date: Date().addingTimeInterval(7 * 24 * 60 * 60)),
        ]
        let recurringTransactions = fi_findRecurringTransactions(transactionsWithoutPattern)
        XCTAssertEqual(recurringTransactions.count, 0)
    }

    // MARK: - findPotentialDuplicates

    func testFindPotentialDuplicatesWithShortTimePeriod() {
        let duplicateSuspects = fi_findPotentialDuplicates(transactions)
        XCTAssertEqual(duplicateSuspects.count, 1)
        XCTAssertEqual(duplicateSuspects[0][0].title, "Groceries")
        XCTAssertEqual(duplicateSuspects[0][1].title, "Groceries")
    }

    func testFindPotentialDuplicatesWithoutShortTimePeriod() {
        let transactionsWithoutShortTimePeriod = [
            FinancialTransaction(title: "Car Payment", amount: -300, date: Date().addingTimeInterval(24 * 60 * 60)),
            FinancialTransaction(title: "Monthly Rent", amount: -1000, date: Date()),
            FinancialTransaction(title: "Groceries", amount: -500, date: Date().addingTimeInterval(7 * 24 * 60 * 60)),
        ]
        let duplicateSuspects = fi_findPotentialDuplicates(transactionsWithoutShortTimePeriod)
        XCTAssertEqual(duplicateSuspects.count, 0)
    }
}
