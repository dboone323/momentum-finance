//
// DataAnonymizer.swift
// MomentumFinance
//
// Service for anonymizing data for export/debugging
//

import Foundation

@MainActor
public final class DataAnonymizer {
    @MainActor public static let shared = DataAnonymizer()

    private init() {}

    /**
     Anonymizes a transaction for display or export.
     - Parameter transaction: The core transaction model.
     - Returns: An anonymized copy.
     */
    public func anonymizeTransaction(_ transaction: CoreTransaction) -> CoreTransaction {
        // Return a copy with sensitive fields redacted
        CoreTransaction(
            id: transaction.id,
            amount: transaction.amount, // Keep amount for math checks
            date: transaction.date,
            note: "REDACTED", // Redact notes as they may contain PII
            categoryId: transaction.categoryId,
            accountId: transaction.accountId
        )
    }

    /**
     Anonymizes an account for display or export.
     - Parameter account: The core account model.
     - Returns: An anonymized copy.
     */
    public func anonymizeAccount(_ account: CoreAccount) -> CoreAccount {
        CoreAccount(
            id: account.id,
            name: "Account \(account.id.uuidString.prefix(4))", // Use partial UUID for recognition
            balance: account.balance,
            type: account.type
        )
    }

    /**
     Bulk anonymization of transactions.
     - Parameter transactions: Array of core transactions.
     - Returns: Array of anonymized transactions.
     */
    public func anonymizeTransactions(_ transactions: [CoreTransaction]) -> [CoreTransaction] {
        transactions.map { self.anonymizeTransaction($0) }
    }

    /**
     Bulk anonymization of accounts.
     - Parameter accounts: Array of core accounts.
     - Returns: Array of anonymized accounts.
     */
    public func anonymizeAccounts(_ accounts: [CoreAccount]) -> [CoreAccount] {
        accounts.map { self.anonymizeAccount($0) }
    }
}
