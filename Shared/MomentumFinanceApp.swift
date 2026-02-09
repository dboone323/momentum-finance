import Foundation
import MomentumFinanceCore
import SwiftData
import SwiftUI
import os

// Import KeychainHelper for secure storage
// import KeychainHelper // This line is commented out and will be removed as per instruction

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

// MARK: - Secure Settings Access

// The top-level biometric settings access has been removed as it was redundant and replaced by the implementation within MomentumFinanceApp.

// Model references for SwiftData container
extension MomentumFinanceApp {
    fileprivate enum ModelReferences {
        static let accounts = FinancialAccount.self
        static let transactions = FinancialTransaction.self
        static let subscriptions = Subscription.self
        static let budgets = Budget.self
        static let categories = ExpenseCategory.self
        static let goals = SavingsGoal.self
    }
}

@main
public struct MomentumFinanceApp: App {
    @State private var showingError = false
    @State private var errorMessage = ""

    public init() {
        print("MomentumFinanceApp: init started")

        // Initialize app launch analytics
        self.trackAppLaunch()

        // Setup crash reporting
        self.setupCrashReporting()

        // Initialize user preferences
        self.initializeUserPreferences()

        // Initialize network security
        NetworkSecurityManager.shared.initialize()
    }

    // MARK: - Secure Settings Access

    /// Securely access biometric authentication setting from Keychain
    var isBiometricAuthEnabled: Bool {
        do {
            return try SecureCredentialManager.shared.retrieveBool(.biometricEnabled) ?? false
        } catch {
            os_log(
                "Failed to retrieve biometric setting from Keychain: %@", log: .default,
                type: .error, error.localizedDescription
            )
            return false
        }
    }

    /// Securely set biometric authentication setting in Keychain
    /// - Parameter enabled: Whether biometric auth should be enabled
    func setBiometricAuthEnabled(_ enabled: Bool) {
        do {
            try SecureCredentialManager.shared.store(enabled, forKey: .biometricEnabled)
        } catch {
            os_log(
                "Failed to store biometric setting in Keychain: %@", log: .default, type: .error,
                error.localizedDescription
            )
        }
    }

    private func trackAppLaunch() {
        let launchCount = UserDefaults.standard.integer(forKey: "appLaunchCount") + 1
        UserDefaults.standard.set(launchCount, forKey: "appLaunchCount")

        let launchTime = Date()
        UserDefaults.standard.set(launchTime, forKey: "lastAppLaunch")

        // Log analytics event
        print("MomentumFinanceApp: App launched #\(launchCount) at \(launchTime)")

        // In a real app, this would send to analytics service
        // Analytics.track(event: "app_launch", properties: ["launch_count": launchCount])
    }

    private func setupCrashReporting() {
        // Setup basic crash reporting
        // In a real app, this would integrate with services like Sentry, Crashlytics, etc.
        print("MomentumFinanceApp: Crash reporting initialized")

        // Set up signal handlers for basic crash detection
        signal(SIGABRT) { _ in
            print("MomentumFinanceApp: Crash detected - SIGABRT")
            // Log crash information
        }

        signal(SIGSEGV) { _ in
            print("MomentumFinanceApp: Crash detected - SIGSEGV")
            // Log crash information
        }

        // Note: In production, use proper crash reporting frameworks
    }

    private func initializeUserPreferences() {
        let defaults = UserDefaults.standard

        // Set default preferences if not already set
        if defaults.object(forKey: "currencySymbol") == nil {
            defaults.set("$", forKey: "currencySymbol")
        }

        if defaults.object(forKey: "dateFormat") == nil {
            defaults.set("MM/dd/yyyy", forKey: "dateFormat")
        }

        if defaults.object(forKey: "themePreference") == nil {
            defaults.set("system", forKey: "themePreference")  // system, light, dark
        }

        if defaults.object(forKey: "notificationsEnabled") == nil {
            defaults.set(true, forKey: "notificationsEnabled")
        }

        // Migrate biometric auth setting from UserDefaults to Keychain if needed
        if defaults.object(forKey: "biometricAuthEnabled") != nil {
            let enabled = defaults.bool(forKey: "biometricAuthEnabled")
            do {
                try SecureCredentialManager.shared.store(enabled, forKey: .biometricEnabled)
                defaults.removeObject(forKey: "biometricAuthEnabled")
                print("MomentumFinanceApp: Migrated biometric preference to Keychain")
            } catch {
                print("MomentumFinanceApp: Failed to migrate biometric preference: \(error)")
            }
        }

        // Set default biometric auth preference in Keychain if not already set
        if !SecureCredentialManager.shared.exists(.biometricEnabled) {
            try? SecureCredentialManager.shared.store(false, forKey: .biometricEnabled)
        }

        defaults.synchronize()
        print("MomentumFinanceApp: User preferences initialized")
    }

    var sharedModelContainer: ModelContainer? = {
        print("MomentumFinanceApp: Creating ModelContainer")

        let schema = Schema([
            ModelReferences.accounts,
            ModelReferences.transactions,
            ModelReferences.subscriptions,
            ModelReferences.budgets,
            ModelReferences.categories,
            ModelReferences.goals,
        ])

        print("MomentumFinanceApp: Schema created")

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        print("MomentumFinanceApp: ModelConfiguration created")

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("MomentumFinanceApp: ModelContainer created successfully")
            return container
        } catch {
            // Log the error instead of crashing
            print("MomentumFinanceApp: ERROR creating ModelContainer: \(error)")
            os_log(
                "Could not create ModelContainer: %@", log: .default, type: .error,
                error.localizedDescription
            )

            // Try with in-memory storage as fallback
            do {
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [inMemoryConfig])
                print("MomentumFinanceApp: In-memory ModelContainer created successfully")
                return container
            } catch {
                print("MomentumFinanceApp: ERROR creating in-memory ModelContainer: \(error)")
                os_log(
                    "Could not create in-memory ModelContainer: %@", log: .default, type: .error,
                    error.localizedDescription
                )
                return nil
            }
        }
    }()

    public var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
                    .onAppear {
                        print("MomentumFinanceApp: ContentView appeared")
                    }
            } else {
                // Show error view if ModelContainer couldn't be created
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Unable to Initialize Database")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(
                        "The app encountered an error while setting up the database. Please try restarting the app."
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    Button("Quit App") {
                        #if os(iOS)
                            // iOS doesn't allow programmatic app termination
                            // User must manually close the app
                        #else
                            NSApplication.shared.terminate(nil)
                        #endif
                    }
                    .accessibilityLabel("Quit App Button")
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if os(iOS)
                    .background(Color(uiColor: .systemBackground))
                #else
                    .background(Color(NSColor.windowBackgroundColor))
                #endif
                .onAppear {
                    print("MomentumFinanceApp: Error view appeared")
                }
            }
        }

        #if os(macOS)
            Settings {
                if let container = sharedModelContainer {
                    SettingsView()
                        .modelContainer(container)
                } else {
                    Text("Settings unavailable - Database error")
                        .padding()
                }
            }
        #endif
    }
}
