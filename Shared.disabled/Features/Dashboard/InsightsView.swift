import Charts
import Foundation
import MomentumFinanceCore
import SwiftData
import SwiftUI

// Momentum Finance - Insights View
// Copyright © 2025 Momentum Finance. All rights reserved.

// MARK: - Search Types

public enum SearchFilter: String, CaseIterable, Hashable, Identifiable {
    public var id: String {
        rawValue
    }

    case all = "All"
    case accounts = "Accounts"
    case transactions = "Transactions"
    case subscriptions = "Subscriptions"
    case budgets = "Budgets"
}

public struct SearchResult: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let type: SearchFilter
    public let iconName: String
    public let data: Any?
    public let relevanceScore: Double

    public init(
        id: String, title: String, subtitle: String? = nil, type: SearchFilter, iconName: String,
        relevanceScore: Double = 1.0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.iconName = iconName
        self.relevanceScore = relevanceScore
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.type)
    }

    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }
}

public struct InsightsView: View {
    @StateObject private var intelligenceService = FinancialIntelligenceService.shared
    @Environment(\.modelContext) private var modelContext

    @State private var selectedInsight: FinancialInsight?
    @State private var filterPriority: InsightPriority?
    @State private var filterType: InsightType?

    public var body: some View {
        Group {
            #if os(macOS)
                NavigationStack {
                    VStack(spacing: 0) {
                        // Filter Bar
                        InsightsFilterBar(
                            filterPriority: self.$filterPriority,
                            filterType: self.$filterType
                        )

                        // Insights Content
                        self.insightsContent
                    }
                    .navigationTitle("Financial Insights")
                    .toolbar(content: {
                        ToolbarItem(placement: .navigation) {
                            Button("Refresh") {
                                Task {
                                    await self.intelligenceService.analyzeFinancialData(
                                        modelContext: self.modelContext
                                    )
                                }
                            }
                            .accessibilityLabel("Button")
                            .disabled(self.intelligenceService.isAnalyzing)
                        }
                    })
                }
            #else
                NavigationView {
                    VStack(spacing: 0) {
                        // Filter Bar
                        InsightsFilterBar(
                            filterPriority: self.$filterPriority,
                            filterType: self.$filterType
                        )

                        // Insights Content
                        self.insightsContent
                    }
                    .navigationTitle("Financial Insights")
                    .navigationBarItems(
                        trailing:
                        Button("Refresh") {
                            Task {
                                await self.intelligenceService.analyzeFinancialData(
                                    modelContext: self.modelContext
                                )
                            }
                        }
                        .disabled(self.intelligenceService.isAnalyzing)
                        .accessibilityLabel("Button")
                    )
                }
            #endif
        }
        .sheet(item: self.$selectedInsight) { insight in
            InsightDetailView(insight: insight)
        }
        .onAppear {
            Task {
                if self.intelligenceService.insights.isEmpty {
                    await self.intelligenceService.analyzeFinancialData(
                        modelContext: self.modelContext
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var insightsContent: some View {
        if self.intelligenceService.isAnalyzing {
            InsightsLoadingView()
        } else if self.intelligenceService.insights.isEmpty {
            InsightsEmptyStateView()
        } else {
            self.insightsList
        }
    }

    private var insightsList: some View {
        List {
            ForEach(self.filteredInsights) { insight in
                InsightRowView(insight: insight) {
                    self.selectedInsight = insight
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var filteredInsights: [FinancialInsight] {
        self.intelligenceService.insights
            .filter { insight in
                if let priority = filterPriority, insight.priority != priority {
                    return false
                }
                if let type = filterType, insight.type != type {
                    return false
                }
                return true
            }
            .sorted { $0.priority > $1.priority } // Sort by priority (critical first)
    }
}

// MARK: - Preview

#Preview {
    InsightsView()
        .modelContainer(
            for: [
                FinancialAccount.self,
                FinancialTransaction.self,
                Budget.self,
                ExpenseCategory.self,
            ], inMemory: true
        )
}

// MARK: - Insights Filter Bar

public struct InsightsFilterBar: View {
    @Binding var filterPriority: InsightPriority?
    @Binding var filterType: InsightType?

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Priority Filter
                Menu {
                    Button(action: { self.filterPriority = nil }) {
                        Label("All Priorities", systemImage: "line.3.horizontal.decrease.circle")
                    }

                    ForEach(InsightPriority.allCases, id: \.self) { priority in
                        Button(action: { self.filterPriority = priority }) {
                            Label(priority.rawValue, systemImage: priority.icon)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(self.filterPriority?.rawValue ?? "Priority")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        self.filterPriority != nil
                            ? Color.blue.opacity(0.1)
                            : Color.gray.opacity(0.1)
                    )
                    .cornerRadius(8)
                    .foregroundColor(self.filterPriority != nil ? .blue : .primary)
                }
                .accessibilityLabel("Filter by Priority")

                // Type Filter
                Menu {
                    Button(action: { self.filterType = nil }) {
                        Label("All Types", systemImage: "tag")
                    }

                    ForEach(InsightType.allCases, id: \.self) { type in
                        Button(action: { self.filterType = type }) {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "tag")
                        Text(self.filterType?.rawValue ?? "Type")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        self.filterType != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                    )
                    .cornerRadius(8)
                    .foregroundColor(self.filterType != nil ? .blue : .primary)
                }
                .accessibilityLabel("Filter by Type")
            }
            .padding()
        }
    }

    public init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        self._filterPriority = filterPriority
        self._filterType = filterType
    }
}
