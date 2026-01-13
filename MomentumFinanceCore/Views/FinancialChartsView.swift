//
// FinancialChartsView.swift
// MomentumFinance
//
// Step 24: SwiftUI Charts for financial trends.
//

import SwiftUI
import Charts

/// Data point for financial chart.
struct FinancialDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let category: String
}

/// Spending trends chart using Swift Charts.
struct SpendingTrendsChart: View {
    let data: [FinancialDataPoint]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Chart(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.value)
                )
                .foregroundStyle(by: .value("Category", point.category))
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.value)
                )
                .foregroundStyle(by: .value("Category", point.category))
                .opacity(0.1)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Category breakdown pie chart.
struct CategoryBreakdownChart: View {
    let data: [FinancialDataPoint]
    
    private var categoryTotals: [(category: String, total: Double)] {
        Dictionary(grouping: data, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.value } }
            .map { (category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Chart(categoryTotals, id: \.category) { item in
                SectorMark(
                    angle: .value("Amount", item.total),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Category", item.category))
            }
            .frame(height: 200)
            
            // Legend
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(categoryTotals, id: \.category) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                        Text(item.category)
                            .font(.caption)
                        Spacer()
                        Text("$\(Int(item.total))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Net worth trend chart.
struct NetWorthChart: View {
    let data: [FinancialDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Net Worth Trend")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Chart(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .month),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(point.value >= 0 ? Color.green : Color.red)
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount / 1000))K")
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Preview helper
#Preview {
    let sampleData: [FinancialDataPoint] = {
        var data: [FinancialDataPoint] = []
        let calendar = Calendar.current
        let categories = ["Food", "Transport", "Shopping", "Bills"]
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            for category in categories {
                data.append(FinancialDataPoint(
                    date: date,
                    value: Double.random(in: 10...100),
                    category: category
                ))
            }
        }
        return data
    }()
    
    ScrollView {
        VStack(spacing: 20) {
            SpendingTrendsChart(data: sampleData, title: "Daily Spending")
            CategoryBreakdownChart(data: sampleData)
        }
        .padding()
    }
}
