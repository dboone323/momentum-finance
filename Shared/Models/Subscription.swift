import Foundation
import SwiftData

public enum BillingCycle: String, Codable, CaseIterable {
	case daily, weekly, monthly, quarterly, yearly
}

@Model
public final class Subscription {
	public var id: UUID
	public var name: String
	public var amount: Double
	public var provider: String
	public var billingCycle: BillingCycle
	public var nextDueDate: Date
	public var isActive: Bool
	public var category: ExpenseCategory?
	public var account: FinancialAccount?
	public var notes: String?

	public init(
		id: UUID = UUID(),
		name: String,
		amount: Double,
		provider: String = "",
		billingCycle: BillingCycle = .monthly,
		nextDueDate: Date = Date(),
		isActive: Bool = true,
		category: ExpenseCategory? = nil,
		account: FinancialAccount? = nil,
		notes: String? = nil
	) {
		self.id = id
		self.name = name
		self.amount = amount
		self.provider = provider
		self.billingCycle = billingCycle
		self.nextDueDate = nextDueDate
		self.isActive = isActive
		self.category = category
		self.account = account
		self.notes = notes
	}

	/// Advance the next due date based on billing cycle and optionally deduct from account.
	public func processPayment() {
		if let account {
			account.balance -= amount
		}

		let calendar = Calendar.current
		let components: DateComponents
		switch billingCycle {
		case .daily: components = DateComponents(day: 1)
		case .weekly: components = DateComponents(day: 7)
		case .monthly: components = DateComponents(month: 1)
		case .quarterly: components = DateComponents(month: 3)
		case .yearly: components = DateComponents(year: 1)
		}

		self.nextDueDate = calendar.date(byAdding: components, to: self.nextDueDate) ?? self.nextDueDate
	}
}
