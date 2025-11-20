//
//  SubscriptionDetailComponents.swift
//  MomentumFinance
//
//  Extracted components from EnhancedSubscriptionDetailView for SwiftLint compliance
//

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)

    // MARK: - Shared Subscription Components

    struct SubscriptionLogo: View {
        let provider: String

        // Map common providers to system images
        private var iconName: String {
            switch provider.lowercased() {
            case "netflix": "play.tv"
            case "spotify": "music.note"
            case "apple": "apple.logo"
            case "disney": "play.tv.fill"
            case "amazon": "cart"
            case "youtube": "play.rectangle"
            default: "creditcard"
            }
        }

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))

                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
        }
    }

    struct SubscriptionDetailField: View {
        let label: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(self.value)
                    .font(.body)
            }
        }
    }

    struct SubscriptionStatusBadge: View {
        let isActive: Bool
        let autoRenews: Bool

        var body: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(self.isActive ? .green : .red)
                    .frame(width: 8, height: 8)

                Text(self.isActive ? (self.autoRenews ? "Active" : "Expiring") : "Inactive")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                (self.isActive ? (self.autoRenews ? Color.green : Color.orange) : Color.red)
                    .opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        (self.isActive ? (self.autoRenews ? Color.green : Color.orange) : Color.red)
                            .opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }

    struct PaymentHistoryChart: View {
        let subscription: Subscription

        // Sample data - would be real data in actual implementation
        func generateSampleData() -> [(month: String, amount: Double)] {
            [
                (month: "Jun", amount: self.subscription.amount),
                (month: "Jul", amount: self.subscription.amount),
                (month: "Aug", amount: self.subscription.amount),
                (month: "Sep", amount: self.subscription.amount),
                (month: "Oct", amount: self.subscription.amount),
                (month: "Nov", amount: self.subscription.amount)
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Chart {
                    ForEach(self.generateSampleData(), id: \.month) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }

                    RuleMark(y: .value("Average", self.subscription.amount))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Monthly: \(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                }
            }
        }
    }

    struct BulletPoint: View {
        let text: String

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .padding(.top, 6)

                Text(self.text)
            }
        }
    }

    struct ValueAssessmentView: View {
        let subscription: Subscription

        // Sample usage data - in a real app, this would be tracked
        @State private var usageRating: Double = 0.7 // 0-1 scale

        // Calculate cost per use
        private var costPerUse: Double {
            // Assuming monthly billing and usage 5 times per month
            self.subscription.amount / 5.0
        }

        private var valueAssessment: String {
            if self.usageRating > 0.8 {
                "Excellent Value"
            } else if self.usageRating > 0.5 {
                "Good Value"
            } else if self.usageRating > 0.3 {
                "Fair Value"
            } else {
                "Poor Value"
            }
        }

        private var valueColor: Color {
            if self.usageRating > 0.8 {
                .green
            } else if self.usageRating > 0.5 {
                .blue
            } else if self.usageRating > 0.3 {
                .orange
            } else {
                .red
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Value Assessment")
                    .font(.headline)

                HStack {
                    VStack(alignment: .center, spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                .frame(width: 100, height: 100)

                            Circle()
                                .trim(from: 0, to: self.usageRating)
                                .stroke(self.valueColor, lineWidth: 10)
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))

                            VStack {
                                Text(self.valueAssessment)
                                    .font(.headline)
                                    .foregroundStyle(self.valueColor)

                                Text("\(Int(self.usageRating * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text("Usage Rating")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 20)

                    Divider()
                        .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))
                                .font(.title2)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Estimated Cost Per Use")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(self.costPerUse.formatted(.currency(code: self.subscription.currencyCode)))
                                .font(.title3)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Similar Subscriptions Average")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            let lowerBound = (self.subscription.amount * 0.9).formatted(.currency(code: self.subscription.currencyCode))
                            let upperBound = (self.subscription.amount * 1.1).formatted(.currency(code: self.subscription.currencyCode))
                            Text(
                                "\(lowerBound) - \(upperBound)"
                            )
                            .font(.body)
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 4)

                // Value improvement suggestions
                Text("Value Improvement Suggestions")
                    .font(.subheadline)
                    .bold()

                VStack(alignment: .leading, spacing: 6) {
                    BulletPoint(text: "Consider switching to annual billing to save 16%")
                    BulletPoint(text: "3 similar services found with lower monthly costs")
                    BulletPoint(text: "Usage has decreased by 30% in the last 2 months")
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }
    }

    struct SubscriptionCancellationAssistantView: View {
        let subscription: Subscription?
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            VStack(spacing: 20) {
                Text("Subscription Cancellation Assistant")
                    .font(.title2)
                    .padding(.top)

                Text("Let us help you cancel your \(self.subscription?.name ?? "subscription")")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 16) {
                        Image(systemName: "1.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Visit the provider's website")
                                .font(.headline)

                            if let provider = subscription?.provider {
                                Button("\(provider) Account Page") {
                                    // Open the website
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        Image(systemName: "2.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Navigate to account settings")
                                .font(.headline)

                            Text("Look for 'Subscription', 'Membership', or 'Billing' section")
                                .font(.body)
                        }
                    }

                    HStack(spacing: 16) {
                        Image(systemName: "3.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Find cancellation option")
                                .font(.headline)

                            Text("Look for 'Cancel', 'End subscription', or 'Manage plan'")
                                .font(.body)
                        }
                    }

                    HStack(spacing: 16) {
                        Image(systemName: "4.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Confirm cancellation")
                                .font(.headline)

                            Text("Complete any final steps and get confirmation email")
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                Text("Need to contact customer support?")
                    .font(.headline)

                if let provider = subscription?.provider {
                    HStack(spacing: 20) {
                        Button("Call \(provider)") {
                            // Call action
                        }
                        .buttonStyle(.bordered)

                        Button("Email Support") {
                            // Email action
                        }
                        .buttonStyle(.bordered)

                        Button("Live Chat") {
                            // Chat action
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Spacer()

                Button("Close").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
        }
    }

    struct Feature: View {
        let text: String
        let isIncluded: Bool

        var body: some View {
            HStack {
                Image(systemName: self.isIncluded ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(self.isIncluded ? .green : .secondary)

                Text(self.text)
            }
        }
    }

    struct SubscriptionAlternativesView: View {
        let subscription: Subscription?
        @Environment(\.dismiss) private var dismiss

        // Sample alternatives data
        let alternatives = [
            (name: "CompetitorA", price: 7.99, features: ["HD Streaming", "2 devices", "Limited library"]),
            (name: "CompetitorB", price: 9.99, features: ["4K Streaming", "4 devices", "Full library", "Downloads"]),
            (
                name: "CompetitorC",
                price: 12.99,
                features: ["4K Streaming", "Unlimited devices", "Full library", "Downloads", "Live TV"]
            )
        ]

        var body: some View {
            VStack(spacing: 20) {
                Text("Alternative Services")
                    .font(.title2)
                    .padding(.top)

                Text("Compare alternatives to \(self.subscription?.name ?? "this service")")
                    .font(.headline)

                HStack(alignment: .top, spacing: 0) {
                    // Current subscription column
                    VStack(spacing: 0) {
                        Text("Your Subscription")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))

                        Divider()

                        Text(self.subscription?.name ?? "Current")
                            .font(.title3)
                            .padding()

                        Divider()

                        Text(self.subscription?.amount.formatted(.currency(code: self.subscription?.currencyCode ?? "USD")) ?? "$0.00")
                            .font(.title3)
                            .bold()
                            .padding()

                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Feature(text: "Basic Feature", isIncluded: true)
                            Feature(text: "Premium Feature", isIncluded: true)
                            Feature(text: "Advanced Feature", isIncluded: false)
                            Feature(text: "Extra Feature", isIncluded: false)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)

                    // Alternatives columns
                    ForEach(self.alternatives, id: \.name) { alternative in
                        VStack(spacing: 0) {
                            Text("Alternative")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.secondary.opacity(0.1))

                            Divider()

                            Text(alternative.name)
                                .font(.title3)
                                .padding()

                            Divider()

                            Text(alternative.price.formatted(.currency(code: "USD")))
                                .font(.title3)
                                .bold()
                                .padding()

                            Divider()

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(alternative.features, id: \.self) { feature in
                                    Feature(text: feature, isIncluded: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                            Spacer()

                            Button("Visit Website").accessibilityLabel("Button").accessibilityLabel("Button") {
                                // Open website
                            }
                            .buttonStyle(.bordered)
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    }
                }

                Button("Close").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .padding(.top)
            }
            .padding()
        }
    }

    struct SubscriptionEditModel {
        var name: String
        var provider: String
        var amount: Double
        var billingCycle: String
        var startDate: Date?
        var nextPaymentDate: Date?
        var notes: String
        var currencyCode: String
        var category: String?
        var paymentMethod: String?
        var autoRenews: Bool

        init(from subscription: Subscription) {
            self.name = subscription.name
            self.provider = subscription.provider
            self.amount = subscription.amount
            self.billingCycle = subscription.billingCycle
            self.startDate = subscription.startDate
            self.nextPaymentDate = subscription.nextPaymentDate
            self.notes = subscription.notes
            self.currencyCode = subscription.currencyCode
            self.category = subscription.category
            self.paymentMethod = subscription.paymentMethod
            self.autoRenews = subscription.autoRenews
        }
    }

#endif
