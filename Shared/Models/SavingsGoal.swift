//
//  SavingsGoal.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class SavingsGoal {
    public var id: UUID
    public var title: String
    public var goalDescription: String?
    public var targetAmount: Double
    public var currentAmount: Double
    public var targetDate: Date?
    public var createdDate: Date
    public var isCompleted: Bool
    public var priority: GoalPriority
    public var category: String?

    /// Relationships
    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.savingsGoal)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        title: String,
        goalDescription: String? = nil,
        targetAmount: Double,
        currentAmount: Double = 0,
        targetDate: Date? = nil,
        createdDate: Date = Date(),
        isCompleted: Bool = false,
        priority: GoalPriority = .medium,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.goalDescription = goalDescription
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.createdDate = createdDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
    }

    /// Legacy convenience initializer retained for compatibility with older views/view-models.
    public convenience init(
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        targetDate: Date = Date(),
        notes: String? = nil
    ) {
        self.init(
            title: name,
            goalDescription: notes,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate
        )
    }

    /// Calculate progress as a percentage (0-100)
    public var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min((currentAmount / targetAmount) * 100, 100)
    }

    /// Calculate remaining amount needed to reach the goal
    public var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }

    /// Check if the goal is on track based on target date
    public var isOnTrack: Bool {
        guard let targetDate else { return true }

        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        guard daysRemaining > 0 else { return currentAmount >= targetAmount }

        let requiredDailySavings = remainingAmount / Double(daysRemaining)
        // This is a simple heuristic - could be made more sophisticated
        return requiredDailySavings <= 50 // Assuming $50/day is reasonable
    }

    /// Mark the goal as completed
    public func markCompleted() {
        isCompleted = true
        currentAmount = targetAmount
    }

    /// Add an amount to the current savings
    public func addAmount(_ amount: Double) {
        currentAmount += amount
        if currentAmount >= targetAmount {
            isCompleted = true
        }
    }

    /// Legacy alias retained for older call sites.
    public func addFunds(_ amount: Double) {
        addAmount(amount)
    }
}

/// Priority levels for savings goals
public enum GoalPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    public var sortOrder: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .critical: 3
        }
    }
}

public extension SavingsGoal {
    // Backward-compatible aliases used by older views
    var name: String {
        get { title }
        set { title = newValue }
    }

    var notes: String? {
        get { goalDescription }
        set { goalDescription = newValue }
    }

    var formattedCurrentAmount: String {
        currentAmount.formatted(.currency(code: "USD"))
    }

    var formattedTargetAmount: String {
        targetAmount.formatted(.currency(code: "USD"))
    }

    var formattedRemainingAmount: String {
        remainingAmount.formatted(.currency(code: "USD"))
    }

    var daysRemaining: Int? {
        guard let targetDate else { return nil }
        return max(Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0, 0)
    }

    /// Sample data for previews and testing
    static var sample: SavingsGoal {
        SavingsGoal(
            title: "Emergency Fund",
            goalDescription: "6 months of expenses for financial security",
            targetAmount: 15000,
            currentAmount: 8500,
            targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
            priority: .high,
            category: "Emergency"
        )
    }

    static var sampleCompleted: SavingsGoal {
        SavingsGoal(
            title: "Vacation to Europe",
            goalDescription: "Summer vacation for the family",
            targetAmount: 5000,
            currentAmount: 5000,
            targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
            isCompleted: true,
            priority: .medium,
            category: "Travel"
        )
    }
}
