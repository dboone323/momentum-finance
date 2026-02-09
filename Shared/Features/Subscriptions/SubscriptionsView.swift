//
//  SubscriptionsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import MomentumFinanceCore
import SwiftData
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
#if canImport(UIKit)
    import UIKit
#endif

extension Features.Subscriptions {
    // MARK: - Subscription Filter Enum

    public enum SubscriptionFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case inactive = "Inactive"
        case dueSoon = "Due Soon"
    }

    // MARK: - Header View

    public struct SubscriptionHeaderView: View {
        let subscriptions: [Subscription]
        @Binding var selectedFilter: SubscriptionFilter
        @Binding var showingAddSubscription: Bool

        private var viewModel = SubscriptionsViewModel()

        public init(
            subscriptions: [Subscription],
            selectedFilter: Binding<SubscriptionFilter>,
            showingAddSubscription: Binding<Bool>
        ) {
            self.subscriptions = subscriptions
            _selectedFilter = selectedFilter
            _showingAddSubscription = showingAddSubscription
        }

        public var body: some View {
            VStack(spacing: 16) {
                // Enhanced Summary Section
                SubscriptionSummaryCard(subscriptions: self.subscriptions)

                // Filter Picker
                Picker("Filter", selection: self.$selectedFilter) {
                    ForEach(SubscriptionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding()
        }
    }

    // MARK: - Subscription Summary Card

    public struct SubscriptionSummaryCard: View {
        let subscriptions: [Subscription]

        private var viewModel = SubscriptionsViewModel()

        private var activeSubscriptions: [Subscription] {
            self.subscriptions.filter(\.isActive)
        }

        private var totalMonthlyCost: Double {
            self.viewModel.totalMonthlyAmount(self.activeSubscriptions)
        }

        private var subscriptionsDueThisWeek: [Subscription] {
            self.viewModel.subscriptionsDueThisWeek(self.activeSubscriptions)
        }

        private var overdueSubscriptions: [Subscription] {
            self.viewModel.overdueSubscriptions(self.activeSubscriptions)
        }

        public init(subscriptions: [Subscription]) {
            self.subscriptions = subscriptions
        }

        public var body: some View {
            VStack(spacing: 16) {
                // Total Monthly Cost
                HStack {
                    VStack(alignment: .leading) {
                        Text("Monthly Total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(self.totalMonthlyCost.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                // Quick Stats
                HStack(spacing: 20) {
                    StatItem(
                        title: "Active",
                        value: "\(self.activeSubscriptions.count)",
                        color: .green
                    )

                    StatItem(
                        title: "Due Soon",
                        value: "\(self.subscriptionsDueThisWeek.count)",
                        color: self.subscriptionsDueThisWeek.isEmpty ? .secondary : .orange
                    )

                    StatItem(
                        title: "Overdue",
                        value: "\(self.overdueSubscriptions.count)",
                        color: self.overdueSubscriptions.isEmpty ? .secondary : .red
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }

    // MARK: - Stat Item View

    private struct StatItem: View {
        let title: String
        let value: String
        let color: Color

        var body: some View {
            VStack(spacing: 4) {
                Text(self.value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.color)
                Text(self.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Content View

    private struct SubscriptionContentView: View {
        let filteredSubscriptions: [Subscription]
        @Binding var selectedSubscription: Subscription?

        var body: some View {
            if self.filteredSubscriptions.isEmpty {
                EmptySubscriptionsView()
            } else {
                self.subscriptionsList
            }
        }

        private var subscriptionsList: some View {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(self.filteredSubscriptions, id: \.id) { subscription in
                        SubscriptionRowView(subscription: subscription)
                            .onTapGesture {
                                self.selectedSubscription = subscription
                            }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Empty Subscriptions View

    private struct EmptySubscriptionsView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "creditcard")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary.opacity(0.5))

                Text("No Subscriptions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text("Add your first subscription to start tracking recurring payments.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 60)
        }
    }

    // MARK: - Main Subscriptions View

    struct SubscriptionsView: View {
        @State private var viewModel = SubscriptionsViewModel()
        @Environment(\.modelContext)
        private var modelContext
        // Use simple stored arrays for now to keep builds stable across toolchains.
        private var subscriptions: [Subscription] = []
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []

        @State private var showingAddSubscription = false
        @State private var selectedSubscription: Subscription?
        @State private var selectedFilter: SubscriptionFilter = .all

        // Search functionality
        @State private var showingSearch = false
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
                return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.white
            #endif
        }

        private var toolbarPlacement: ToolbarItemPlacement {
            #if canImport(UIKit)
                return .navigationBarTrailing
            #else
                return .primaryAction
            #endif
        }

        private var filteredSubscriptions: [Subscription] {
            switch self.selectedFilter {
            case .all:
                return self.subscriptions
            case .active:
                return self.subscriptions.filter(\.isActive)
            case .inactive:
                return self.subscriptions.filter { !$0.isActive }
            case .dueSoon:
                let sevenDaysFromNow =
                    Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                return self.subscriptions.filter {
                    $0.isActive && $0.nextDueDate <= sevenDaysFromNow
                }
            }
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Header Section
                    SubscriptionHeaderView(
                        subscriptions: self.subscriptions,
                        selectedFilter: self.$selectedFilter,
                        showingAddSubscription: self.$showingAddSubscription
                    )

                    // Content Section
                    SubscriptionContentView(
                        filteredSubscriptions: self.filteredSubscriptions,
                        selectedSubscription: self.$selectedSubscription
                    )
                }
                .navigationTitle("Subscriptions")
                .toolbar(content: {
                    ToolbarItem(placement: self.toolbarPlacement) {
                        HStack(spacing: 12) {
                            Button {
                                self.showingSearch = true
                                NavigationCoordinator.shared.activateSearch()
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            .accessibilityLabel("Search Subscriptions")

                            Button(
                                action: { self.showingAddSubscription = true },
                                label: {
                                    Image(systemName: "plus")
                                }
                            )
                            .accessibilityLabel("Add Subscription")
                        }
                    }
                })
                .sheet(isPresented: self.$showingAddSubscription) {
                    AddSubscriptionView()
                }
                .sheet(isPresented: self.$showingSearch) {
                    Features.GlobalSearch.GlobalSearchView()
                }
                .sheet(item: self.$selectedSubscription) { subscription in
                    SubscriptionDetailView(subscription: subscription)
                }
                .onAppear {
                    self.viewModel.setModelContext(self.modelContext)
                    // Schedule renewal notifications for active subscriptions
                    let activeSubscriptions = self.subscriptions.filter(\.isActive)
                    self.viewModel.scheduleSubscriptionNotifications(for: activeSubscriptions)
                }
                .background(self.backgroundColor)
            }
        }

        // Provide an explicit initializer so call sites can use `SubscriptionsView()`
        // When SwiftData is available the @Query wrappers manage data; otherwise use provided defaults.
        init(
            subscriptions: [Subscription] = [], categories: [ExpenseCategory] = [],
            accounts: [FinancialAccount] = []
        ) {
            #if !canImport(SwiftData)
                self.subscriptions = subscriptions
                self.categories = categories
                self.accounts = accounts
            #endif
        }
    }

}

// MARK: - Placeholder Views

private struct SubscriptionRowView: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subscription.name)
                    .font(.headline)
                Text(subscription.billingCycle.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(subscription.amount, format: .currency(code: "USD"))
                .font(.subheadline)
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(10)
    }
}

private struct AddSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var billingCycle: BillingCycle = .monthly
    @State private var nextDueDate: Date = .init()
    @State private var provider: String = ""
    @State private var isActive: Bool = true
    @State private var notes: String = ""
    @State private var error: String?

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Name", text: self.$name)
                    TextField("Provider", text: self.$provider)
                    TextField("Amount", text: self.$amount)
                        #if os(iOS)
                            .keyboardType(.decimalPad)
                        #endif
                    Picker("Billing Cycle", selection: self.$billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue.capitalized).tag(cycle)
                        }
                    }
                    DatePicker(
                        "Next Due Date", selection: self.$nextDueDate, displayedComponents: .date)
                    Toggle("Active", isOn: self.$isActive)
                    TextField("Notes", text: self.$notes, axis: .vertical)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Save Subscription") { self.save() }
                        .disabled(!self.canSave)
                }
            }
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { self.dismiss() }
                }
            }
        }
    }

    private var canSave: Bool {
        !self.name.trimmingCharacters(in: .whitespaces).isEmpty
            && Double(self.amount) != nil
    }

    private func save() {
        guard let amountValue = Double(self.amount) else {
            self.error = "Amount must be a number"
            return
        }

        let subscription = Subscription(
            name: self.name.trimmingCharacters(in: .whitespaces),
            provider: self.provider,
            amount: amountValue,
            billingCycle: self.billingCycle,
            nextDueDate: self.nextDueDate,
            notes: self.notes.isEmpty ? nil : self.notes,
            isActive: self.isActive
        )

        self.modelContext.insert(subscription)
        try? self.modelContext.save()
        self.dismiss()
    }
}
