//
// FinancialValidator.swift
// MomentumFinance
//
// Service for validating financial data integrity
//

import Foundation

class FinancialValidator {
    static let shared = FinancialValidator()

    enum ValidationError: Error {
        case negativeBalance
        case invalidDate
        case orphanTransaction
        case duplicateTransaction
    }

    func validateTransaction(_ transaction: Transaction) -> [ValidationError] {
        var errors: [ValidationError] = []

        if transaction.amount == 0 {
            // Warning: Zero amount transaction
        }

        if transaction.date > Date() {
            // Warning: Future transaction
        }

        return errors
    }

    func validateAccountBalance(accountBalance: Decimal, transactions: [Transaction]) -> Bool {
        let calculatedBalance = transactions.reduce(0) { $0 + $1.amount }
        return abs(accountBalance - calculatedBalance) < 0.01
    }
}
