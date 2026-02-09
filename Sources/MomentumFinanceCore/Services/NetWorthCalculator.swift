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

@MainActor
class NetWorthCalculator {
    @MainActor static let shared = NetWorthCalculator()

    func calculateCurrentNetWorth(accounts: [NetWorthAccount]) -> Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    func generateHistory(accounts: [NetWorthAccount], transactions: [CoreTransaction])
        -> [NetWorthPoint]
    {
        // Replay transactions to build history
        // This is complex; simplified placeholder for now
        []
    }
}

// Placeholder Account struct
struct NetWorthAccount: Identifiable {
    let id = UUID()
    let name: String
    let balance: Decimal
    let type: NetWorthAccountType
}

enum NetWorthAccountType {
    case asset
    case liability
}
