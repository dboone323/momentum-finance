//
//  ThemeDemoComponents.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

// MARK: - Theme Demo Components

/// Theme selector card for the demo view
public struct ThemeSelectorCard: View {
    @Binding var selectedThemeMode: ThemeMode
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Theme Selector")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            Picker("Theme Mode", selection: self.$selectedThemeMode) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: self.selectedThemeMode) { _, newValue in
                self.theme.setThemeMode(newValue)
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Financial summary card for the demo view
public struct ThemeFinancialSummaryCard: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Summary")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundStyle(self.theme.secondaryText)
                    Text("$12,211.50")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(self.theme.income)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("This Month")
                        .font(.subheadline)
                        .foregroundStyle(self.theme.secondaryText)
                    Text("+$1,250.75")
                        .font(.title3)
                        .foregroundStyle(self.theme.income)
                }
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Accounts list for the demo view
public struct ThemeAccountsList: View {
    let accounts: [AccountData]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accounts")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            ForEach(self.accounts, id: \.name) { account in
                HStack {
                    Image(systemName: account.iconName)
                        .frame(width: 32, height: 32)
                        .foregroundStyle(self.theme.accentPrimary)
                        .background(self.theme.secondaryBackground)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(account.name)
                            .font(.subheadline)
                            .foregroundStyle(self.theme.primaryText)
                        Text("$\(String(format: "%.2f", account.balance))")
                            .font(.caption)
                            .foregroundStyle(self.theme.secondaryText)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Budget progress section for the demo view
public struct ThemeBudgetProgress: View {
    let budgets: [BudgetData]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Progress")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            ForEach(self.budgets, id: \.name) { budget in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(budget.name)
                            .font(.subheadline)
                            .foregroundStyle(self.theme.primaryText)
                        Spacer()
                        Text("$\(String(format: "%.0f", budget.spent)) / $\(String(format: "%.0f", budget.total))")
                            .font(.caption)
                            .foregroundStyle(self.theme.secondaryText)
                    }

                    let progress = budget.total > 0 ? budget.spent / budget.total : 0
                    let color: Color = progress > 1.0 ? self.theme.expense : self.theme.budgetUnder

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(self.theme.secondaryBackground)
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(color)
                                .frame(width: geometry.size.width * min(progress, 1.0), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Subscription item model for demo
public struct SubscriptionItem: Hashable {
    let name: String
    let icon: String
    let renewalDate: String
    let amount: Double
}

/// Subscriptions list for the demo view
public struct ThemeSubscriptionsList: View {
    let subscriptions: [SubscriptionItem]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscriptions")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            ForEach(self.subscriptions, id: \.name) { subscription in
                HStack {
                    Image(systemName: subscription.icon)
                        .frame(width: 32, height: 32)
                        .foregroundStyle(self.theme.accentPrimary)
                        .background(self.theme.secondaryBackground)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(subscription.name)
                            .font(.subheadline)
                            .foregroundStyle(self.theme.primaryText)
                        Text("Renews \(subscription.renewalDate)")
                            .font(.caption)
                            .foregroundStyle(self.theme.secondaryText)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", subscription.amount))")
                        .font(.subheadline)
                        .foregroundStyle(self.theme.primaryText)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Typography showcase for the demo view
public struct ThemeTypographyShowcase: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            Group {
                Text("Large Title")
                    .font(.largeTitle)
                    .foregroundStyle(self.theme.primaryText)

                Text("Title")
                    .font(.title)
                    .foregroundStyle(self.theme.primaryText)

                Text("Title 2")
                    .font(.title2)
                    .foregroundStyle(self.theme.primaryText)

                Text("Title 3")
                    .font(.title3)
                    .foregroundStyle(self.theme.primaryText)

                Text("Headline")
                    .font(.headline)
                    .foregroundStyle(self.theme.primaryText)

                Text("Subheadline")
                    .font(.subheadline)
                    .foregroundStyle(self.theme.primaryText)

                Text("Body")
                    .font(.body)
                    .foregroundStyle(self.theme.primaryText)

                Text("Callout")
                    .font(.callout)
                    .foregroundStyle(self.theme.primaryText)

                Text("Caption")
                    .font(.caption)
                    .foregroundStyle(self.theme.primaryText)

                Text("Caption 2")
                    .font(.caption2)
                    .foregroundStyle(self.theme.secondaryText)
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Button styles showcase for the demo view
public struct ThemeButtonStylesShowcase: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Button Styles")
                .font(.headline)
                .foregroundStyle(self.theme.primaryText)

            VStack(spacing: 12) {
                Button("Primary Button").accessibilityLabel("Button").accessibilityLabel("Button") {}
                    .buttonStyle(.borderedProminent)
                    .tint(self.theme.accentPrimary)

                Button("Secondary Button").accessibilityLabel("Button").accessibilityLabel("Button") {}
                    .buttonStyle(.bordered)
                    .tint(self.theme.secondaryBackground)

                Button("Text Button").accessibilityLabel("Button").accessibilityLabel("Button") {}
                    .foregroundStyle(self.theme.accentPrimary)

                Button("Destructive Button").accessibilityLabel("Button").accessibilityLabel("Button") {}
                    .foregroundStyle(self.theme.expense)
            }
        }
        .padding()
        .background(self.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(self.theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

/// Theme settings sheet for the demo view
public struct ThemeSettingsSheet: View {
    @Binding var selectedThemeMode: ThemeMode
    @Binding var sliderValue: Double
    @Binding var showSheet: Bool
    let theme: ColorTheme

    var body: some View {
        NavigationStack {
            Form {
                Section("Theme Mode") {
                    Picker("Mode", selection: self.$selectedThemeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.inline)
                    .onChange(of: self.selectedThemeMode) { _, newValue in
                        self.theme.setThemeMode(newValue)
                    }
                }

                Section("Accent Adjustment") {
                    Slider(value: self.$sliderValue, in: 0 ... 1) {
                        Text("Accent Intensity")
                    }
                    Text("Value: \(String(format: "%.2f", self.sliderValue))")
                        .font(.caption)
                        .foregroundStyle(self.theme.secondaryText)
                }
            }
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.showSheet = false
                    }
                }
            }
        }
    }
}
