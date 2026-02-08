import Foundation

public enum TransactionType: String, Codable, CaseIterable {
	case income, expense, transfer
}

// Legacy alias maintained for build graph compatibility.
public typealias Transaction = FinancialTransaction
