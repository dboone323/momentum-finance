//
// FinancialCharts.swift
// MomentumFinance
//
// Reusable chart components
//

import SwiftUI
import Charts

struct SpendingPieChart: View {
    let data: [CategorySpending]
    
    var body: some View {
        Chart(data, id: \.categoryId) { item in
            SectorMark(
                angle: .value("Amount", item.totalAmount),
                innerRadius: .ratio(0.6),
                angularInset: 1.5
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Category", item.categoryId.uuidString))
        }
    }
}

struct NetWorthLineChart: View {
    let data: [NetWorthPoint]
    
    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Date", item.date),
                y: .value("Net Worth", item.netWorth)
            )
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Date", item.date),
                y: .value("Net Worth", item.netWorth)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.green.opacity(0.5), .green.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}
