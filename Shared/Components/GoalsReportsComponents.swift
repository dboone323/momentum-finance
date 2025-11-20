//
//  GoalsReportsComponents.swift
//  MomentumFinance
//
//  Extracted components from GoalsAndReportsView for SwiftLint compliance
//

import SwiftUI

// MARK: - Goal Progress Components

/// Progress row for a financial goal
struct GoalProgressRow: View {
    let title: String
    let current: Double
    let target: Double
    let color: Color
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(color)
            
            HStack {
                Text("$\(current, specifier: "%.0f")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(target, specifier: "%.0f")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Spending Category Components

/// Category spending row
struct CategorySpendingRow: View {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(category)
                .font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(percentage))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Budget Alert Components

/// Budget alert card
struct BudgetAlertCard: View {
    let category: String
    let spent: Double
    let limit: Double
    let severity: AlertSeverity
    
    enum AlertSeverity {
        case warning, critical
        
        var color: Color {
            switch self {
            case .warning: return .orange
            case .critical: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "exclamationmark.octagon.fill"
            }
        }
    }
    
    var percentage: Double {
        guard limit > 0 else { return 0 }
        return (spent / limit) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: severity.icon)
                .foregroundStyle(severity.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("$\(spent, specifier: "%.0f") of $\(limit, specifier: "%.0f") (\(Int(percentage))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(severity.color.opacity(0.1))
        .cornerRadius(8)
    }
}
