import Foundation
import SwiftData

/// Accounts data generator
@MainActor
final class AccountsGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generates sample financial accounts for the app
    func generate() {
        let accounts = [
            (
                name: "Checking Account", icon: "creditcard.fill", balance: Decimal(2500),
                type: AccountType.checking
            ),
            (
                name: "Savings Account", icon: "building.columns.fill", balance: Decimal(15000),
                type: AccountType.savings
            ),
            (
                name: "Credit Card", icon: "creditcard", balance: Decimal(-850),
                type: AccountType.credit
            ),
            (
                name: "Investment Account",
                icon: "chart.line.uptrend.xyaxis",
                balance: Decimal(25000),
                type: AccountType.investment
            ),
            (
                name: "Emergency Fund", icon: "shield.fill", balance: Decimal(5000),
                type: AccountType.savings
            ),
            (name: "Cash", icon: "banknote", balance: Decimal(150), type: AccountType.cash),
        ]

        for account in accounts {
            let newAccount = FinancialAccount(
                name: account.name,
                balance: account.balance,
                iconName: account.icon,
                accountType: account.type
            )
            self.modelContext.insert(newAccount)
        }

        try? self.modelContext.save()
    }
}
