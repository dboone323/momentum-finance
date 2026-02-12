import Foundation
import MomentumFinanceCore

// MARK: - Utility Functions

/// Formats a currency amount with the specified currency code
/// - Parameters:
///   - amount: The amount to format
///   - currencyCode: The ISO 4217 currency code (default: "USD")
///   - showSign: Whether to show a "+" sign for positive amounts (default: false)
/// - Returns: Formatted currency string
public func formatCurrency(_ amount: Double, currencyCode: String = "USD", showSign: Bool = false)
    -> String
{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.maximumFractionDigits = 2

    let nsAmount = NSNumber(value: amount)
    if showSign && amount > 0 {
        return "+" + (formatter.string(from: nsAmount) ?? "$0.00")
    }
    return formatter.string(from: nsAmount) ?? "$0.00"
}

/// Formats a Decimal currency amount with the specified currency code
/// - Parameters:
///   - amount: The Decimal amount to format
///   - currencyCode: The ISO 4217 currency code (default: "USD")
///   - showSign: Whether to show a "+" sign for positive amounts (default: false)
/// - Returns: Formatted currency string
public func formatCurrency(_ amount: Decimal, currencyCode: String = "USD", showSign: Bool = false)
    -> String
{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.maximumFractionDigits = 2

    let nsAmount = NSDecimalNumber(decimal: amount)
    if showSign && amount > 0 {
        return "+" + (formatter.string(from: nsAmount) ?? "$0.00")
    }
    return formatter.string(from: nsAmount) ?? "$0.00"
}

// MARK: - Financial Intelligence Functions

func fi_generateForecasts(transactions _: [Any], accounts _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_analyzeSpendingPatterns(transactions _: [Any], categories _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_detectAnomalies(transactions _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_analyzeBudgets(transactions _: [Any], budgets _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestIdleCashInsights(transactions _: [Any], accounts _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestCreditUtilizationInsights(accounts _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestDuplicatePaymentInsights(transactions _: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}
