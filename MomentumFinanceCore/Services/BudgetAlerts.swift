//
// BudgetAlerts.swift
// MomentumFinance
//
// Step 35: Budget alerts and notifications.
//

import Foundation
import UserNotifications

/// Configuration for a budget alert.
public struct BudgetAlertConfig: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var category: String?
    public var budgetAmount: Double
    public var alertThreshold: Double // 0.0-1.0 (e.g., 0.8 = 80%)
    public var isEnabled: Bool
    public var notifyOnExceed: Bool
    public var currentSpending: Double
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: String? = nil,
        budgetAmount: Double,
        alertThreshold: Double = 0.8,
        isEnabled: Bool = true,
        notifyOnExceed: Bool = true,
        currentSpending: Double = 0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.budgetAmount = budgetAmount
        self.alertThreshold = alertThreshold
        self.isEnabled = isEnabled
        self.notifyOnExceed = notifyOnExceed
        self.currentSpending = currentSpending
    }
    
    public var percentUsed: Double {
        guard budgetAmount > 0 else { return 0 }
        return currentSpending / budgetAmount
    }
    
    public var isOverThreshold: Bool {
        percentUsed >= alertThreshold
    }
    
    public var isOverBudget: Bool {
        currentSpending > budgetAmount
    }
    
    public var remainingBudget: Double {
        max(0, budgetAmount - currentSpending)
    }
}

/// Manager for budget alerts and notifications.
public final class BudgetAlertManager: ObservableObject {
    
    public static let shared = BudgetAlertManager()
    
    @Published public var alerts: [BudgetAlertConfig] = []
    @Published public var pendingNotifications: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let alertsKey = "budgetAlerts"
    
    private init() {
        loadAlerts()
        requestNotificationPermission()
    }
    
    // MARK: - Alert Management
    
    public func addAlert(_ alert: BudgetAlertConfig) {
        alerts.append(alert)
        saveAlerts()
    }
    
    public func updateAlert(_ alert: BudgetAlertConfig) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index] = alert
            saveAlerts()
        }
    }
    
    public func removeAlert(id: UUID) {
        alerts.removeAll { $0.id == id }
        saveAlerts()
    }
    
    // MARK: - Spending Update
    
    public func updateSpending(category: String?, amount: Double) {
        for i in alerts.indices {
            if alerts[i].category == category || (alerts[i].category == nil && category == nil) {
                let previousPercent = alerts[i].percentUsed
                alerts[i].currentSpending += amount
                let newPercent = alerts[i].percentUsed
                
                // Check for threshold crossing
                if alerts[i].isEnabled && previousPercent < alerts[i].alertThreshold && newPercent >= alerts[i].alertThreshold {
                    sendThresholdAlert(alerts[i])
                }
                
                // Check for budget exceeded
                if alerts[i].isEnabled && alerts[i].notifyOnExceed && !previousPercent.isNaN && alerts[i].isOverBudget {
                    sendExceededAlert(alerts[i])
                }
            }
        }
        saveAlerts()
    }
    
    public func resetMonthlyBudgets() {
        for i in alerts.indices {
            alerts[i].currentSpending = 0
        }
        saveAlerts()
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[BudgetAlerts] Notification permission error: \(error)")
            }
            print("[BudgetAlerts] Notification permission: \(granted)")
        }
    }
    
    private func sendThresholdAlert(_ config: BudgetAlertConfig) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Warning ⚠️"
        content.body = "\(config.name) has reached \(Int(config.percentUsed * 100))% of your budget. $\(String(format: "%.2f", config.remainingBudget)) remaining."
        content.sound = .default
        content.categoryIdentifier = "BUDGET_THRESHOLD"
        
        scheduleNotification(content: content, identifier: "threshold_\(config.id)")
    }
    
    private func sendExceededAlert(_ config: BudgetAlertConfig) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Exceeded! 🚨"
        content.body = "\(config.name) has exceeded your budget by $\(String(format: "%.2f", config.currentSpending - config.budgetAmount))."
        content.sound = .defaultCritical
        content.categoryIdentifier = "BUDGET_EXCEEDED"
        
        scheduleNotification(content: content, identifier: "exceeded_\(config.id)")
    }
    
    private func scheduleNotification(content: UNMutableNotificationContent, identifier: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[BudgetAlerts] Failed to schedule notification: \(error)")
            } else {
                print("[BudgetAlerts] Notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveAlerts() {
        if let data = try? JSONEncoder().encode(alerts) {
            userDefaults.set(data, forKey: alertsKey)
        }
    }
    
    private func loadAlerts() {
        if let data = userDefaults.data(forKey: alertsKey),
           let loaded = try? JSONDecoder().decode([BudgetAlertConfig].self, from: data) {
            alerts = loaded
        }
    }
}
