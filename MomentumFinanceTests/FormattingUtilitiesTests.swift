@testable import MomentumFinance
import XCTest

class FormattingUtilitiesTests: XCTestCase {
    // Test case for fi_formatCurrency with optional currency code
    func testFiFormatCurrencyWithOptionalCode() {
        let amount = 1234.56
        let expectedCurrencyCode = "USD"
        let result = fi_formatCurrency(amount, code: expectedCurrencyCode)

        XCTAssertEqual(result, "$1,234.56", "Expected currency code to be USD")
    }

    func testFiFormatCurrencyWithoutOptionalCode() {
        let amount = 1234.56
        let result = fi_formatCurrency(amount)

        XCTAssertEqual(result, "$1,234.56", "Expected default currency code to be USD")
    }

    // Test case for fi_formatDateShort with a specific date
    func testFiFormatDateShortWithSpecificDate() {
        let date = Date(timeIntervalSinceNow: 0)
        let expectedFormattedDate = "Today"
        let result = fi_formatDateShort(date)

        XCTAssertEqual(result, expectedFormattedDate, "Expected formatted date to be 'Today'")
    }

    // Test case for fi_formatMonthAbbrev with a specific date
    func testFiFormatMonthAbbrevWithSpecificDate() {
        let date = Date(timeIntervalSinceNow: 0)
        let expectedFormattedMonth = "Jan"
        let result = fi_formatMonthAbbrev(date)

        XCTAssertEqual(result, expectedFormattedMonth, "Expected formatted month to be 'Jan'")
    }

    // Test case for formatCurrency with optional currency code
    func testFormatCurrencyWithOptionalCode() {
        let amount = 1234.56
        let expectedCurrencyCode = "USD"
        let result = formatCurrency(amount, code: expectedCurrencyCode)

        XCTAssertEqual(result, "$1,234.56", "Expected currency code to be USD")
    }

    // Test case for extractTransactionFeatures with a specific transaction
    func testExtractTransactionFeaturesWithSpecificTransaction() {
        let transaction = FinancialTransaction(title: "Groceries", amount: -100.0, date: Date(timeIntervalSinceNow: 0))
        let expectedFeatures = [
            "name": "groceries".lowercased(),
            "amount": abs(transaction.amount),
            "is_expense": true,
            "day_of_week": Calendar.current.component(.weekday, from: transaction.date),
            "month": Calendar.current.component(.month, from: transaction.date),
        ]

        XCTAssertEqual(
            fi_extractTransactionFeatures(transaction),
            expectedFeatures,
            "Expected extracted features to match the test data"
        )
    }

    // Test case for formatCurrency with optional currency code
    func testFormatCurrencyWithOptionalCode() {
        let amount = 1234.56
        let expectedCurrencyCode = "USD"
        let result = formatCurrency(amount, code: expectedCurrencyCode)

        XCTAssertEqual(result, "$1,234.56", "Expected currency code to be USD")
    }
}
