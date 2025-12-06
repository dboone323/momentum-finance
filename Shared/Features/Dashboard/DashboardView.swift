import MomentumFinanceCore
import SwiftData
import SwiftUI

// AppKit is only available on macOS
#if canImport(AppKit)
    import AppKit
#endif

// Temporary ColorTheme stub for macOS compatibility (only if not already defined)
#if DEBUG
    @available(iOS, deprecated: 9999)
    @MainActor
    struct DebugColorThemeStub {
        static let shared = DebugColorThemeStub()
        var background: Color { Color.gray.opacity(0.1) }
        var secondaryBackground: Color { Color.gray.opacity(0.05) }
        var primaryText: Color { Color.primary }
        var secondaryText: Color { Color.secondary }
        var accentPrimary: Color { Color.blue }
        var cardBackground: Color { Color.white }
        var isDarkMode: Bool { false }
    }
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

// MARK: - Theme Types

extension Features.Dashboard {
    // Enum for dashboard destinations
    enum DashboardDestination: Hashable {
        case transactions
        case subscriptions
        case budgets
        case accountDetail(String)
    }

    struct DashboardView: View {
        @Environment(\.modelContext) private var modelContext
        @State private var navigationPath = NavigationPath()

        // Use simple stored arrays to keep builds stable when SwiftData's macros are unavailable.
        @State private var accounts: [FinancialAccount] = []
        @State private var subscriptions: [Subscription] = []
        @State private var budgets: [Budget] = []

        var body: some View {
            NavigationStack(path: self.$navigationPath) {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Welcome Header
                        DashboardWelcomeHeader(
                            greeting: self.timeOfDayGreeting,
                            wellnessPercentage: 70,
                            totalBalance: self.totalBalanceDouble,
                            monthlyIncome: self.monthlyIncomeDouble,
                            monthlyExpenses: self.monthlyExpensesDouble
                        )

                        // Account Balances Summary
                        DashboardAccountsSummary(
                            accounts: self.accounts,
                            onAccountTap: { accountId in
                                self.navigationPath.append(
                                    DashboardDestination.accountDetail(accountId)
                                )
                            },
                            onViewAllTap: {
                                self.navigationPath.append(DashboardDestination.transactions)
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            )
                        )

                        // Upcoming Subscriptions
                        DashboardSubscriptionsSection(
                            subscriptions: self.subscriptions,
                            onSubscriptionTapped: { _ in
                                // Navigate to subscription detail
                            },
                            onViewAllTapped: {
                                self.navigationPath.append(DashboardDestination.subscriptions)
                            },
                            onAddTapped: {
                                // Navigate to add subscription
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )

                        // Budget Progress
                        DashboardBudgetProgress(
                            budgets: self.budgets,
                            onBudgetTap: { _ in
                                self.navigationPath.append(DashboardDestination.budgets)
                            },
                            onViewAllTap: {
                                self.navigationPath.append(DashboardDestination.budgets)
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            )
                        )

                        // Insights Section
                        DashboardInsights(
                            insights: [],
                            onDetailsTapped: {
                                // Navigate to insights detail
                            }
                        )

                        // Quick Actions
                        DashboardQuickActions(
                            onAddTransaction: {
                                // Add transaction action
                            },
                            onPayBills: {
                                // Pay bills action
                            },
                            onViewReports: {
                                // View reports action
                            },
                            onSetGoals: {
                                // Set goals action
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.secondary.opacity(0.05))
                .navigationTitle("Dashboard")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                #endif
                    .onAppear {
                        self.loadData()
                    }
                    .task {
                        // Process overdue subscriptions asynchronously
                        await self.processOverdueSubscriptions(self.subscriptions)
                    }
                    .navigationDestination(for: DashboardDestination.self) { destination in
                        switch destination {
                        case .transactions:
                            Features.Transactions.TransactionsView()
                        case .subscriptions:
                            #if canImport(SwiftData)
                                Features.Subscriptions.SubscriptionsView()
                            #else
                                Text("Subscriptions View - SwiftData not available")
                            #endif
                        case .budgets:
                            Features.Budgets.BudgetsView()
                        case let .accountDetail(accountId):
                            Text("Account Detail: \(accountId)")
                        }
                    }
            }
        }

        // MARK: - Computed Properties

        private var timeOfDayGreeting: String {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 0..<12: return "Morning"
            case 12..<17: return "Afternoon"
            default: return "Evening"
            }
        }

        private var totalBalance: String {
            let total = self.accounts.reduce(0) { $0 + $1.balance }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
        }

        private var monthlyIncome: String {
            // Calculate monthly income from transactions
            "$2,450"
        }

        private var monthlyExpenses: String {
            // Calculate monthly expenses from transactions
            "$1,890"
        }

        private var totalBalanceDouble: Double {
            self.accounts.reduce(0) { $0 + $1.balance }
        }

        private var monthlyIncomeDouble: Double {
            // Calculate monthly income from transactions
            2450.0
        }

        private var monthlyExpensesDouble: Double {
            // Calculate monthly expenses from transactions
            1890.0
        }

        // MARK: - Data Loading

        private func loadData() {
            do {
                let accountDescriptor = FetchDescriptor<FinancialAccount>()
                self.accounts = try self.modelContext.fetch(accountDescriptor)

                let subscriptionDescriptor = FetchDescriptor<Subscription>()
                self.subscriptions = try self.modelContext.fetch(subscriptionDescriptor)

                let budgetDescriptor = FetchDescriptor<Budget>()
                self.budgets = try self.modelContext.fetch(budgetDescriptor)
            } catch {
                print("Error loading dashboard data: \(error)")
            }
        }

        private func processOverdueSubscriptions(_ subscriptions: [Subscription]) async {
            let overdueSubscriptions = subscriptions.filter { subscription in
                subscription.isActive && subscription.nextDueDate <= Date()
            }

            for subscription in overdueSubscriptions {
                subscription.processPayment(modelContext: self.modelContext)
                do {
                    try self.modelContext.save()
                } catch {
                    print("Failed to process subscription payment: \(error)")
                }
            }
        }
    }
}

#Preview {
    Features.Dashboard.DashboardView()
        .modelContainer(for: [FinancialAccount.self, Subscription.self, Budget.self])
}

// MARK: - Widget Support (Verification)

struct BudgetWidgetView: View {
    let totalSpent: Double
    let totalBudget: Double

    var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(totalSpent / totalBudget, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Budget")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(NumberFormatter.currency.string(from: NSNumber(value: totalBudget - totalSpent)) ?? "$0")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Left to spend")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))

                    Capsule()
                        .fill(progress > 0.9 ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)

            HStack {
                Text(NumberFormatter.currency.string(from: NSNumber(value: totalSpent)) ?? "$0")
                Spacer()
                Text(NumberFormatter.currency.string(from: NSNumber(value: totalBudget)) ?? "$0")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

#Preview("Widget") {
    BudgetWidgetView(totalSpent: 1250, totalBudget: 2000)
        .frame(width: 170, height: 170)
        .cornerRadius(20)
}
