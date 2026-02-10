//
//  Transaction.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// Simplified transaction model for basic operations
/// This is a lightweight version of FinancialTransaction for specific use cases
public struct Transaction: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var amount: Double
    public var date: Date
    public var type: TransactionType
    public var category: String?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        type: TransactionType,
        category: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.notes = notes
    }

    /// Signed amount (negative for expenses, positive for income)
    public var signedAmount: Double {
        switch type {
        case .income:
            amount
        case .expense:
            -amount
        case .transfer:
            amount
        }
    }

    /// Formatted amount string
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(abs(amount))"
    }

    /// Create a Transaction from a FinancialTransaction
    public init(from financialTransaction: FinancialTransaction) {
        self.id = financialTransaction.id
        self.title = financialTransaction.title
        self.amount = financialTransaction.amount
        self.date = financialTransaction.date
        self.type = financialTransaction.transactionType
        self.category = financialTransaction.category
        self.notes = financialTransaction.notes
    }

    /// Convert to FinancialTransaction
    public func toFinancialTransaction() -> FinancialTransaction {
        FinancialTransaction(
            id: id,
            title: title,
            amount: amount,
            date: date,
            transactionType: type,
            category: category,
            notes: notes
        )
    }
}

public extension Transaction {
    /// Sample data for previews and testing
    static var sampleIncome: Transaction {
        Transaction(
            title: "Salary Deposit",
            amount: 3500,
            date: Date(),
            type: .income,
            category: "Salary",
            notes: "Monthly salary payment"
        )
    }

    static var sampleExpense: Transaction {
        Transaction(
            title: "Grocery Shopping",
            amount: 85.50,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            type: .expense,
            category: "Groceries",
            notes: "Weekly grocery shopping"
        )
    }
}
