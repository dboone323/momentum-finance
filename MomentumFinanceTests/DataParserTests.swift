import XCTest
@testable import MomentumFinance

class DataParserTests: XCTestCase {
    /// Test parsing date strings
    func testParseDate() {
        let dateString = "2023-10-05"
        let expectedDate = DateComponents(year: 2023, month: 10, day: 5).date!

        do {
            let parsedDate = DataParser.parseDate(dateString)
            XCTAssertEqual(parsedDate, expectedDate)
        } catch {
            XCTFail("Failed to parse date: \(dateString)")
        }
    }

    func testParseDateInvalidFormat() {
        let dateString = "10/05/2023"
        do {
            DataParser.parseDate(dateString)
            XCTFail("Expected error for invalid date format")
        } catch let ImportError.invalidDateFormat(errorMessage) {
            XCTAssertEqual(errorMessage, "Invalid date format: \(dateString)")
        }
    }

    /// Test parsing amount strings
    func testParseAmount() {
        let amountString = "$100.50"
        let expectedAmount = 100.50

        do {
            let parsedAmount = DataParser.parseAmount(amountString)
            XCTAssertEqual(parsedAmount, expectedAmount)
        } catch {
            XCTFail("Failed to parse amount: \(amountString)")
        }
    }

    func testParseAmountInvalidFormat() {
        let amountString = "100,50"
        do {
            DataParser.parseAmount(amountString)
            XCTFail("Expected error for invalid amount format")
        } catch let ImportError.invalidAmountFormat(errorMessage) {
            XCTAssertEqual(errorMessage, "Invalid amount format: \(amountString)")
        }
    }

    /// Test parsing transaction type
    func testParseTransactionTypeIncome() {
        let typeString = "Salary"
        let expectedType = .income

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: 5000.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for income")
        }
    }

    func testParseTransactionTypeExpense() {
        let typeString = "Payment"
        let expectedType = .expense

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: -200.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for expense")
        }
    }

    func testParseTransactionTypeInvalidType() {
        let typeString = "Unknown"
        let expectedType = .expense

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: 100.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Expected error for invalid transaction type")
        }
    }

    /// Test parsing with different amounts
    func testParseTransactionTypeWithPositiveAmount() {
        let typeString = "Salary"
        let expectedType = .income

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: 5000.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for positive amount")
        }
    }

    func testParseTransactionTypeWithNegativeAmount() {
        let typeString = "Payment"
        let expectedType = .expense

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: -200.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for negative amount")
        }
    }

    /// Test parsing with zero amount
    func testParseTransactionTypeWithZeroAmount() {
        let typeString = "Salary"
        let expectedType = .income

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: 0.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for zero amount")
        }
    }

    /// Test parsing with negative amount
    func testParseTransactionTypeWithNegativeAmount() {
        let typeString = "Payment"
        let expectedType = .expense

        do {
            let parsedType = DataParser.parseTransactionType(typeString, amount: -200.0)
            XCTAssertEqual(parsedType, expectedType)
        } catch {
            XCTFail("Failed to parse transaction type for negative amount")
        }
    }
}
