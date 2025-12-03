import XCTest
@testable import MomentumFinance

class DataImportHelpersTests: XCTestCase {
    // Test setup

    // Test teardown

    // Test public method: importData
    func testImportData() {
        // GIVEN
        let testData = [
            // Define your test data here, ensuring it's specific and realistic
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            let result = DataImporter.importData(testData)

            // THEN
            XCTAssertEqual(result.count, testData.count) { expected, actual in
                XCTAssertEqual(expected.key, actual.key) && XCTAssertEqual(expected.anotherKey, actual.anotherKey)
            }
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

    // Test public property: currentData
    func testCurrentData() {
        // GIVEN
        let testData = [
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            let result = DataImporter.importData(testData)

            // THEN
            XCTAssertEqual(result.count, testData.count) { expected, actual in
                XCTAssertEqual(expected.key, actual.key) && XCTAssertEqual(expected.anotherKey, actual.anotherKey)
            }
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

    // Test public method: exportData
    func testExportData() {
        // GIVEN
        let testData = [
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            let result = DataImporter.exportData(testData)

            // THEN
            XCTAssertEqual(result.count, testData.count) { expected, actual in
                XCTAssertEqual(expected.key, actual.key) && XCTAssertEqual(expected.anotherKey, actual.anotherKey)
            }
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

    // Test public property: importedData
    func testImportedData() {
        // GIVEN
        let testData = [
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            let result = DataImporter.importData(testData)

            // THEN
            XCTAssertEqual(result.count, testData.count) { expected, actual in
                XCTAssertEqual(expected.key, actual.key) && XCTAssertEqual(expected.anotherKey, actual.anotherKey)
            }
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

    // Test public method: clearData
    func testClearData() {
        // GIVEN
        let testData = [
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            DataImporter.importData(testData)
            DataImporter.clearData()

            // THEN
            XCTAssertEqual(DataImporter.currentData.count, 0)
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

    // Test public method: validateData
    func testValidateData() {
        // GIVEN
        let testData = [
            ["key": "value1", "anotherKey": "anotherValue"],
            ["key2": "value2", "anotherKey2": "anotherValue2"],
        ]

        // WHEN
        do {
            let result = DataImporter.importData(testData)

            // THEN
            XCTAssertEqual(result.count, testData.count) { expected, actual in
                XCTAssertEqual(expected.key, actual.key) && XCTAssertEqual(expected.anotherKey, actual.anotherKey)
            }
        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }

}
