//
// CloudSyncManager.swift
// MomentumFinanceCore
//

import CloudKit
import Combine
import Foundation

/// Protocol defining the interface for a cloud-backed database.
@MainActor
public protocol CloudDatabaseProtocol: Sendable {
    func perform(
        _ query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID?,
        completionHandler: @escaping @Sendable ([CKRecord]?, Error?) -> Void
    )
    func save(
        _ record: CKRecord, completionHandler: @escaping @Sendable (CKRecord?, Error?) -> Void
    )
}

extension CKDatabase: CloudDatabaseProtocol {}

/// Service for synchronizing application data with iCloud via CloudKit.
@MainActor
public class CloudSyncManager: ObservableObject, @unchecked Sendable {
    public static let shared = CloudSyncManager()
    
    private let database: CloudDatabaseProtocol
    @Published public var records: [CKRecord] = []

    public init(database: CloudDatabaseProtocol = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }

    /// Fetches transaction records from the cloud database.
    public func fetchRecords() {
        let query = CKQuery(recordType: "Transaction", predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            if let error {
                print("[CloudSync] Error fetching records: \(error)")
                return
            }

            guard let records else { return }

            Task { @MainActor [weak self] in
                self?.records = records
            }
        }
    }

    /// Saves a transaction record to the cloud database.
    public func saveRecord(record: CKRecord) {
        database.save(record) { _, error in
            if let error {
                print("[CloudSync] Error saving record: \(error)")
            } else {
                print("[CloudSync] Record saved successfully")
            }
        }
    }
}
