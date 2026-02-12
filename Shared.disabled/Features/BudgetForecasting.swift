import Foundation
import MomentumFinanceCore
import SwiftData

/// Budget forecasting using trend analysis
@MainActor
public final class BudgetForecastingService {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Forecast spending for next month
    public func forecastNextMonth(category: ExpenseCategory? = nil) async -> Forecast {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            // Filter by category if specified
            let relevantTransactions = if let category {
                transactions.filter { $0.category == category && $0.transactionType == .expense }
            } else {
                transactions.filter { $0.transactionType == .expense }
            }

            // Get last 3 months
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
            let recentTransactions = relevantTransactions.filter { $0.date >= threeMonthsAgo }

            // Calculate monthly averages
            let monthlyTotals = calculateMonthlyTotals(recentTransactions)

            // Apply trend analysis
            let trend = calculateTrend(monthlyTotals)
            let baselineAverage = monthlyTotals.reduce(0, +) / Double(max(monthlyTotals.count, 1))

            // Forecast with trend adjustment
            let forecastAmount = baselineAverage * (1 + trend)

            // Seasonal adjustment
            let seasonalFactor = calculateSeasonalFactor(for: Date())
            let adjustedForecast = forecastAmount * seasonalFactor

            return Forecast(
                amount: adjustedForecast,
                confidence: calculateConfidence(monthlyTotals),
                trend: trend > 0 ? .increasing : (trend < 0 ? .decreasing : .stable),
                category: category?.name
            )
        } catch {
            print("Error forecasting: \(error)")
            return Forecast(amount: 0, confidence: 0, trend: .stable, category: nil)
        }
    }

    private func calculateMonthlyTotals(_ transactions: [FinancialTransaction]) -> [Double] {
        var monthlyTotals: [String: Double] = [:]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        for transaction in transactions {
            let monthKey = formatter.string(from: transaction.date)
            monthlyTotals[monthKey, default: 0] += abs(transaction.amount)
        }

        let sortedKeys = monthlyTotals.keys.sorted()
        return sortedKeys.map { monthlyTotals[$0]! }
    }

    private func calculateTrend(_ values: [Double]) -> Double {
        guard values.count >= 2 else { return 0 }

        // Simple linear regression slope
        let n = Double(values.count)
        let x = Array(1...values.count).map { Double($0) }
        let y = values

        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)

        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)

        return slope / (sumY / n) // Normalize to percentage
    }

    private func calculateSeasonalFactor(for date: Date) -> Double {
        let month = Calendar.current.component(.month, from: date)

        // Seasonal spending patterns (higher during holidays)
        switch month {
        case 11, 12: return 1.3 // Holiday season
        case 8, 9: return 1.1 // Back to school
        case 1: return 0.9 // Post-holiday recovery
        default: return 1.0
        }
    }

    private func calculateConfidence(_ values: [Double]) -> Double {
        guard values.count >= 3 else { return 0.3 }

        // Confidence based on data consistency
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let stdDev = sqrt(variance)
        let coefficientOfVariation = stdDev / mean

        // Lower CV = higher confidence
        return max(0.3, min(0.95, 1.0 - coefficientOfVariation))
    }
}

public struct Forecast {
    public let amount: Double
    public let confidence: Double // 0.0 to 1.0
    public let trend: TrendDirection
    public let category: String?
}

public enum TrendDirection {
    case increasing, decreasing, stable
}
