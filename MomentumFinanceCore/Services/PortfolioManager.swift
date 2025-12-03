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
    var marketValue: Decimal { Decimal(quantity) * currentPrice }
    var gainLoss: Decimal { marketValue - costBasis }
}

class PortfolioManager {
    static let shared = PortfolioManager()

    func calculatePortfolioValue(holdings: [Holding]) -> Decimal {
        holdings.reduce(0) { $0 + $1.marketValue }
    }

    func calculateTotalReturn(holdings: [Holding]) -> Decimal {
        holdings.reduce(0) { $0 + $1.gainLoss }
    }
}
