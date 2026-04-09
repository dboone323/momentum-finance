// Momentum Finance - Session Manager
// Copyright © 2026 Momentum Finance. All rights reserved.

import Foundation

/// Manager for app session timeouts and auto-lock security.
@MainActor
public final class SessionManager {
    // MARK: - Singleton

    /// Shared singleton instance
    public static let shared = SessionManager()

    // MARK: - Properties

    /// The date of the last user interaction
    private var lastInteractionDate: Date = .init()

    /// The timeout duration in seconds (default: 5 minutes)
    public var sessionTimeout: TimeInterval = 300

    /// Whether the app is currently locked
    @MainActor public private(set) var isLocked: Bool = false

    /// Callback to trigger biometric authentication
    public var onLockTriggered: (@MainActor () -> Void)?

    // MARK: - Initialization

    private init() {
        self.setupLifecycleObservers()
    }

    // MARK: - Interaction Tracking

    /**
     Updates the last interaction date.
     Should be called from a global interaction monitor or view lifecycle.
     */
    public func recordInteraction() {
        self.lastInteractionDate = Date()

        // If we were locked and just got an interaction, we might need re-auth
        // But usually recordInteraction is called while the app is active
    }

    /**
     Checks if the session has timed out.
     - Returns: True if timed out.
     */
    public func checkTimeout() -> Bool {
        let elapsed = Date().timeIntervalSince(self.lastInteractionDate)
        let timedOut = elapsed > self.sessionTimeout

        if timedOut && !self.isLocked {
            self.lock()
        }

        return timedOut
    }

    // MARK: - Lock Control

    /**
     Manually locks the app session.
     */
    public func lock() {
        self.isLocked = true
        Logger.logInfo("App session locked due to timeout/inactivity")
        self.onLockTriggered?()
    }

    /**
     Unlocks the app session.
     Typically called after successful biometric authentication.
     */
    public func unlock() {
        self.isLocked = false
        self.recordInteraction()
        Logger.logInfo("App session unlocked")
    }

    // MARK: - Lifecycle Integration

    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIApplicationWillResignActiveNotification"),
            object: nil,
            queue: .main
        ) { _ in
            // Apps entering background should record time
            Task { @MainActor in
                SessionManager.shared.recordInteraction()
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                _ = SessionManager.shared.checkTimeout()
            }
        }
    }
}
