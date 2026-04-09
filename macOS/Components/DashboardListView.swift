// Dashboard List View for macOS Three-Column Layout
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
    extension Features.Dashboard {
        struct DashboardListView: View {
            @Environment(\.modelContext) private var modelContext
            @Query private var accounts: [FinancialAccount]
            @Query private var recentTransactions: [FinancialTransaction]
            @State private var selectedItem: ListableItem?

            var body: some View {
                List(selection: self.$selectedItem) {
                    Section("Accounts") {
                        ForEach(self.accounts) { account in
                            NavigationLink(value: ListableItem(id: account.id, name: account.name, type: .account)) {
                                HStack {
                                    Image(systemName: account.type == .checking ? "banknote" : "creditcard")
                                        .foregroundStyle(account.type == .checking ? .green : .blue)
                                    VStack(alignment: .leading) {
                                        Text(account.name)
                                            .font(.headline)
                                        Text(account.balance.formatted(.currency(code: "USD")))
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .tag(ListableItem(id: account.id, name: account.name, type: .account))
                        }
                    }

                    Section("Recent Transactions") {
                        ForEach(self.recentTransactions.prefix(5)) { transaction in
                            NavigationLink(value: ListableItem(
                                id: transaction.id,
                                name: transaction.name,
                                type: .transaction
                            )) {
                                HStack {
                                    Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                                        .foregroundStyle(transaction.amount < 0 ? .red : .green)
                                    VStack(alignment: .leading) {
                                        Text(transaction.name)
                                            .font(.headline)
                                        Text(transaction.amount.formatted(.currency(code: "USD")))
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .tag(ListableItem(id: transaction.id, name: transaction.name, type: .transaction))
                        }
                    }

                    Section("Quick Actions") {
                        Button("Add New Account") {
                            // Action to add new account
                        }
                        .accessibilityLabel("Add New Account Button")

                        Button("Add New Transaction") {
                            // Action to add new transaction
                        }
                        .accessibilityLabel("Add New Transaction Button")
                    }
                }
                .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem {
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                        })
                        .help("Add New Item")
                        .accessibilityLabel("Add New Item Button")
                    }

                    ToolbarItem {
                        Button(action: {}, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                        .help("Refresh")
                        .accessibilityLabel("Refresh Button")
                    }
                }
            }
        }
    }
#endif
