import Foundation
import SwiftData

@Model
public final class Budget {
	public var id: UUID
	public var name: String
	public var limitAmount: Double
	public var spentAmount: Double
	public var month: Date
	public var category: ExpenseCategory?
	public var rolloverEnabled: Bool
	public var maxRolloverPercentage: Double
	public var rolledOverAmount: Double
	public var createdDate: Date

	public init(
		id: UUID = UUID(),
		name: String,
		limitAmount: Double,
		spentAmount: Double = 0,
		month: Date = Date(),
		category: ExpenseCategory? = nil,
		rolloverEnabled: Bool = false,
		maxRolloverPercentage: Double = 0,
		rolledOverAmount: Double = 0,
		createdDate: Date = Date()
	) {
		self.id = id
		self.name = name
		self.limitAmount = limitAmount
		self.spentAmount = spentAmount
		self.month = month
		self.category = category
		self.rolloverEnabled = rolloverEnabled
		self.maxRolloverPercentage = maxRolloverPercentage
		self.rolledOverAmount = rolledOverAmount
		self.createdDate = createdDate
	}

	public var remainingAmount: Double { self.limitAmount - self.spentAmount }
	public var effectiveLimit: Double { self.limitAmount + self.rolledOverAmount }

	public var isOverBudget: Bool { self.spentAmount > self.limitAmount }

	public func calculateRolloverAmount() -> Double {
		guard rolloverEnabled else { return 0 }
		let allowedRollover = limitAmount * (maxRolloverPercentage / 100)
		return max(0, min(self.remainingAmount, allowedRollover))
	}

	public func createNextPeriodBudget(for nextMonth: Date) -> Budget {
		let next = Budget(
			name: self.name,
			limitAmount: self.limitAmount,
			spentAmount: 0,
			month: nextMonth,
			category: self.category,
			rolloverEnabled: self.rolloverEnabled,
			maxRolloverPercentage: self.maxRolloverPercentage,
			rolledOverAmount: 0
		)
		next.rolledOverAmount = self.calculateRolloverAmount()
		return next
	}
}
