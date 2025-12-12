
import CloudKit
import Combine

// Enhancement #79: iCloud Sync
class CloudSyncManager: ObservableObject {
    private let container = CKContainer.default()
    private let database = CKContainer.default().privateCloudDatabase
    @Published var records: [CKRecord] = []

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
