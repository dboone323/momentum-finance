import Foundation
import MomentumFinanceCore
import SwiftData

/// Savings goals data generator
@MainActor
final class SavingsGoalsGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    private struct GoalData {
        let name: String
        let target: Decimal
        let current: Decimal
        let targetDate: Date?
        let notes: String?
    }

    /// Generates sample savings goals with various targets and timelines
    func generate() {
        let calendar = Calendar.current
        let savingsGoals = [
            GoalData(
                name: "Emergency Fund",
                target: 10000 as Decimal,
                current: 3500 as Decimal,
                targetDate: calendar.date(byAdding: .month, value: 12, to: Date()),
                notes: nil
            ),
            GoalData(
                name: "Vacation Fund",
                target: 5000 as Decimal,
                current: 1200 as Decimal,
                targetDate: calendar.date(byAdding: .month, value: 8, to: Date()),
                notes: nil
            ),
            GoalData(
                name: "New Car",
                target: 25000 as Decimal,
                current: 8500 as Decimal,
                targetDate: calendar.date(byAdding: .month, value: 24, to: Date()),
                notes: nil
            ),
            GoalData(
                name: "Home Down Payment",
                target: 50000 as Decimal,
                current: 15000 as Decimal,
                targetDate: calendar.date(byAdding: .month, value: 36, to: Date()),
                notes: "20% down payment for first home"
            ),
            GoalData(
                name: "Retirement Boost",
                target: 15000 as Decimal,
                current: 2000 as Decimal,
                targetDate: calendar.date(byAdding: .year, value: 2, to: Date()),
                notes: "Extra contribution to retirement account"
            ),
        ]

        for goal in savingsGoals {
            let newGoal = SavingsGoal(
                name: goal.name,
                targetAmount: goal.target,
                currentAmount: goal.current,
                targetDate: goal.targetDate ?? Date(),
                notes: goal.notes ?? ""
            )
            // Note: SavingsGoal model might not have notes field based on usage, leaving it out if so.
            // If it does, we can add: newGoal.notes = goal.notes

            self.modelContext.insert(newGoal)
        }

        try? self.modelContext.save()
    }
}
