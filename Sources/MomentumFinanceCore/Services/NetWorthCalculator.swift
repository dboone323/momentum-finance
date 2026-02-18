//
// NetWorthCalculator.swift
// MomentumFinance
//
// Service for calculating net worth over time
//

import Foundation

public struct NetWorthPoint: Identifiable, Equatable {
    public let id = UUID()
    public let date: Date
    public let assets: Decimal
    public let liabilities: Decimal
    public var netWorth: Decimal {
        assets - liabilities
    }

    public init(date: Date, assets: Decimal, liabilities: Decimal) {
        self.date = date
        self.assets = assets
        self.liabilities = liabilities
    }
}

@MainActor
public final class NetWorthCalculator {
    public static let shared = NetWorthCalculator()

    private init() {}

    public func calculateCurrentNetWorth(accounts: [FinancialAccount]) -> Decimal {
        let assets = accounts.filter { isAsset($0) }.reduce(0) { $0 + $1.balance }
        let liabilities = accounts.filter { isLiability($0) }.reduce(0) { $0 + $1.balance }
        return assets - liabilities
    }

    public func generateHistory(accounts: [FinancialAccount], transactions: [FinancialTransaction])
        -> [NetWorthPoint]
    {
        var points: [NetWorthPoint] = []
        let calendar = Calendar.current
        let now = Date()

        // 1. Calculate current state
        var runningAssets = accounts.filter { isAsset($0) }.reduce(0) { $0 + $1.balance }
        var runningLiabilities = accounts.filter { isLiability($0) }.reduce(0) { $0 + $1.balance }

        points.append(
            NetWorthPoint(
                date: now,
                assets: runningAssets,
                liabilities: runningLiabilities
            )
        )

        // 2. Generate past 30 days of data based on transactions
        // Sort transactions by date descending for reversal
        let sortedTransactions = transactions.sorted { $0.date > $1.date }

        for dayOffset in 1...30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                continue
            }
            _ = calendar.startOfDay(for: date)

            // Find transactions that happened between now and this past date (exclusive of now's point)
            // But actually we are going day by day backwards.
            // So we reverse transactions that happened on the day we are "moving out of".
            // Since we start at 'now', first offset is 1 day ago.
            // We reverse transactions from day 0 (today) to get to day -1's state.

            let boundaryDate = calendar.date(byAdding: .day, value: -(dayOffset - 1), to: now)!
            let startOfPreviousDay = calendar.startOfDay(for: boundaryDate)
            let endOfPreviousDay = calendar.date(byAdding: .day, value: 1, to: startOfPreviousDay)!

            let dayTransactions = sortedTransactions.filter {
                $0.date >= startOfPreviousDay && $0.date < endOfPreviousDay
            }

            for tx in dayTransactions {
                guard let account = tx.account else { continue }

                // Reversal logic:
                // If tx was income: current = prev + amount -> prev = current - amount
                // If tx was expense: current = prev - amount -> prev = current + amount
                let adjustment = tx.transactionType == .income ? -tx.amount : tx.amount

                if isAsset(account) {
                    runningAssets += adjustment
                } else if isLiability(account) {
                    // For liability accounts (like credit cards),
                    // a 'balance' usually represents debt (positive number).
                    // Income (payment) reduces debt. Expense increases debt.
                    // This matches updateBalance in FinancialAccount.
                    runningLiabilities += adjustment
                }
            }

            points.append(
                NetWorthPoint(
                    date: date,
                    assets: runningAssets,
                    liabilities: runningLiabilities
                )
            )
        }

        return points.sorted { $0.date < $1.date }
    }

    private func isAsset(_ account: FinancialAccount) -> Bool {
        switch account.accountType {
        case .checking, .savings, .investment, .cash:
            true
        case .credit:
            false
        }
    }

    private func isLiability(_ account: FinancialAccount) -> Bool {
        account.accountType == .credit
    }
}
