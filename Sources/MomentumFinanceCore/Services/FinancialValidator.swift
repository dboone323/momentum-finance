//
// FinancialValidator.swift
// MomentumFinance
//
// Service for validating financial data integrity
//

import Foundation

@MainActor class FinancialValidator {
    @MainActor static let shared = FinancialValidator()

    enum ValidationError: Error {
        case negativeBalance
        case invalidDate
        case orphanTransaction
        case duplicateTransaction
    }

    func validateTransaction(_ transaction: CoreTransaction) -> [ValidationError] {
        var errors: [ValidationError] = []

        if transaction.amount == 0 {
            // Warning: Zero amount transaction
        }

        if transaction.date > Date() {
            // Warning: Future transaction
        }

        return errors
    }

    func validateAccountBalance(accountBalance: Decimal, transactions: [CoreTransaction]) -> Bool {
        let calculatedBalance = transactions.reduce(0) { $0 + $1.amount }
        return abs(accountBalance - calculatedBalance) < 0.01
    }
}
