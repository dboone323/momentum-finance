// Momentum Finance - macOS-specific Keyboard Shortcuts
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftUI

#if os(macOS)
    /**
     Manages keyboard shortcuts for the macOS version of Momentum Finance.

     ## Overview
     `KeyboardShortcutManager` provides centralized keyboard shortcut management for the macOS application,
     registering global shortcuts and creating menu items with keyboard equivalents.

     ## Keyboard Shortcut Categories

     ### Navigation Shortcuts
     - **⌘1**: Jump to Dashboard view
     - **⌘2**: Jump to Transactions view
     - **⌘3**: Jump to Budgets view
     - **⌘4**: Jump to Subscriptions view
     - **⌘5**: Jump to Goals & Reports view

     ### Action Shortcuts
     - **⌘⇧N**: Create new transaction
     - **⌘⇧B**: Create new budget
     - **⌘⇧S**: Create new subscription
     - **⌘⇧G**: Create new savings goal
     - **⌘F**: Open global search

     ### View Management
     - **⌘S**: Toggle sidebar visibility
     - **⌘R**: Refresh all data
     - **⌘⇧E**: Export data to file

     ## Usage Example
     ```swift
     // Registration happens automatically at app launch
     KeyboardShortcutManager.shared.registerGlobalShortcuts()

     // Access shortcuts for SwiftUI views
     Button("Dashboard") {
         // Action
     }
     .keyboardShortcut(KeyboardShortcutManager.shared.dashboardShortcut)
     ```

     ## Implementation Notes
     - This class is a singleton accessible via `shared`
     - Shortcuts are registered through NSMenu integration
     - macOS automatically handles keyboard shortcut conflicts
     - All shortcuts follow Apple's Human Interface Guidelines

     - Note: Shortcuts defined here must not conflict with system-level shortcuts
     - Important: Changes to shortcuts require updating both the property definitions and menu creation
     */
    class KeyboardShortcutManager {
        /// Shared singleton instance
        static let shared = KeyboardShortcutManager()

        // MARK: - Navigation Shortcuts

        /// Keyboard shortcut for Dashboard (⌘1)
        let dashboardShortcut = KeyboardShortcut("1", modifiers: [.command])

        /// Keyboard shortcut for Transactions (⌘2)
        let transactionsShortcut = KeyboardShortcut("2", modifiers: [.command])

        /// Keyboard shortcut for Budgets (⌘3)
        let budgetsShortcut = KeyboardShortcut("3", modifiers: [.command])

        /// Keyboard shortcut for Subscriptions (⌘4)
        let subscriptionsShortcut = KeyboardShortcut("4", modifiers: [.command])

        /// Keyboard shortcut for Goals & Reports (⌘5)
        let goalsReportsShortcut = KeyboardShortcut("5", modifiers: [.command])

        // MARK: - Action Shortcuts

        /// Keyboard shortcut for creating a new transaction (⌘⇧N)
        let newTransactionShortcut = KeyboardShortcut("n", modifiers: [.command, .shift])

        /// Keyboard shortcut for creating a new budget (⌘⇧B)
        let newBudgetShortcut = KeyboardShortcut("b", modifiers: [.command, .shift])

        /// Keyboard shortcut for creating a new subscription (⌘⇧S)
        let newSubscriptionShortcut = KeyboardShortcut("s", modifiers: [.command, .shift])

        /// Keyboard shortcut for creating a new savings goal (⌘⇧G)
        let newGoalShortcut = KeyboardShortcut("g", modifiers: [.command, .shift])

        /// Keyboard shortcut for opening global search (⌘F)
        let searchShortcut = KeyboardShortcut("f", modifiers: [.command])

        // MARK: - View Management Shortcuts

        /// Keyboard shortcut for toggling sidebar (⌘S)
        let toggleSidebarShortcut = KeyboardShortcut("s", modifiers: [.command])

        /// Keyboard shortcut for refreshing data (⌘R)
        let refreshDataShortcut = KeyboardShortcut("r", modifiers: [.command])

        /// Keyboard shortcut for exporting data (⌘⇧E)
        let exportDataShortcut = KeyboardShortcut("e", modifiers: [.command, .shift])

        private init() {}

        /**
         Registers global keyboard shortcuts for the application.

         This method creates the main menu with all keyboard shortcuts properly configured.
         It should be called once during application launch.

         ## Implementation
         The method assigns the created menu to `NSApp.mainMenu`, which automatically
         registers all keyboard shortcuts defined within menu items.

         - Note: macOS handles keyboard shortcut conflicts automatically
         - Important: This must be called on the main thread
         */
        func registerGlobalShortcuts() {
            // macOS automatically handles keyboard shortcuts defined in the menu
            NSApp.mainMenu = self.createMainMenu()
        }

        /// Creates the main menu with keyboard shortcuts
        private func createMainMenu() -> NSMenu {
            let mainMenu = NSMenu()

            // App menu
            let appMenu = NSMenu()
            let appMenuItem = NSMenuItem(title: "Momentum Finance", action: nil, keyEquivalent: "")
            appMenuItem.submenu = appMenu

            appMenu.addItem(NSMenuItem(
                title: "About Momentum Finance",
                action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                keyEquivalent: ""
            ))
            appMenu.addItem(NSMenuItem.separator())
            appMenu.addItem(NSMenuItem(
                title: "Preferences...",
                action: #selector(NSApplication.shared.showPreferencesWindow),
                keyEquivalent: ","
            ))
            appMenu.addItem(NSMenuItem.separator())
            appMenu.addItem(NSMenuItem(
                title: "Quit Momentum Finance",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            ))

            // File menu
            let fileMenu = NSMenu(title: "File")
            fileMenu.addItem(
                withTitle: "New Transaction",
                action: #selector(NSApplication.shared.newTransaction),
                keyEquivalent: "N"
            )
            fileMenu.addItem(
                withTitle: "New Budget",
                action: #selector(NSApplication.shared.newBudget),
                keyEquivalent: "B"
            )
            fileMenu.addItem(
                withTitle: "New Subscription",
                action: #selector(NSApplication.shared.newSubscription),
                keyEquivalent: "S"
            )
            fileMenu.addItem(
                withTitle: "New Savings Goal",
                action: #selector(NSApplication.shared.newGoal),
                keyEquivalent: "G"
            )
            fileMenu.addItem(NSMenuItem.separator())
            fileMenu.addItem(
                withTitle: "Export Data...",
                action: #selector(NSApplication.shared.exportData),
                keyEquivalent: "E"
            )
            fileMenu.addItem(
                withTitle: "Import Data...",
                action: #selector(NSApplication.shared.importData),
                keyEquivalent: "I"
            )

            let fileMenuItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
            fileMenuItem.submenu = fileMenu

            // Edit menu
            let editMenu = NSMenu(title: "Edit")
            editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
            editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
            editMenu.addItem(NSMenuItem.separator())
            editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
            editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
            editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
            editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
            editMenu.addItem(NSMenuItem.separator())
            editMenu.addItem(
                withTitle: "Find...",
                action: #selector(NSApplication.shared.performGlobalSearch),
                keyEquivalent: "f"
            )

            let editMenuItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
            editMenuItem.submenu = editMenu

            // View menu
            let viewMenu = NSMenu(title: "View")
            viewMenu.addItem(
                withTitle: "Toggle Sidebar",
                action: #selector(NSApplication.shared.toggleSidebar),
                keyEquivalent: "s"
            )
            viewMenu.addItem(
                withTitle: "Enter Full Screen",
                action: #selector(NSWindow.toggleFullScreen(_:)),
                keyEquivalent: "f"
            )
            viewMenu.addItem(NSMenuItem.separator())
            viewMenu.addItem(
                withTitle: "Dashboard",
                action: #selector(NSApplication.shared.showDashboard),
                keyEquivalent: "1"
            )
            viewMenu.addItem(
                withTitle: "Transactions",
                action: #selector(NSApplication.shared.showTransactions),
                keyEquivalent: "2"
            )
            viewMenu.addItem(
                withTitle: "Budgets",
                action: #selector(NSApplication.shared.showBudgets),
                keyEquivalent: "3"
            )
            viewMenu.addItem(
                withTitle: "Subscriptions",
                action: #selector(NSApplication.shared.showSubscriptions),
                keyEquivalent: "4"
            )
            viewMenu.addItem(
                withTitle: "Goals & Reports",
                action: #selector(NSApplication.shared.showGoalsAndReports),
                keyEquivalent: "5"
            )

            let viewMenuItem = NSMenuItem(title: "View", action: nil, keyEquivalent: "")
            viewMenuItem.submenu = viewMenu

            // Help menu
            let helpMenu = NSMenu(title: "Help")
            helpMenu.addItem(
                withTitle: "Momentum Finance Help",
                action: #selector(NSApplication.shared.showHelp),
                keyEquivalent: "?"
            )

            let helpMenuItem = NSMenuItem(title: "Help", action: nil, keyEquivalent: "")
            helpMenuItem.submenu = helpMenu

            // Add top-level menus to main menu
            mainMenu.addItem(appMenuItem)
            mainMenu.addItem(fileMenuItem)
            mainMenu.addItem(editMenuItem)
            mainMenu.addItem(viewMenuItem)
            mainMenu.addItem(helpMenuItem)

            return mainMenu
        }
    }

    extension NSApplication {
        @objc
        func showPreferencesWindow() {
            // Open preferences window - would be implemented in the app
            NotificationCenter.default.post(name: Notification.Name("ShowPreferencesWindow"), object: nil)
        }

        @objc
        func newTransaction() {
            NotificationCenter.default.post(name: Notification.Name("NewTransaction"), object: nil)
        }

        @objc
        func newBudget() {
            NotificationCenter.default.post(name: Notification.Name("NewBudget"), object: nil)
        }

        @objc
        func newSubscription() {
            NotificationCenter.default.post(name: Notification.Name("NewSubscription"), object: nil)
        }

        @objc
        func newGoal() {
            NotificationCenter.default.post(name: Notification.Name("NewGoal"), object: nil)
        }

        @objc
        func exportData() {
            NotificationCenter.default.post(name: Notification.Name("ExportData"), object: nil)
        }

        @objc
        func importData() {
            NotificationCenter.default.post(name: Notification.Name("ImportData"), object: nil)
        }

        @objc
        func performGlobalSearch() {
            NotificationCenter.default.post(name: Notification.Name("PerformGlobalSearch"), object: nil)
        }

        @objc
        func toggleSidebar() {
            NotificationCenter.default.post(name: Notification.Name("ToggleSidebar"), object: nil)
        }

        @objc
        func showDashboard() {
            NotificationCenter.default.post(name: Notification.Name("ShowDashboard"), object: nil)
        }

        @objc
        func showTransactions() {
            NotificationCenter.default.post(name: Notification.Name("ShowTransactions"), object: nil)
        }

        @objc
        func showBudgets() {
            NotificationCenter.default.post(name: Notification.Name("ShowBudgets"), object: nil)
        }

        @objc
        func showSubscriptions() {
            NotificationCenter.default.post(name: Notification.Name("ShowSubscriptions"), object: nil)
        }

        @objc
        func showGoalsAndReports() {
            NotificationCenter.default.post(name: Notification.Name("ShowGoalsAndReports"), object: nil)
        }

        @objc
        func showHelp() {
            NotificationCenter.default.post(name: Notification.Name("ShowHelp"), object: nil)
        }
    }

    /// View modifier for applying keyboard shortcuts to macOS views
    struct MacOSKeyboardShortcuts: ViewModifier {
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        /// <#Description#>
        /// - Returns: <#description#>
        func body(content: Content) -> some View {
            content
                // Tab navigation shortcuts
                .keyboardShortcut("1", modifiers: [.command], action: { self.navigateToTab(0) })
                .keyboardShortcut("2", modifiers: [.command], action: { self.navigateToTab(1) })
                .keyboardShortcut("3", modifiers: [.command], action: { self.navigateToTab(2) })
                .keyboardShortcut("4", modifiers: [.command], action: { self.navigateToTab(3) })
                .keyboardShortcut("5", modifiers: [.command], action: { self.navigateToTab(4) })
                // Sidebar toggle
                .keyboardShortcut("s", modifiers: [.command], action: { self.toggleSidebar() })
                // Search
                .keyboardShortcut("f", modifiers: [.command], action: { self.activateSearch() })
                // Refresh data
                .keyboardShortcut("r", modifiers: [.command], action: { self.refreshData() })
                .onAppear {
                    // Setup notification listeners
                    self.setupNotificationHandlers()
                }
        }

        private func navigateToTab(_ index: Int) {
            self.navigationCoordinator.navigateToTab(index)
        }

        private func toggleSidebar() {
            self.navigationCoordinator.toggleSidebar()
        }

        private func activateSearch() {
            self.navigationCoordinator.activateSearch()
        }

        private func refreshData() {
            // This would refresh the app's data
        }

        private func setupNotificationHandlers() {
            // Setup notification handlers for the menu actions
            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowDashboard"),
                object: nil,
                queue: .main
            ) { _ in
                self.navigateToTab(0)
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowTransactions"),
                object: nil,
                queue: .main
            ) { _ in
                self.navigateToTab(1)
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowBudgets"),
                object: nil,
                queue: .main
            ) { _ in
                self.navigateToTab(2)
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowSubscriptions"),
                object: nil,
                queue: .main
            ) { _ in
                self.navigateToTab(3)
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowGoalsAndReports"),
                object: nil,
                queue: .main
            ) { _ in
                self.navigateToTab(4)
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("ToggleSidebar"),
                object: nil,
                queue: .main
            ) { _ in
                self.toggleSidebar()
            }

            NotificationCenter.default.addObserver(
                forName: Notification.Name("PerformGlobalSearch"),
                object: nil,
                queue: .main
            ) { _ in
                self.activateSearch()
            }
        }
    }

    extension View {
        /// Apply macOS keyboard shortcuts to a view
        /// <#Description#>
        /// - Returns: <#description#>
        func withMacOSKeyboardShortcuts() -> some View {
            modifier(MacOSKeyboardShortcuts())
        }
    }

    /// Helper extension for keyboard shortcut functions
    extension View {
        /// <#Description#>
        /// - Returns: <#description#>
        func keyboardShortcut(_ key: String, modifiers: EventModifiers, action: @escaping () -> Void) -> some View {
            onExitCommand(perform: nil)
                .background(KeyboardShortcutHandler(key: key, modifiers: modifiers, action: action))
        }
    }

    /// Internal helper for keyboard shortcut support
    struct KeyboardShortcutHandler: NSViewRepresentable {
        let key: String
        let modifiers: EventModifiers
        let action: () -> Void

        /// <#Description#>
        /// - Returns: <#description#>
        func makeNSView(context _: Context) -> NSView {
            let view = KeyView()
            view.key = self.key
            view.modifiers = self.modifiers
            view.action = self.action
            return view
        }

        /// <#Description#>
        /// - Returns: <#description#>
        func updateNSView(_ nsView: NSView, context _: Context) {
            guard let view = nsView as? KeyView else { return }
            view.key = self.key
            view.modifiers = self.modifiers
            view.action = self.action
        }

        private class KeyView: NSView {
            var key: String = ""
            var modifiers: EventModifiers = []
            var action: (() -> Void)?

            override var acceptsFirstResponder: Bool { true }

            override func keyDown(with event: NSEvent) {
                let pressedKey = event.charactersIgnoringModifiers?.lowercased() ?? ""
                var pressedModifiers: EventModifiers = []

                if event.modifierFlags.contains(.command) { pressedModifiers.insert(.command) }
                if event.modifierFlags.contains(.shift) { pressedModifiers.insert(.shift) }
                if event.modifierFlags.contains(.option) { pressedModifiers.insert(.option) }
                if event.modifierFlags.contains(.control) { pressedModifiers.insert(.control) }

                if pressedKey == self.key.lowercased(), pressedModifiers == self.modifiers {
                    self.action?()
                } else {
                    super.keyDown(with: event)
                }
            }
        }
    }
#endif

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
