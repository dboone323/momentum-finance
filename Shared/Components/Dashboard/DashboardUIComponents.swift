//
//  DashboardUIComponents.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-09-05.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import MomentumFinanceCore
import SwiftData
import SwiftUI

// Import the models
// Note: FinancialAccount should be available from the Models folder

// MARK: - Dashboard Welcome Header

public struct DashboardWelcomeHeader: View {
    public let userName: String

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back, \(self.userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Here's your financial overview")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    public init(userName: String) {
        self.userName = userName
    }
}

// MARK: - Dashboard Accounts Summary

// formatCurrency removed (duplicate)
