//
//  String+Localization.swift
//  MomentumFinance
//
//  Localization helper extension
//

import Foundation

extension String {
    /// Returns a localized version of the string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

/// Centralized localization keys for type-safe access
enum L10n {
    enum App {
        static let name = "app.name".localized
        static let tagline = "app.tagline".localized
    }
    
    enum Tab {
        static let dashboard = "tab.dashboard".localized
        static let accounts = "tab.accounts".localized
        static let transactions = "tab.transactions".localized
        static let budgets = "tab.budgets".localized
        static let goals = "tab.goals".localized
        static let insights = "tab.insights".localized
        static let settings = "tab.settings".localized
    }
    
    enum Dashboard {
        static let title = "dashboard.title".localized
        static let netWorth = "dashboard.netWorth".localized
        static let totalBalance = "dashboard.totalBalance".localized
        static let monthlySpending = "dashboard.monthlySpending".localized
        static let monthlyIncome = "dashboard.monthlyIncome".localized
        static let recentTransactions = "dashboard.recentTransactions".localized
    }
    
    enum Account {
        static let title = "account.title".localized
        static let add = "account.add".localized
        static let edit = "account.edit".localized
        static let delete = "account.delete".localized
        static let name = "account.name".localized
        static let balance = "account.balance".localized
        static let currency = "account.currency".localized
    }
    
    enum Transaction {
        static let title = "transaction.title".localized
        static let add = "transaction.add".localized
        static let edit = "transaction.edit".localized
        static let delete = "transaction.delete".localized
        static let amount = "transaction.amount".localized
        static let date = "transaction.date".localized
        static let category = "transaction.category".localized
        static let note = "transaction.note".localized
    }
    
    enum Budget {
        static let title = "budget.title".localized
        static let create = "budget.create".localized
        static let edit = "budget.edit".localized
        static let delete = "budget.delete".localized
        static let name = "budget.name".localized
        static let amount = "budget.amount".localized
        static let spent = "budget.spent".localized
        static let remaining = "budget.remaining".localized
        
        static func progress(_ percent: Int) -> String {
            "budget.progress".localized(with: percent)
        }
    }
    
    enum Action {
        static let save = "action.save".localized
        static let cancel = "action.cancel".localized
        static let delete = "action.delete".localized
        static let edit = "action.edit".localized
        static let done = "action.done".localized
        static let ok = "action.ok".localized
        static let add = "action.add".localized
    }
    
    enum Error {
        static let generic = "error.generic".localized
        static let network = "error.network".localized
        static let loadFailed = "error.loadFailed".localized
        static let saveFailed = "error.saveFailed".localized
    }
}
