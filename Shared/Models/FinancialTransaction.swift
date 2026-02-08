import Foundation
import SwiftData

@Model
public final class FinancialTransaction {
	public var id: UUID
	public var title: String
	public var amount: Double
	public var date: Date
	public var category: ExpenseCategory?
	public var account: FinancialAccount?
	public var transactionType: TransactionType
	public var notes: String?

	public init(
		id: UUID = UUID(),
		title: String,
		amount: Double,
		date: Date = Date(),
		category: ExpenseCategory? = nil,
		account: FinancialAccount? = nil,
		transactionType: TransactionType = .expense,
		notes: String? = nil
	) {
		self.id = id
		self.title = title
		self.amount = amount
		self.date = date
		self.category = category
		self.account = account
		self.transactionType = transactionType
		self.notes = notes
	}

	public var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: self.date)
	}

	public var formattedAmount: String {
		self.amount.formatted(.currency(code: "USD"))
	}
}
