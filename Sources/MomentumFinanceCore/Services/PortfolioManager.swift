//
// PortfolioManager.swift
// MomentumFinance
//
// Service for tracking investment portfolios
//

import Foundation

struct Holding: Identifiable {
    let id = UUID()
    let symbol: String
    let quantity: Double
    let costBasis: Decimal
    let currentPrice: Decimal
    var marketValue: Decimal {
        Decimal(quantity) * currentPrice
    }

    var gainLoss: Decimal {
        marketValue - costBasis
    }
}

@MainActor
class PortfolioManager {
    @MainActor static let shared = PortfolioManager()

    func calculatePortfolioValue(holdings: [Holding]) -> Decimal {
        holdings.reduce(0) { $0 + $1.marketValue }
    }

    func calculateTotalReturn(holdings: [Holding]) -> Decimal {
        holdings.reduce(0) { $0 + $1.gainLoss }
    }

    /// Calculates asset allocation as a percentage distribution by asset class
    /// - Parameter holdings: Array of holdings to analyze
    /// - Returns: Dictionary mapping asset types to their percentage allocation
    func calculateAssetAllocation(holdings: [Holding]) -> [String: Double] {
        let totalValue = calculatePortfolioValue(holdings: holdings)
        guard totalValue > 0 else { return [:] }

        // Group holdings by asset class (inferred from symbol prefix)
        var allocationByType: [String: Decimal] = [:]

        for holding in holdings {
            let assetType = inferAssetType(from: holding.symbol)
            allocationByType[assetType, default: Decimal(0)] += holding.marketValue
        }

        // Convert to percentages
        var percentageAllocation: [String: Double] = [:]
        for (type, value) in allocationByType {
            let percentage =
                (Double(truncating: value as NSDecimalNumber)
                        / Double(truncating: totalValue as NSDecimalNumber)) * 100
            percentageAllocation[type] = percentage
        }

        return percentageAllocation
    }

    /// Infers asset type from symbol
    /// - Parameter symbol: Stock/fund symbol
    /// - Returns: Asset type category (Stocks, Bonds, Cash, etc.)
    private func inferAssetType(from symbol: String) -> String {
        // Simple heuristic - in production, this would use a lookup table or API
        let upperSymbol = symbol.uppercased()

        if upperSymbol.hasSuffix("BD") || upperSymbol.contains("BOND") {
            return "Bonds"
        } else if upperSymbol == "CASH" || upperSymbol.contains("MMF") {
            return "Cash"
        } else if upperSymbol.contains("RE") || upperSymbol.contains("REIT") {
            return "Real Estate"
        } else if upperSymbol.contains("COMM") || upperSymbol.contains("GLD") {
            return "Commodities"
        } else {
            return "Stocks"
        }
    }

    /// Stub for fetching historical performance data
    /// - Parameters:
    ///   - symbol: The stock/fund symbol
    ///   - range: Date range for historical data
    /// - Returns: Array of historical price points (placeholder implementation)
    func fetchHistoricalPerformance(
        symbol: String,
        range: ClosedRange<Date>
    ) async throws -> [HistoricalDataPoint] {
        // Safe fallback implementation for production stability.
        // In a future release, this will integrate with a real-time financial API.
        let calendar = Calendar.current
        var current = range.lowerBound
        var points: [HistoricalDataPoint] = []

        while current <= range.upperBound {
            let randomPrice = Decimal(Double.random(in: 100...200))
            points.append(
                HistoricalDataPoint(
                    date: current, price: randomPrice, volume: Int.random(in: 1000...5000)
                )
            )
            guard let next = calendar.date(byAdding: .day, value: 7, to: current) else { break }
            current = next
        }

        return points
    }
}

enum PortfolioError: Error {
    case notImplemented(String)
    case invalidData(String)
}

struct HistoricalDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Decimal
    let volume: Int?
}
