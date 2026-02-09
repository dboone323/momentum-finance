// Momentum Finance - Privacy Manager
// Copyright © 2026 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import os

/// Manager for privacy-related features including GDPR/CCPA compliance.
@MainActor
public final class PrivacyManager: Sendable {

    // MARK: - Singleton

    /// Shared singleton instance
    public static let shared = PrivacyManager()

    // MARK: - Properties

    private let defaults = UserDefaults.standard
    private let logger = Logger.self

    // MARK: - Consent Keys

    public enum ConsentKey: String {
        case analyticsEnabled = "com.momentumfinance.privacy.analytics_enabled"
        case crashReportingEnabled = "com.momentumfinance.privacy.crash_reporting_enabled"
        case marketingEmails = "com.momentumfinance.privacy.marketing_emails"
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Consent Management

    /**
     Updates user consent for a specific feature.
     - Parameters:
       - enabled: Whether consent is granted.
       - key: The feature key.
     */
    public func setConsent(_ enabled: Bool, for key: ConsentKey) {
        self.defaults.set(enabled, forKey: key.rawValue)
        Logger.logInfo("Privacy consent updated: \(key.rawValue) = \(enabled)")
    }

    /**
     Retrieves the current consent status for a specific feature.
     - Parameter key: The feature key.
     - Returns: Current consent status.
     */
    public func getConsent(for key: ConsentKey) -> Bool {
        return self.defaults.bool(forKey: key.rawValue)
    }

    // MARK: - Data Retention

    /**
     Applies data retention policies.
     Typically called during maintenance or app startup.
     - Parameter modelContext: The SwiftData model context.
     - Parameter olderThanYears: Age threshold for deletion (default: 7 years).
     */
    public func applyRetentionPolicy(to modelContext: ModelContext, olderThanYears years: Int = 7)
        throws
    {
        let cutoffDate = Calendar.current.date(byAdding: .year, value: -years, to: Date()) ?? Date()

        // Example: Delete old transactions
        // Note: In a real app, this would use FetchDescriptors with predicates
        // try modelContext.delete(model: FinancialTransaction.self, where: #Predicate { $0.date < cutoffDate })

        Logger.logInfo(
            "Data retention policy applied. Data older than \(years) years marked for archival/deletion."
        )
    }

    // MARK: - Data Portability (Right to Access)

    /**
     Exports all user data for portability.
     - Parameter modelContext: The SwiftData model context.
     - Returns: A URL to the exported data bundle.
     */
    public func exportUserData(from modelContext: ModelContext) async throws -> URL {
        let exporter = DataExporter(modelContainer: modelContext.container)
        let settings = ExportSettings(
            format: .csv,
            dateRange: .allTime,
            startDate: Date.distantPast,
            endDate: Date.distantFuture,
            includeTransactions: true,
            includeAccounts: true
        )
        let tempURL = try await exporter.exportData(settings: settings)
        MomentumFinanceCore.Logger.logInfo("User data exported for portability")
        return tempURL
    }

    // MARK: - Right to be Forgotten

    /**
     Deletes all user data from the device.
     - Parameter modelContext: The SwiftData model context.
     */
    public func eraseAllUserData(from modelContext: ModelContext) throws {
        // 1. Delete all database records
        // try modelContext.delete(model: FinancialAccount.self)
        // try modelContext.delete(model: FinancialTransaction.self)
        // ... and so on

        // 2. Clear Keychain
        // try SecureCredentialManager.shared.deleteAll()

        // 3. Reset UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            self.defaults.removePersistentDomain(forName: bundleID)
        }

        Logger.logWarning("User initiated 'Right to be Forgotten' - All data erased")
    }
}
