//
//  SubscriptionDetailComponents.swift
//  MomentumFinance
//
//  Extracted components from EnhancedSubscriptionDetailView for SwiftLint compliance
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Subscription Categories

/// Category options for subscriptions
enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment = "Entertainment"
    case productivity = "Productivity"
    case health = "Health & Fitness"
    case utilities = "Utilities"
    case education = "Education"
    case other = "Other"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .entertainment: return "tv.fill"
        case .productivity: return "briefcase.fill"
        case .health: return "heart.fill"
        case .utilities: return "wrench.fill"
        case .education: return "book.fill"
        case .other: return "folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .entertainment: return .purple
        case .productivity: return .blue
        case .health: return .red
        case .utilities: return .green
        case .education: return .orange
        case .other: return .gray
        }
    }
}

// MARK: - Payment Methods

/// Payment method options
struct PaymentMethod: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let lastFour: String?

    static let creditCard = PaymentMethod(name: "Credit Card", icon: "creditcard.fill", lastFour: "4242")
    static let  debitCard = PaymentMethod(name: "Debit Card", icon: "creditcard.fill", lastFour: "1234")
    static let paypal = PaymentMethod(name: "PayPal", icon: "dollarsign.circle.fill", lastFour: nil)
    static let applePay = PaymentMethod(name: "Apple Pay", icon: "applelogo", lastFour: nil)

    static let allMethods = [creditCard, debitCard, paypal, applePay]
}

// MARK: - Billing Cycles

/// Billing cycle options
struct BillingCycle: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let days: Int

    static let weekly = BillingCycle(name: "Weekly", days: 7)
    static let biweekly = BillingCycle(name: "Bi-Weekly", days: 14)
    static let monthly = BillingCycle(name: "Monthly", days: 30)
    static let quarterly = BillingCycle(name: "Quarterly", days: 90)
    static let yearly = BillingCycle(name: "Yearly", days: 365)

    static let allCycles = [weekly, biweekly, monthly, quarterly, yearly]
}

// MARK: - Subscription Status Views

/// Status badge view
struct SubscriptionStatusBadge: View {
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isActive ? "Active" : "Inactive")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill((isActive ? Color.green : Color.red).opacity(0.1))
        )
    }
}

/// Cost breakdown view
struct CostBreakdownView: View {
    let amount: Double
    let cycle: String

    private var monthlyEquivalent: Double {
        switch cycle.lowercased() {
        case "weekly": return amount * 4.33
        case "bi-weekly": return amount * 2.17
        case "monthly": return amount
        case "quarterly": return amount / 3
        case "yearly": return amount / 12
        default: return amount
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cost Breakdown")
                .font(.headline)

            HStack {
                Text("\(cycle) Cost:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(amount, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }

            if cycle.lowercased() != "monthly" {
                HStack {
                    Text("Monthly Equivalent:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("$\(monthlyEquivalent, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            Divider()

            HStack {
                Text("Annual Cost:")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(monthlyEquivalent * 12, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

/// Next billing date view
struct NextBillingView: View {
    let nextBillingDate: Date

    private var daysUntilBilling: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextBillingDate).day ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Billing")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nextBillingDate, style: .date)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("\(daysUntilBilling) days away")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "calendar.badge.clock")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

/// Payment history row
struct PaymentHistoryRow: View {
    let date: Date
    let amount: Double
    let status: PaymentStatus

    enum PaymentStatus {
        case successful, pending, failed

        var icon: String {
            switch self {
            case .successful: return "checkmark.circle.fill"
            case .pending: return "clock.fill"
            case .failed: return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .successful: return .green
            case .pending: return .orange
            case .failed: return .red
            }
        }
    }

    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundStyle(status.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("$\(amount, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(String(describing: status))
                .font(.caption)
                .foregroundStyle(status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(status.color.opacity(0.1))
                )
        }
        .padding(.vertical, 8)
    }
}

/// Notes editor view
struct NotesEditorView: View {
    @Binding var notes: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

            #if canImport(AppKit)
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .focused($isFocused)
            #else
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            #endif
        }
    }
}

/// Auto-renewal toggle view
struct AutoRenewalToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto-Renewal")
                        .font(.headline)

                    Text("Automatically renew this subscription")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
            }

            if !isEnabled {
                Text("Your subscription will be cancelled at the end of the current billing period")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

/// Subscription insights view
struct SubscriptionInsightsView: View {
    let totalPaid: Double
    let averageMonthly: Double
    let startDate: Date

    private var monthsActive: Int {
        Calendar.current.dateComponents([.month], from: startDate, to: Date()).month ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)

            HStack(spacing: 20) {
                InsightCard(
                    title: "Total Paid",
                    value: "$\(totalPaid, specifier: "%.2f")",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )

                InsightCard(
                    title: "Avg/Month",
                    value: "$\(averageMonthly, specifier: "%.2f")",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                InsightCard(
                    title: "Active For",
                    value: "\(monthsActive) mo",
                    icon: "calendar",
                    color: .purple
                )
            }
        }
    }

    private struct InsightCard: View {
        let title: String
        let value: String
        let icon: String
        let color: Color

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
    }
}

/// Cancellation confirmation view
struct CancellationConfirmationView: View {
    @Binding var isPresented: Bool
    let subscriptionName: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Cancel Subscription?")
                .font(.title2)
                .fontWeight(.bold)

            Text("Are you sure you want to cancel '\(subscriptionName)'? This action cannot be undone.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Keep Subscription") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Cancel Subscription") {
                    onConfirm()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            }
            .padding(.top)
        }
        .padding(30)
        .frame(width: 400)
    }
}
