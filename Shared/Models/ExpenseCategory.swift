import Foundation
import SwiftData

@Model
public final class ExpenseCategory {
	public var id: UUID
	public var name: String
	public var iconName: String

	public init(id: UUID = UUID(), name: String, iconName: String = "tag") {
		self.id = id
		self.name = name
		self.iconName = iconName
	}

	/// Placeholder spending calculator for the category.
	public func totalSpent(for _: Date) -> Double {
		// Full implementation would aggregate transactions for the month.
		return 0
	}
}
