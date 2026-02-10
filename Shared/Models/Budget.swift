//
//  Budget.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class Budget {
    public var id: UUID
    public var name: String
    public var budgetDescription: String?
    public var totalAmount: Double
    public var spentAmount: Double
    public var period: BudgetPeriod
    public var startDate: Date
    public var endDate: Date
    public var isActive: Bool
    public var category: String?
    public var colorHex: String?
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.budget)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        name: String,
        budgetDescription: String? = nil,
        totalAmount: Double,
        spentAmount: Double = 0,
        period: BudgetPeriod,
        startDate: Date,
        endDate: Date,
        isActive: Bool = true,
        category: String? = nil,
        colorHex: String? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.budgetDescription = budgetDescription
        self.totalAmount = totalAmount
        self.spentAmount = spentAmount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.category = category
        self.colorHex = colorHex
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Calculate remaining budget amount
    public var remainingAmount: Double {
        max(totalAmount - spentAmount, 0)
    }

    /// Calculate budget utilization as a percentage (0-100)
    public var utilizationPercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return min((spentAmount / totalAmount) * 100, 100)
    }

    /// Check if budget is over limit
    public var isOverBudget: Bool {
        spentAmount > totalAmount
    }

    /// Check if budget is nearing limit (within 10%)
    public var isNearLimit: Bool {
        let threshold = totalAmount * 0.9
        return spentAmount >= threshold && spentAmount <= totalAmount
    }

    /// Calculate daily spending rate
    public var dailySpendingRate: Double {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 1
        guard daysRemaining > 0 else { return remainingAmount }
        return remainingAmount / Double(daysRemaining)
    }

    /// Calculate days remaining in the budget period
    public var daysRemaining: Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0, 0)
    }

    /// Check if the budget period has expired
    public var isExpired: Bool {
        Date() > endDate
    }

    /// Add a transaction amount to the spent total
    public func addTransaction(amount: Double) {
        spentAmount += amount
        lastModifiedDate = Date()
    }

    /// Remove a transaction amount from the spent total
    public func removeTransaction(amount: Double) {
        spentAmount = max(spentAmount - amount, 0)
        lastModifiedDate = Date()
    }

    /// Reset the budget for a new period
    public func resetForNewPeriod(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        spentAmount = 0
        lastModifiedDate = Date()
    }

    /// Update the budget amount
    public func updateAmount(_ newAmount: Double) {
        totalAmount = newAmount
        lastModifiedDate = Date()
    }
}

/// Budget period types
public enum BudgetPeriod: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case annually = "Annually"
    case custom = "Custom"

    public var displayName: String {
        rawValue
    }

    /// Calculate the next period dates from a given date
    public func nextPeriod(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current

        switch self {
        case .weekly:
            let start = date.startOfWeek
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
            return (start, end)

        case .monthly:
            let start = date.startOfMonth
            let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? start
            return (start, end)

        case .quarterly:
            let start = date.startOfQuarter
            let end = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: start) ?? start
            return (start, end)

        case .semiAnnually:
            let start = date.startOfSemester
            let end = calendar.date(byAdding: DateComponents(month: 6, day: -1), to: start) ?? start
            return (start, end)

        case .annually:
            let start = date.startOfYear
            let end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: start) ?? start
            return (start, end)

        case .custom:
            // For custom periods, return the same dates (should be handled by user)
            return (date, date)
        }
    }
}

extension Date {
    var startOfWeek: Date {
        Calendar.current
            .date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    var startOfQuarter: Date {
        let month = Calendar.current.component(.month, from: self)
        let quarterStartMonth = ((month - 1) / 3) * 3 + 1
        return Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: self),
            month: quarterStartMonth,
            day: 1
        )) ?? self
    }

    var startOfSemester: Date {
        let month = Calendar.current.component(.month, from: self)
        let semesterStartMonth = month <= 6 ? 1 : 7
        return Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: self),
            month: semesterStartMonth,
            day: 1
        )) ?? self
    }

    var startOfYear: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year], from: self)) ?? self
    }
}

public extension Budget {
    /// Sample data for previews and testing
    static var sample: Budget {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate

        return Budget(
            name: "Monthly Expenses",
            budgetDescription: "General monthly spending budget",
            totalAmount: 2000,
            spentAmount: 1450,
            period: .monthly,
            startDate: startDate,
            endDate: endDate,
            category: "General",
            colorHex: "#007AFF"
        )
    }

    static var sampleOverBudget: Budget {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate

        return Budget(
            name: "Dining Out",
            budgetDescription: "Restaurant and food delivery budget",
            totalAmount: 400,
            spentAmount: 520,
            period: .monthly,
            startDate: startDate,
            endDate: endDate,
            category: "Food",
            colorHex: "#FF3B30"
        )
    }
}
