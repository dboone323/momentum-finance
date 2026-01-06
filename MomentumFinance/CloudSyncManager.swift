
import CloudKit
import Combine

// Enhancement #79: iCloud Sync

@MainActor
protocol CloudDatabaseProtocol {
    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping @Sendable ([CKRecord]?, Error?) -> Void)
    func save(_ record: CKRecord, completionHandler: @escaping @Sendable (CKRecord?, Error?) -> Void)
}

extension CKDatabase: CloudDatabaseProtocol {}

@MainActor
class CloudSyncManager: ObservableObject {
    // private let container = CKContainer.default() // Not used directly
    private let database: CloudDatabaseProtocol
    @Published var records: [CKRecord] = []

    init(database: CloudDatabaseProtocol = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }

    func fetchRecords() {
        let query = CKQuery(recordType: "Transaction", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            if let records = records {
                DispatchQueue.main.async {
                    self?.records = records
                }
            }
        }
    }

    func saveRecord(record: CKRecord) {
        database.save(record) { record, error in
            if let error = error {
                print("Error saving record: \(error)")
            } else {
                print("Record saved successfully")
            }
        }
    }
}
