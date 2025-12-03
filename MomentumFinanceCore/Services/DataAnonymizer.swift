//
// DataAnonymizer.swift
// MomentumFinance
//
// Service for anonymizing data for export/debugging
//

import Foundation

class DataAnonymizer {
    static let shared = DataAnonymizer()

    func anonymizeTransaction(_ transaction: Transaction) -> Transaction {
        // Return a copy with sensitive fields redacted
        Transaction(
            amount: transaction.amount, // Keep amount for math checks
            date: transaction.date,
            note: "REDACTED",
            categoryId: transaction.categoryId,
            accountId: transaction.accountId
        )
    }

    func anonymizeAccount(_ account: Account) -> Account {
        Account(
            name: "Account \(account.id.uuidString.prefix(4))",
            balance: account.balance,
            type: account.type
        )
    }
}
