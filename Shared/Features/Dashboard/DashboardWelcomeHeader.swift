//
//  DashboardWelcomeHeader.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//  Enhanced: 2025-12-05
//

import SwiftUI

extension Features.Dashboard {
    struct DashboardWelcomeHeader: View {
        let greeting: String
        let wellnessPercentage: Int
        let totalBalance: Double
        let monthlyIncome: Double
        let monthlyExpenses: Double

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                // Greeting Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good \(self.greeting),")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("Financial Overview") // Placeholder for user name if not available
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                    }
                    Spacer()
                    // Notification or Profile icon could go here
                }

                // Main Balance Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Balance")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))

                            Text(totalBalance, format: .currency(code: "USD"))
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 20) {
                            // Income
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "arrow.down")
                                            .font(.caption.bold())
                                            .foregroundColor(.green.opacity(0.9))
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Income")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(monthlyIncome, format: .currency(code: "USD"))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }

                            Spacer()

                            // Expenses
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "arrow.up")
                                            .font(.caption.bold())
                                            .foregroundColor(.red.opacity(0.9))
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Expenses")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(monthlyExpenses, format: .currency(code: "USD"))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .padding(.top, 4)
                    }
                    .padding(24)
                }
                .frame(height: 200)
            }
        }
    }
}
