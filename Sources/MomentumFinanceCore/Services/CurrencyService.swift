//
// CurrencyService.swift
// MomentumFinance
//
// Service for multi-currency support and exchange rates
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"

    var id: String {
        rawValue
    }

    var symbol: String {
        switch self {
        case .usd, .cad: "$"
        case .eur: "€"
        case .gbp: "£"
        case .jpy: "¥"
        }
    }
}

@MainActor
class CurrencyService {
    @MainActor static let shared = CurrencyService()

    /// Fallback exchange rates (Base: USD)
    /// > [!NOTE]
    /// > These are used when real-time pricing data is unavailable.
    private static let fallbackRates: [Currency: Decimal] = [
        .usd: 1.0,
        .eur: 0.92,
        .gbp: 0.79,
        .jpy: 150.5,
        .cad: 1.35,
    ]

    func convert(amount: Decimal, from source: Currency, to target: Currency) -> Decimal {
        guard let sourceRate = Self.fallbackRates[source],
              let targetRate = Self.fallbackRates[target]
        else {
            return amount
        }

        // Convert to USD first, then to target
        let amountInUSD = amount / sourceRate
        return amountInUSD * targetRate
    }

    func format(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)\(amount)"
    }
}
