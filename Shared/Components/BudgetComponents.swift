//
//  BudgetComponents.swift
//  MomentumFinance
//
//  Extracted components from BudgetsView for SwiftLint compliance
//

import MomentumFinanceCore
import SwiftUI

// MARK: - Budget Row Component

/// Individual budget row showing category and progress
struct BudgetRow: View {
    let budget: Budget

    var progress: Double {
        guard budget.limitAmount > 0 else { return 0 }
        return min(budget.spentAmount / budget.limitAmount, 1.0)
    }

    var progressColor: Color {
        if progress >= 1.0 {
            .red
        } else if progress >= 0.8 {
            .orange
        } else {
            .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category?.name ?? "Uncategorized")
                    .font(.headline)

                Spacer()

                Text(
                    "$\(budget.spentAmount, specifier: "%.2f") / $\(budget.limitAmount, specifier: "%.2f")"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(progressColor)

            Text("\(Int(progress * 100))% used")
                .font(.caption)
                .foregroundStyle(progressColor)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
