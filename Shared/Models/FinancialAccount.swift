import Foundation
import SwiftData

public enum AccountType: String, Codable, CaseIterable {
	case checking, savings, credit, investment, cash, other
}

@Model
public final class FinancialAccount {
	public var id: UUID
	public var name: String
	public var balance: Double
	public var iconName: String
	public var accountType: AccountType
	public var createdDate: Date
	public var transactions: [FinancialTransaction]?

	public init(
		id: UUID = UUID(),
		name: String,
		balance: Double = 0,
		iconName: String = "creditcard",
		accountType: AccountType = .checking,
		createdDate: Date = Date(),
		transactions: [FinancialTransaction]? = nil
	) {
		self.id = id
		self.name = name
		self.balance = balance
		self.iconName = iconName
		self.accountType = accountType
		self.createdDate = createdDate
		self.transactions = transactions
	}

	/// Adjust the balance based on a transaction's type and amount.
	public func updateBalance(for transaction: FinancialTransaction) {
		switch transaction.transactionType {
		case .income:
			self.balance += transaction.amount
		case .expense:
			self.balance -= transaction.amount
		case .transfer:
			// Transfer handling is contextual; keep balance unchanged for now.
			break
		}
	}
}
