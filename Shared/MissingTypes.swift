// MissingTypes.swift (Minimal Stub)
// Purpose: Temporary navigation types only. All previous large content moved.
// Safe to remove once BreadcrumbItem & DeepLink are relocated.

import Foundation
import MomentumFinanceCore
import SwiftUI

// Definitions removed as they are now provided by BreadcrumbNavigation.swift

// MARK: - Financial Intelligence Shared Types

public enum RiskTolerance: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

public struct Investment: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let symbol: String
    public let value: Double

    public init(id: UUID = UUID(), name: String, symbol: String, value: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.value = value
    }
}

// MARK: - Compatibility Helpers

func fi_formatCurrency(_ amount: Double, code: String = "USD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = code
    return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
}

func fi_formatCurrency(_ amount: Decimal, code: String = "USD") -> String {
    fi_formatCurrency(Double(truncating: amount as NSDecimalNumber), code: code)
}

func fi_formatMonthAbbrev(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter.string(from: date)
}

extension FinancialAccount {
    var currencyCode: String { currency }
}
