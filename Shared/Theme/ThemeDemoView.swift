//
//  ThemeDemoView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import MomentumFinanceCore
import SwiftUI

/// A demonstration view showing the dark mode optimizations and theme system
public struct ThemeDemoView: View {
    @State private var theme = ColorTheme.shared
    @State private var themeManager = ThemeManager.shared
    @State private var selectedThemeMode: ThemeMode = .system
    @State private var showSheet = false
    @State private var sliderValue: Double = 0.75

    // Sample financial data for demo
    private let accounts = [
        ("Checking", "banknote", 1250.50),
        ("Savings", "dollarsign.circle", 4320.75),
        ("Investment", "chart.line.uptrend.xyaxis", 8640.25),
    ]

    private let budgets = [
        ("Groceries", 420.0, 500.0),
        ("Dining Out", 280.0, 300.0),
        ("Entertainment", 150.0, 100.0),
    ]

    private let subscriptions = [
        ("Netflix", "play.tv", "2025-06-15", 15.99),
        ("Spotify", "music.note", "2025-06-22", 9.99),
        ("iCloud+", "cloud", "2025-07-01", 2.99),
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme selector at top
                    ThemeSelectorCard(
                        selectedThemeMode: self.$selectedThemeMode,
                        theme: self.theme
                    )

                    // Financial summary card
                    ThemeFinancialSummaryCard(theme: self.theme)

                    // Account cards
                    ThemeAccountsList(
                        accounts: self.accounts.map {
                            AccountData(name: $0.0, iconName: $0.1, balance: $0.2)
                        },
                        theme: self.theme
                    )

                    // Budget progress section
                    ThemeDemoBudgetProgress(
                        budgets: self.budgets.map {
                            BudgetData(name: $0.0, spent: $0.1, total: $0.2)
                        },
                        theme: self.theme
                    )

                    // Subscriptions section
                    ThemeDemoSubscriptionsList(
                        subscriptions: self.subscriptions.map {
                            SubscriptionItem(
                                name: $0.0, icon: $0.1, renewalDate: $0.2, amount: $0.3)
                        },
                        theme: self.theme
                    )

                    // Typography showcase
                    ThemeDemoTypographyShowcase(theme: self.theme)

                    // Button styles showcase
                    ThemeDemoButtonStylesShowcase(theme: self.theme)
                }
                .padding()
            }
            .background(self.theme.background)
            .navigationTitle("Theme Showcase")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { self.showSheet = true }) {
                        Image(systemName: "gear")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(self.theme.accentPrimary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: self.$showSheet) {
                ThemeDemoSettingsSheet(
                    selectedThemeMode: self.$selectedThemeMode,
                    sliderValue: self.$sliderValue,
                    showSheet: self.$showSheet,
                    theme: self.theme
                )
            }
            .preferredColorScheme(self.theme.isDarkMode ? .dark : .light)
        }
        .onAppear {
            // Initialize the selected mode from current theme
            self.selectedThemeMode = self.theme.currentThemeMode
        }
    }
}

#Preview {
    ThemeDemoView()
}
