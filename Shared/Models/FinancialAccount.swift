//
//  FinancialAccount.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class FinancialAccount {
    public var id: UUID
    public var name: String
    public var accountType: AccountType
    public var institutionName: String?
    public var accountNumber: String?
    public var balance: Double
    public var currency: String
    public var isActive: Bool
    public var colorHex: String?
    public var iconName: String?
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.account)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        name: String,
        accountType: AccountType,
        institutionName: String? = nil,
        accountNumber: String? = nil,
        balance: Double = 0,
        currency: String = "USD",
        isActive: Bool = true,
        colorHex: String? = nil,
        iconName: String? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.accountType = accountType
        self.institutionName = institutionName
        self.accountNumber = accountNumber
        self.balance = balance
        self.currency = currency
        self.isActive = isActive
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Formatted balance string with currency
    public var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
    }

    /// Calculate total income for this account in a date range
    public func totalIncome(in dateRange: ClosedRange<Date>? = nil) -> Double {
        let relevantTransactions = transactions.filter { transaction in
            transaction.transactionType == .income &&
                (dateRange?.contains(transaction.date) ?? true)
        }
        return relevantTransactions.reduce(0) { $0 + $1.amount }
    }

    /// Calculate total expenses for this account in a date range
    public func totalExpenses(in dateRange: ClosedRange<Date>? = nil) -> Double {
        let relevantTransactions = transactions.filter { transaction in
            transaction.transactionType == .expense &&
                (dateRange?.contains(transaction.date) ?? true)
        }
        return relevantTransactions.reduce(0) { $0 + $1.amount }
    }

    /// Calculate net flow (income - expenses) for this account in a date range
    public func netFlow(in dateRange: ClosedRange<Date>? = nil) -> Double {
        totalIncome(in: dateRange) - totalExpenses(in: dateRange)
    }

    /// Update balance with a transaction
    public func updateBalance(with transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        case .transfer:
            // For transfers, the balance change depends on whether this is the source or destination
            // This would need to be handled by the transfer logic
            break
        }
        lastModifiedDate = Date()
    }

    /// Check if account is overdrawn
    public var isOverdrawn: Bool {
        balance < 0
    }

    /// Get account type display name
    public var accountTypeDisplayName: String {
        accountType.displayName
    }

    /// Get masked account number for display
    public var maskedAccountNumber: String? {
        guard let accountNumber else { return nil }
        let lastFour = String(accountNumber.suffix(4))
        return "****\(lastFour)"
    }
}

/// Account types
public enum AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case investment = "Investment"
    case loan = "Loan"
    case cash = "Cash"
    case other = "Other"

    public var displayName: String {
        rawValue
    }

    public var defaultColorHex: String {
        switch self {
        case .checking: "#007AFF" // Blue
        case .savings: "#34C759" // Green
        case .creditCard: "#FF3B30" // Red
        case .investment: "#AF52DE" // Purple
        case .loan: "#FF9500" // Orange
        case .cash: "#FFCC00" // Yellow
        case .other: "#8E8E93" // Gray
        }
    }

    public var defaultIconName: String {
        switch self {
        case .checking: "building.columns.fill"
        case .savings: "banknote.fill"
        case .creditCard: "creditcard.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .loan: "dollarsign.circle.fill"
        case .cash: "banknote"
        case .other: "circle.fill"
        }
    }

    public var isAsset: Bool {
        switch self {
        case .checking, .savings, .investment, .cash:
            true
        case .creditCard, .loan, .other:
            false
        }
    }

    public var isLiability: Bool {
        switch self {
        case .creditCard, .loan:
            true
        case .checking, .savings, .investment, .cash, .other:
            false
        }
    }
}

public extension FinancialAccount {
    /// Sample data for previews and testing
    static var sampleChecking: FinancialAccount {
        FinancialAccount(
            name: "Main Checking",
            accountType: .checking,
            institutionName: "Chase Bank",
            accountNumber: "1234567890",
            balance: 5420.50,
            currency: "USD",
            colorHex: "#007AFF",
            iconName: "building.columns.fill"
        )
    }

    static var sampleSavings: FinancialAccount {
        FinancialAccount(
            name: "Emergency Fund",
            accountType: .savings,
            institutionName: "Chase Bank",
            accountNumber: "0987654321",
            balance: 15000.00,
            currency: "USD",
            colorHex: "#34C759",
            iconName: "banknote.fill"
        )
    }

    static var sampleCreditCard: FinancialAccount {
        FinancialAccount(
            name: "Chase Freedom",
            accountType: .creditCard,
            institutionName: "Chase Bank",
            accountNumber: "1111222233334444",
            balance: -1250.75,
            currency: "USD",
            colorHex: "#FF3B30",
            iconName: "creditcard.fill"
        )
    }
}
