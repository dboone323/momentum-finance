import CloudKit
@testable import MomentumFinance
import XCTest

@MainActor
final class MockCloudDatabase: CloudDatabaseProtocol {
    var savedRecords: [CKRecord] = []
    var recordsToReturn: [CKRecord] = []

    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping @Sendable ([CKRecord]?, Error?) -> Void) {
        completionHandler(recordsToReturn, nil)
    }

    func save(_ record: CKRecord, completionHandler: @escaping @Sendable (CKRecord?, Error?) -> Void) {
        savedRecords.append(record)
        completionHandler(record, nil)
    }
}

@MainActor
final class CloudSyncManagerTests: XCTestCase {
    var manager: CloudSyncManager!
    var mockDB: MockCloudDatabase!

    override func setUp() {
        super.setUp()
        mockDB = MockCloudDatabase()
        manager = CloudSyncManager(database: mockDB)
    }

    func testFetchRecords() {
        let record = CKRecord(recordType: "Transaction")
        mockDB.recordsToReturn = [record]

        let expectation = XCTestExpectation(description: "Fetch records")

        let cancellable = manager.$records.sink { records in
            if !records.isEmpty {
                XCTAssertEqual(records.count, 1)
                expectation.fulfill()
            }
        }

        manager.fetchRecords()

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testSaveRecord() {
        let record = CKRecord(recordType: "Transaction")
        manager.saveRecord(record: record)

        XCTAssertEqual(mockDB.savedRecords.count, 1)
    }
}
