import MomentumFinanceCore
import XCTest

final class DataImporterErrorTests: XCTestCase {
    func testImportErrorDescriptionsAreUserFriendly() {
        XCTAssertEqual(
            ImportError.invalidAmountFormat("BAD").errorDescription,
            "Invalid amount format: BAD."
        )
        XCTAssertEqual(
            ImportError.missingRequiredField("date").errorDescription,
            "CSV is missing required field: date."
        )
    }

    func testImportResultCapturesSuccessAndFailureCounts() {
        let result = ImportResult(
            success: false,
            itemsImported: 2,
            itemsFailed: 1,
            errors: ["Row 3: Invalid amount"],
            warnings: ["Row 2: Missing category"]
        )

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertEqual(result.itemsFailed, 1)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.warnings.count, 1)
    }
}
