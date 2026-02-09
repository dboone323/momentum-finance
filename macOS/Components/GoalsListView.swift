// Goals List View for macOS Three-Column Layout
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
    extension Features.GoalsAndReports {
        struct GoalsListView: View {
            @Environment(\.modelContext) private var modelContext
            @Query private var goals: [SavingsGoal]
            @State private var selectedItem: ListableItem?
            @State private var viewType: ViewType = .goals

            // swiftlint:disable:next nesting
            enum ViewType {
                case goals, reports
            }

            var body: some View {
                VStack {
                    Picker("View", selection: self.$viewType) {
                        Text("Savings Goals").tag(ViewType.goals)
                        Text("Reports").tag(ViewType.reports)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if self.viewType == .goals {
                        self.goalsList
                    } else {
                        self.reportsList
                    }
                }
                .navigationTitle("Goals & Reports")
                .toolbar {
                    ToolbarItem {
                        Button(
                            action: {},
                            label: {
                                Image(systemName: "plus")
                            }
                        )
                        .help("Add New Goal")
                        .accessibilityLabel("Add New Goal Button")
                    }
                }
            }

            var goalsList: some View {
                List(selection: self.$selectedItem) {
                    ForEach(self.goals) { goal in
                        NavigationLink(
                            value: ListableItem(id: goal.id, name: goal.name, type: .goal)
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(goal.name)
                                        .font(.headline)

                                    Spacer()

                                    Text(
                                        "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                    )
                                    .font(.subheadline)
                                }

                                ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                                    .tint(.blue)

                                HStack {
                                    let targetDate = goal.targetDate
                                    Text(
                                        "Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                    Spacer()

                                    let percentage = Int(
                                        (goal.currentAmount / goal.targetAmount) * 100)
                                    Text("\(percentage)%")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: goal.id, name: goal.name, type: .goal))
                    }
                }
            }

            var reportsList: some View {
                List(selection: self.$selectedItem) {
                    NavigationLink(
                        value: ListableItem(
                            id: "spending", name: "Spending by Category", type: .report
                        )
                    ) {
                        HStack {
                            Image(systemName: "chart.pie")
                                .foregroundStyle(.orange)
                            Text("Spending by Category")
                        }
                        .padding(.vertical, 8)
                    }
                    .tag(ListableItem(id: "spending", name: "Spending by Category", type: .report))

                    NavigationLink(
                        value: ListableItem(id: "income", name: "Income vs Expenses", type: .report)
                    ) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundStyle(.green)
                            Text("Income vs Expenses")
                        }
                        .padding(.vertical, 8)
                    }
                    .tag(ListableItem(id: "income", name: "Income vs Expenses", type: .report))

                    NavigationLink(
                        value: ListableItem(
                            id: "trends", name: "Monthly Spending Trends", type: .report
                        )
                    ) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(.blue)
                            Text("Monthly Spending Trends")
                        }
                        .padding(.vertical, 8)
                    }
                    .tag(ListableItem(id: "trends", name: "Monthly Spending Trends", type: .report))

                    NavigationLink(
                        value: ListableItem(
                            id: "cashflow", name: "Cash Flow Analysis", type: .report
                        )
                    ) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundStyle(.purple)
                            Text("Cash Flow Analysis")
                        }
                        .padding(.vertical, 8)
                    }
                    .tag(ListableItem(id: "cashflow", name: "Cash Flow Analysis", type: .report))
                }
            }
        }

        struct SavingsGoalDetailView: View {
            let goalId: String

            @Query private var goals: [SavingsGoal]
            @State private var isEditing = false

            var goal: SavingsGoal? {
                self.goals.first(where: { $0.id == self.goalId })
            }

            var body: some View {
                Group {
                    if let goal {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(goal.name)
                                            .font(.largeTitle)
                                            .bold()

                                        let targetDate = goal.targetDate
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text(
                                                "Target Date: \(targetDate.formatted(date: .long, time: .omitted))"
                                            )
                                            .font(.headline)
                                        }
                                        .foregroundStyle(.secondary)

                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(goal.targetAmount.formatted(.currency(code: "USD")))
                                            .font(.system(size: 28, weight: .bold))

                                        Text("Target Amount")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("Goal Progress")
                                            .font(.headline)

                                        Spacer()

                                        Text(
                                            "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                        )
                                    }

                                    ProgressView(
                                        value: goal.currentAmount, total: goal.targetAmount
                                    )
                                    .tint(.blue)
                                    .scaleEffect(y: 2.0)
                                    .padding(.vertical, 8)

                                    HStack {
                                        Text(
                                            "Remaining: \((goal.targetAmount - goal.currentAmount).formatted(.currency(code: "USD")))"
                                        )
                                        .foregroundStyle(.secondary)

                                        Spacer()

                                        let percentage = Int(
                                            (goal.currentAmount / goal.targetAmount) * 100)
                                        Text("\(percentage)% Complete")
                                            .foregroundStyle(.blue)
                                            .bold()
                                    }
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)

                                TimeRemainingView(goal: goal, targetDate: goal.targetDate)

                                Spacer()
                            }
                            .padding()
                            .frame(
                                maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading
                            )
                        }
                        .toolbar {
                            ToolbarItem {
                                Button(
                                    action: { self.isEditing.toggle() },
                                    label: {
                                        Text(self.isEditing ? "Done" : "Edit")
                                    }
                                )
                                .accessibilityLabel("Edit Goal Button")
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "Goal Not Found",
                            systemImage: "exclamationmark.triangle",
                            description: Text("The goal you're looking for could not be found.")
                        )
                    }
                }
                .navigationTitle("Goal Details")
            }
        }

        struct TimeRemainingView: View {
            let goal: SavingsGoal
            let targetDate: Date

            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time Remaining")
                        .font(.headline)

                    let daysRemaining =
                        Calendar.current.dateComponents(
                            [.day],
                            from: Date(),
                            to: targetDate
                        ).day ?? 0

                    if daysRemaining > 0 {
                        Text("\(daysRemaining) days until target date")
                            .font(.title2)

                        let remainingAmount = goal.targetAmount - goal.currentAmount
                        let monthsRemaining = Double(daysRemaining) / 30.0
                        if monthsRemaining > 0 {
                            let requiredMonthlySavings = remainingAmount / monthsRemaining
                            Text(
                                "You need to save \(requiredMonthlySavings.formatted(.currency(code: "USD"))) per month to reach your goal on time."
                            )
                            .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Target date has passed")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)
            }
        }
    }
#endif
