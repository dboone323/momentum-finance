//
//  Subscription.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class Subscription {
    public var id: UUID
    public var name: String
    public var subscriptionDescription: String?
    public var amount: Double
    public var currency: String
    public var billingCycle: BillingCycle
    public var nextBillingDate: Date
    public var category: String?
    public var isActive: Bool
    public var autoRenew: Bool
    public var reminderDays: Int
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.subscription)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        name: String,
        subscriptionDescription: String? = nil,
        amount: Double,
        currency: String = "USD",
        billingCycle: BillingCycle,
        nextBillingDate: Date,
        category: String? = nil,
        isActive: Bool = true,
        autoRenew: Bool = true,
        reminderDays: Int = 3,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.subscriptionDescription = subscriptionDescription
        self.amount = amount
        self.currency = currency
        self.billingCycle = billingCycle
        self.nextBillingDate = nextBillingDate
        self.category = category
        self.isActive = isActive
        self.autoRenew = autoRenew
        self.reminderDays = reminderDays
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Calculate the monthly cost of this subscription
    public var monthlyCost: Double {
        switch billingCycle {
        case .weekly:
            return amount * 4.33 // Average weeks per month
        case .monthly:
            return amount
        case .quarterly:
            return amount / 3
        case .semiAnnually:
            return amount / 6
        case .annually:
            return amount / 12
        case .custom(let interval):
            let daysInMonth = 30.44 // Average days per month
            return amount * (daysInMonth / Double(interval))
        }
    }

    /// Calculate the yearly cost of this subscription
    public var yearlyCost: Double {
        switch billingCycle {
        case .weekly:
            return amount * 52
        case .monthly:
            return amount * 12
        case .quarterly:
            return amount * 4
        case .semiAnnually:
            return amount * 2
        case .annually:
            return amount
        case .custom(let interval):
            return amount / Double(interval) * 365.25 // Average days per year
        }
    }

    /// Check if a reminder should be sent
    public var shouldRemind: Bool {
        guard isActive else { return false }
        let reminderDate = Calendar.current.date(byAdding: .day, value: -reminderDays, to: nextBillingDate) ?? nextBillingDate
        return Date() >= reminderDate && Date() < nextBillingDate
    }

    /// Calculate days until next billing
    public var daysUntilNextBilling: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextBillingDate).day ?? 0
    }

    /// Update the next billing date based on the billing cycle
    public func updateNextBillingDate() {
        guard let newDate = billingCycle.nextDate(from: nextBillingDate) else { return }
        nextBillingDate = newDate
        lastModifiedDate = Date()
    }

    /// Cancel the subscription
    public func cancel() {
        isActive = false
        autoRenew = false
        lastModifiedDate = Date()
    }

    /// Reactivate the subscription
    public func reactivate() {
        isActive = true
        lastModifiedDate = Date()
    }
}

/// Billing cycle options for subscriptions
public enum BillingCycle: Codable, Hashable {
    case weekly
    case monthly
    case quarterly
    case semiAnnually
    case annually
    case custom(days: Int)

    public var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiAnnually: return "Semi-Annually"
        case .annually: return "Annually"
        case .custom(let days): return "Every \(days) days"
        }
    }

    public var days: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30
        case .quarterly: return 90
        case .semiAnnually: return 180
        case .annually: return 365
        case .custom(let days): return days
        }
    }

    /// Calculate the next billing date from a given date
    public func nextDate(from date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: date)
    }
}

extension Subscription {
    /// Sample data for previews and testing
    public static var sample: Subscription {
        Subscription(
            name: "Netflix Premium",
            subscriptionDescription: "Streaming service subscription",
            amount: 15.99,
            currency: "USD",
            billingCycle: .monthly,
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            category: "Entertainment",
            reminderDays: 3
        )
    }

    public static var sampleAnnual: Subscription {
        Subscription(
            name: "Adobe Creative Cloud",
            subscriptionDescription: "Design software suite",
            amount: 599.99,
            currency: "USD",
            billingCycle: .annually,
            nextBillingDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()) ?? Date(),
            category: "Software",
            reminderDays: 7
        )
    }
}
