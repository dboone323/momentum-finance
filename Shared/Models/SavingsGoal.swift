import Foundation
import SwiftData

@Model
public final class SavingsGoal {
	public var id: UUID
	public var name: String
	public var targetAmount: Double
	public var currentAmount: Double
	public var targetDate: Date?
	public var notes: String?

	public init(
		id: UUID = UUID(),
		name: String,
		targetAmount: Double,
		currentAmount: Double = 0,
		targetDate: Date? = nil,
		notes: String? = nil
	) {
		self.id = id
		self.name = name
		self.targetAmount = targetAmount
		self.currentAmount = currentAmount
		self.targetDate = targetDate
		self.notes = notes
	}

	public var isCompleted: Bool { self.currentAmount >= self.targetAmount }
	public var progressPercentage: Double {
		guard targetAmount > 0 else { return 0 }
		return min(1.0, self.currentAmount / self.targetAmount)
	}

	public var formattedCurrentAmount: String {
		self.currentAmount.formatted(.currency(code: "USD"))
	}

	public var formattedTargetAmount: String {
		self.targetAmount.formatted(.currency(code: "USD"))
	}

	public var formattedRemainingAmount: String {
		let remaining = max(0, self.targetAmount - self.currentAmount)
		return remaining.formatted(.currency(code: "USD"))
	}

	public var daysRemaining: Int? {
		guard let targetDate else { return nil }
		let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day
		return days
	}

	public func addFunds(_ amount: Double) {
		self.currentAmount += amount
	}
}
