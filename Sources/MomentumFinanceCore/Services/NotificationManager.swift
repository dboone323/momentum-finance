import Foundation
import os
import OSLog
import SwiftData
@preconcurrency import UserNotifications

/// Manages smart notifications for budget limits and subscription due dates
@MainActor
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()

    @Published public var isNotificationPermissionGranted = false
    @Published public var pendingNotifications: [ScheduledNotification] = []

    private let center = UNUserNotificationCenter.current()
    private let logger = OSLog(
        subsystem: "com.MomentumFinance.Core", category: "Notifications"
    )

    // Component delegates
    private let permissionManager: NotificationPermissionManager
    private let budgetScheduler: BudgetNotificationScheduler
    private let subscriptionScheduler: SubscriptionNotificationScheduler
    private let goalScheduler: GoalNotificationScheduler

    private init() {
        // Initialize component delegates
        self.permissionManager = NotificationPermissionManager(logger: self.logger)
        self.budgetScheduler = BudgetNotificationScheduler(logger: self.logger)
        self.subscriptionScheduler = SubscriptionNotificationScheduler(logger: self.logger)
        self.goalScheduler = GoalNotificationScheduler(logger: self.logger)

        self.checkNotificationPermission()
        self.setupNotificationCategories()
    }

    // MARK: - Permission Management (Delegate to PermissionManager)

    public func requestNotificationPermission() async {
        let granted = await permissionManager.requestNotificationPermission()
        self.isNotificationPermissionGranted = granted
    }

    public func checkNotificationPermission() {
        Task { @MainActor in
            let granted = await permissionManager.checkNotificationPermissionAsync()
            self.isNotificationPermissionGranted = granted
        }
    }

    // MARK: - Smart Budget Notifications (Delegate to BudgetScheduler)

    public func schedulebudgetWarningNotifications(for budgets: [Budget]) {
        guard self.isNotificationPermissionGranted else { return }
        self.budgetScheduler.scheduleWarningNotifications(for: budgets)
    }

    // MARK: - Subscription Due Date Notifications (Delegate to SubscriptionScheduler)

    public func scheduleSubscriptionNotifications(for subscriptions: [Subscription]) {
        guard self.isNotificationPermissionGranted else { return }
        self.subscriptionScheduler.scheduleNotifications(for: subscriptions)
    }

    // MARK: - Goal Milestone Notifications (Delegate to GoalScheduler)

    public func checkGoalMilestones(for goals: [SavingsGoal]) {
        guard self.isNotificationPermissionGranted else { return }
        self.goalScheduler.checkMilestones(for: goals)
    }

    // MARK: - Notification Management

    public func clearAllNotifications() {
        self.center.removeAllPendingNotificationRequests()
        self.center.removeAllDeliveredNotifications()
        self.pendingNotifications.removeAll()
    }

    public func clearNotifications(ofType type: String) {
        Task { @MainActor in
            let requests = await center.pendingNotificationRequests()
            let identifiersToRemove =
                requests
                    .filter { request in
                        (request.content.userInfo["type"] as? String) == type
                    }
                    .map(\.identifier)

            self.center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }

    public nonisolated func getPendingNotifications() async -> [ScheduledNotification] {
        let requests = await center.pendingNotificationRequests()

        return requests.compactMap { request in
            ScheduledNotification(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                type: request.content.userInfo["type"] as? String ?? "unknown",
                scheduledDate: (request.trigger as? UNCalendarNotificationTrigger)?
                    .nextTriggerDate()
            )
        }
    }

    // MARK: - Notification Categories Setup (Delegate to PermissionManager)

    public func setupNotificationCategories() {
        // Set up notification categories
        let budgetCategory = UNNotificationCategory(
            identifier: "BUDGET_WARNING",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let subscriptionCategory = UNNotificationCategory(
            identifier: "SUBSCRIPTION_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            budgetCategory,
            subscriptionCategory,
        ])
    }
}
