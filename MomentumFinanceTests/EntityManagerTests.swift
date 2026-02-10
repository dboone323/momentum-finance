import SwiftData
import XCTest
@testable import MomentumFinance

class EntityManagerTests: XCTestCase {
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await ModelContext.configure()
        self.modelContext = ModelContext.shared
    }

    override func tearDown() async throws {
        try await ModelContext.destroy()
    }

    // MARK: - Test getOrCreateAccount

    func testGetOrCreateAccountWithExistingAccount() async throws {
        // GIVEN
        let fields = ["Imported Account", "100.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)
        let expectedAccountName = "Imported Account"
        let expectedBalance = 100.00

        // WHEN
        let account = await EntityManager.getOrCreateAccount(from: fields, columnMapping: columnMapping)

        // THEN
        XCTAssertEqual(account.name, expectedAccountName)
        XCTAssertEqual(account.balance, expectedBalance)
    }

    func testGetOrCreateAccountWithNewAccount() async throws {
        // GIVEN
        let fields = ["New Account", "200.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)
        let expectedAccountName = "New Account"
        let expectedBalance = 200.00

        // WHEN
        let account = await EntityManager.getOrCreateAccount(from: fields, columnMapping: columnMapping)

        // THEN
        XCTAssertEqual(account.name, expectedAccountName)
        XCTAssertEqual(account.balance, expectedBalance)
    }

    func testGetOrCreateAccountWithInvalidData() async throws {
        // GIVEN
        let fields = ["", "300.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)

        // WHEN
        do {
            await EntityManager.getOrCreateAccount(from: fields, columnMapping: columnMapping)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid data in CSV file")
        }
    }

    // MARK: - Test getOrCreateCategory

    func testGetOrCreateCategoryWithExistingCategory() async throws {
        // GIVEN
        let fields = ["Other Income", "400.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)
        let expectedCategoryName = "Other Income"
        let expectedIconName = "folder.fill"

        // WHEN
        let category = await EntityManager.getOrCreateCategory(from: fields, columnMapping: columnMapping)

        // THEN
        XCTAssertEqual(category.name, expectedCategoryName)
        XCTAssertEqual(category.iconName, expectedIconName)
    }

    func testGetOrCreateCategoryWithNewCategory() async throws {
        // GIVEN
        let fields = ["Other Expenses", "500.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)
        let expectedCategoryName = "Other Expenses"
        let expectedIconName = "folder.fill"

        // WHEN
        let category = await EntityManager.getOrCreateCategory(from: fields, columnMapping: columnMapping)

        // THEN
        XCTAssertEqual(category.name, expectedCategoryName)
        XCTAssertEqual(category.iconName, expectedIconName)
    }

    func testGetOrCreateCategoryWithInvalidData() async throws {
        // GIVEN
        let fields = ["", "600.00"]
        let columnMapping = CSVColumnMapping(accountIndex: 0, categoryIndex: 1)

        // WHEN
        do {
            await EntityManager.getOrCreateCategory(from: fields, columnMapping: columnMapping)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid data in CSV file")
        }
    }

    // MARK: - Object Pooling

    func testObjectPooling() async throws {
        // GIVEN
        let expectedCount = 50

        // WHEN
        for _ in 1 ... expectedCount {
            let object = getPooledObject()
            XCTAssertNil(object)
        }

        // THEN
        XCTAssertEqual(objectPool.count, expectedCount)

        for _ in 1 ... expectedCount {
            let object = getPooledObject()
            XCTAssertNotNil(object)
        }
    }
}
