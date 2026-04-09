import MomentumFinanceCore
import XCTest

final class DataImporterErrorTests: XCTestCase {
    func testImportErrorDescriptionsAreUserFriendly() {
        let invalidDataMessage = ImportError.invalidData.errorDescription
        let decodingFailedMessage = ImportError.decodingFailed.errorDescription

        XCTAssertNotNil(invalidDataMessage)
        XCTAssertNotNil(decodingFailedMessage)
        XCTAssertFalse(invalidDataMessage?.isEmpty ?? true)
        XCTAssertFalse(decodingFailedMessage?.isEmpty ?? true)
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
