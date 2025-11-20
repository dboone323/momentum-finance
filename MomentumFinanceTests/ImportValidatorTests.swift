@testable import MomentumFinance
import XCTest

class ImportValidatorTests: XCTestCase {
    var modelContext: ModelContext!

    override func setUp() async throws {
        // Initialize the model context for testing
        let store = try await Store.create(inMemoryStore: true)
        self.modelContext = store.viewContext
    }

    override func tearDown() async throws {
        // Clean up after each test case
        await self.modelContext.deleteAll()
    }

    // Test isDuplicate method with a duplicate transaction
    func testIsDuplicateWithDuplicateTransaction() async throws {
        let transaction = FinancialTransaction(
            title: "Test Transaction",
            amount: 100.0,
            date: Date()
        )

        // Insert the transaction into the database
        await self.modelContext.save(transaction)

        // Validate that the transaction is not a duplicate
        await XCTAssertTrue(ImportValidator.isDuplicate(transaction))
    }

    // Test isDuplicate method with a non-duplicate transaction
    func testIsDuplicateWithNonDuplicateTransaction() async throws {
        let transaction = FinancialTransaction(
            title: "Test Transaction",
            amount: 200.0,
            date: Date()
        )

        // Insert the transaction into the database
        await self.modelContext.save(transaction)

        // Validate that the transaction is not a duplicate
        await XCTAssertFalse(ImportValidator.isDuplicate(FinancialTransaction(
            title: "Test Transaction",
            amount: 100.0,
            date: Date()
        )))
    }

    // Test validateRequiredFields method with missing required fields
    func testValidateRequiredFieldsWithMissingRequiredFields() throws {
        let fields = ["", "2023-06-05", "Test Transaction"]
        let columnMapping = CSVColumnMapping(dateIndex: 1, titleIndex: 2)

        do {
            try ImportValidator.validateRequiredFields(fields: fields, columnMapping: columnMapping)
            XCTFail("Expected ImportError.missingRequiredField")
        } catch ImportError.missingRequiredField {
            // Expected error
        }
    }

    // Test validateRequiredFields method with empty required field
    func testValidateRequiredFieldsWithEmptyRequiredField() throws {
        let fields = ["2023-06-05", "", "Test Transaction"]
        let columnMapping = CSVColumnMapping(dateIndex: 1, titleIndex: 2)

        do {
            try ImportValidator.validateRequiredFields(fields: fields, columnMapping: columnMapping)
            XCTFail("Expected ImportError.emptyRequiredField")
        } catch ImportError.emptyRequiredField {
            // Expected error
        }
    }

    // Test validateCSVFormat method with valid CSV content
    func testValidateCSVFormatWithValidCSVContent() throws {
        let csvContent = """
        date,title,amount
        2023-06-05,Test Transaction,100.0
        """

        do {
            let headers = try ImportValidator.validateCSVFormat(content: csvContent)
            XCTAssertEqual(headers, ["date", "title/description", "amount"])
        } catch ImportError.invalidFormat {
            XCTFail("Expected no error")
        }
    }

    // Test validateCSVFormat method with invalid CSV content
    func testValidateCSVFormatWithInvalidCSVContent() throws {
        let csvContent = """
        date,title,amount
        2023-06-05,,100.0
        """

        do {
            try ImportValidator.validateCSVFormat(content: csvContent)
            XCTFail("Expected ImportError.invalidFormat")
        } catch ImportError.invalidFormat {
            // Expected error
        }
    }

    // Test validateCSVFormat method with empty file content
    func testValidateCSVFormatWithEmptyFileContent() throws {
        let csvContent = ""

        do {
            try ImportValidator.validateCSVFormat(content: csvContent)
            XCTFail("Expected ImportError.emptyFile")
        } catch ImportError.emptyFile {
            // Expected error
        }
    }
}
