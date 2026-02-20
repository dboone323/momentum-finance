import XCTest
@testable import MomentumFinance

final class DataImporterErrorTests: XCTestCase {
    func testEmptyHeadersDoNotMapRequiredColumns() {
        let headers = CSVParser.parseCSVRow("")
        let mapping = CSVParser.mapColumns(headers: headers)

        XCTAssertNil(mapping.dateIndex)
        XCTAssertNil(mapping.titleIndex)
        XCTAssertNil(mapping.amountIndex)
    }

    func testInvalidAmountThrowsInvalidAmountFormat() {
        XCTAssertThrowsError(try DataParser.parseAmount("NOTNUM")) { error in
            guard case let ImportError.invalidAmountFormat(value) = error else {
                XCTFail("Expected invalidAmountFormat error, got \(error)")
                return
            }
            XCTAssertEqual(value, "NOTNUM")
        }
    }

    func testInvalidDateThrowsInvalidDateFormat() {
        XCTAssertThrowsError(try DataParser.parseDate("2025/99/99")) { error in
            guard case let ImportError.invalidDateFormat(value) = error else {
                XCTFail("Expected invalidDateFormat error, got \(error)")
                return
            }
            XCTAssertEqual(value, "2025/99/99")
        }
    }

    func testUnknownTransactionTypeFallsBackToAmountSign() {
        XCTAssertEqual(DataParser.parseTransactionType("", fallbackAmount: 100), .income)
        XCTAssertEqual(DataParser.parseTransactionType("", fallbackAmount: -5), .expense)
    }
}
