
import XCTest
@testable import MomentumFinance

class OptimizationSuggestionsTests: XCTestCase {
    var transactions: [FinancialTransaction] = []
    var accounts: [FinancialAccount] = []

    override func setUp() {
        super.setUp()
        
        // Create sample transactions and accounts
        let transaction1 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 2),
            amount: -1000.0,
            type: .expense
        )
        
        let transaction2 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 1),
            amount: -2000.0,
            type: .expense
        )
        
        let transaction3 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 0),
            amount: -1500.0,
            type: .expense
        )
        
        let transaction4 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 2),
            amount: -1000.0,
            type: .expense
        )
        
        let transaction5 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 1),
            amount: -2000.0,
            type: .expense
        )
        
        let transaction6 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 0),
            amount: -1500.0,
            type: .expense
        )
        
        let transaction7 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 2),
            amount: -1000.0,
            type: .expense
        )
        
        let transaction8 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 1),
            amount: -2000.0,
            type: .expense
        )
        
        let transaction9 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 0),
            amount: -1500.0,
            type: .expense
        )
        
        let transaction10 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 2),
            amount: -1000.0,
            type: .expense
        )
        
        let transaction11 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 1),
            amount: -2000.0,
            type: .expense
        )
        
        let transaction12 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 0),
            amount: -1500.0,
            type: .expense
        )
        
        let transaction13 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow: -365 * 2),
            amount: -1000.0,
            type: .expense
        )
        
        let transaction14 = FinancialTransaction(
            id: UUID(),
            account: FinancialAccount(id: UUID(), name: "Checking", currencyCode: "USD"),
            date: Date(timeIntervalSinceNow:
