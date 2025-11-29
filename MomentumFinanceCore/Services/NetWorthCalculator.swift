//
// NetWorthCalculator.swift
// MomentumFinance
//
// Service for calculating net worth over time
//

import Foundation

struct NetWorthPoint: Identifiable {
    let id = UUID()
    let date: Date
    let assets: Decimal
    let liabilities: Decimal
    var netWorth: Decimal { assets - liabilities }
}

class NetWorthCalculator {
    static let shared = NetWorthCalculator()
    
    func calculateCurrentNetWorth(accounts: [Account]) -> Decimal {
        return accounts.reduce(0) { $0 + $1.balance }
    }
    
    func generateHistory(accounts: [Account], transactions: [Transaction]) -> [NetWorthPoint] {
        // Replay transactions to build history
        // This is complex; simplified placeholder for now
        return []
    }
}

// Placeholder Account struct
struct Account: Identifiable {
    let id = UUID()
    let name: String
    let balance: Decimal
    let type: AccountType
}

enum AccountType {
    case asset
    case liability
}
