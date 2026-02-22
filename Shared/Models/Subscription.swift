//
//  Subscription.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import MomentumFinanceCore
import SwiftData

@Model
public final class Subscription {
    public var id: UUID
    public var name: String
    public var subscriptionDescription: String?
    public var amount: Decimal
    public var currency: String
    public var billingCycle: BillingCycle
    public var nextBillingDate: Date
    public var category: String?
    public var isActive: Bool
    public var autoRenew: Bool
    public var reminderDays: Int
    public var createdDate: Date
    public var lastModifiedDate: Date

    /// Relationships
    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.subscription)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        name: String,
        subscriptionDescription: String? = nil,
        amount: Decimal,
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

    /// Legacy convenience initializer retained for compatibility with older views/view-models.
    public convenience init(
        name: String,
        provider: String,
        amount: Decimal,
        billingCycle: BillingCycle,
        nextDueDate: Date,
        notes: String? = nil,
        isActive: Bool = true
    ) {
        self.init(
            name: name,
            subscriptionDescription: notes ?? provider,
            amount: amount,
            billingCycle: billingCycle,
            nextBillingDate: nextDueDate,
            isActive: isActive
        )
    }

    /// Calculate the monthly cost of this subscription
    public var monthlyCost: Decimal {
        switch billingCycle {
        case .daily:
            amount * 30.44
        case .weekly:
            amount * 4.33 // Average weeks per month
        case .monthly:
            amount
        case .quarterly:
            amount / 3
        case .semiAnnually:
            amount / 6
        case .yearly, .annually:
            amount / 12
        case .custom:
            amount
        }
    }

    /// Calculate the yearly cost of this subscription
    public var yearlyCost: Decimal {
        switch billingCycle {
        case .daily:
            amount * 365
        case .weekly:
            amount * 52
        case .monthly:
            amount * 12
        case .quarterly:
            amount * 4
        case .semiAnnually:
            amount * 2
        case .yearly, .annually:
            amount
        case .custom:
            amount * 12
        }
    }

    /// Check if a reminder should be sent
    public var shouldRemind: Bool {
        guard isActive else { return false }
        let reminderDate =
            Calendar.current
                .date(byAdding: .day, value: -reminderDays, to: nextBillingDate) ?? nextBillingDate
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

// Redundant local BillingCycle removed to use core definition.

private enum SubscriptionCompatibilityStore {
    nonisolated(unsafe) static var accounts: [UUID: FinancialAccount] = [:]
}

public extension Subscription {
    var nextDueDate: Date {
        get { nextBillingDate }
        set { nextBillingDate = newValue }
    }

    var provider: String {
        get { subscriptionDescription ?? "" }
        set { subscriptionDescription = newValue }
    }

    var notes: String? {
        get { subscriptionDescription }
        set { subscriptionDescription = newValue }
    }

    var account: FinancialAccount? {
        get { SubscriptionCompatibilityStore.accounts[id] }
        set {
            if let newValue {
                SubscriptionCompatibilityStore.accounts[id] = newValue
            } else {
                SubscriptionCompatibilityStore.accounts.removeValue(forKey: id)
            }
        }
    }

    func processPayment(modelContext: ModelContext) {
        guard isActive else { return }

        let paymentTransaction = FinancialTransaction(
            title: name,
            amount: amount,
            date: nextBillingDate,
            transactionType: .expense,
            category: category,
            notes: subscriptionDescription
        )
        paymentTransaction.subscription = self

        if let account {
            paymentTransaction.account = account
            account.updateBalance(with: paymentTransaction)
        }

        modelContext.insert(paymentTransaction)
        updateNextBillingDate()
        lastModifiedDate = Date()
    }
}

public extension Subscription {
    /// Sample data for previews and testing
    static var sample: Subscription {
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

    static var sampleAnnual: Subscription {
        Subscription(
            name: "Adobe Creative Cloud",
            subscriptionDescription: "Design software suite",
            amount: 599.99,
            currency: "USD",
            billingCycle: .annually,
            nextBillingDate: Calendar.current.date(byAdding: .month, value: 8, to: Date())
                ?? Date(),
            category: "Software",
            reminderDays: 7
        )
    }
}
