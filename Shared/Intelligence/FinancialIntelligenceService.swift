import CoreML
import Foundation
import OSLog
import SwiftData
import SwiftUI
import MomentumFinanceCore

// Momentum Finance - Financial Intelligence Services
// Copyright © 2025 Momentum Finance. All rights reserved.

/**
 Central service providing financial intelligence and machine learning insights.
 
 ## Overview
 `FinancialIntelligenceService` coordinates multiple ML-powered analysis systems to provide
 actionable financial insights. It aggregates data from transactions, budgets, accounts, and
 goals to detect patterns, anomalies, and optimization opportunities.
 
 ## Architecture
 This service uses a delegation pattern, coordinating specialized components:
 - **TransactionPatternAnalyzer**: Detects spending patterns and duplicate transactions
 - **FinancialMLModels**: Machine learning category prediction and forecasting
 - **Analysis Helpers**: Statistical analysis algorithms (implemented in extensions)
 
 ## ML Models Used
 
 ### 1. Category Classification Model
 **Type**: Supervised Classification (likely Decision Tree or Random Forest)
 
 **Purpose**: Automatically categorizes transactions based on historical data
 
 **Input Features**:
 - Transaction amount
 - Merchant name (tokenized)
 - Transaction date/time patterns
 - Historical category assignments
 
 **Output**: Suggested `ExpenseCategory` with confidence score
 
 **Training Data**: Historical user transactions with manual category assignments
 
 **Usage**:
 ```swift
 let suggestedCategory = service.suggestCategoryForTransaction(newTransaction)
 ```
 
 ### 2. Spending Forecast Model
 **Type**: Time Series Prediction (likely ARIMA or Prophet-style model)
 
 **Purpose**: Predicts future spending based on historical patterns
 
 **Input Features**:
 - Historical transaction amounts (time series)
 - Seasonal patterns (monthly, weekly)
 - Category-specific trends
 - Account balance history
 
 **Output**: Predicted spending amounts for future periods (7, 30, 90 days)
 
 **Training Data**: Minimum 3 months of transaction history for reliable predictions
 
 **Usage**: Automatically called during `analyzeFinancialData()`
 
 ### 3. Anomaly Detection Model
 **Type**: Statistical Outlier Detection (Z-score or isolation forest)
 
 **Purpose**: Detects unusual transactions that deviate from normal spending patterns
 
 **Method**:
 - Calculates mean and standard deviation for each category
 - Identifies transactions > 2σ (standard deviations) from mean
 - Flags large or unusual transactions for review
 
 **Output**: `FinancialInsight` with anomaly type and severity
 
 **Usage**: Automatically called during `analyzeFinancialData()`
 
 ## Analysis Pipeline
 
 The `analyzeFinancialData()` method runs a comprehensive analysis:
 
 1. **Data Fetching**: Retrieves all transactions, budgets, accounts, categories
 2. **Parallel Analysis**:
    - Spending pattern detection
    - Anomaly identification
    - Budget health assessment
    - Cash flow forecasting
    - Optimization suggestions
 3. **Insight Aggregation**: Combines and prioritizes insights
 4. **UI Update**: Publishes results via `@Published` properties
 
 ## Insight Types
 
 - **Pattern Insights**: "You spend 30% more on weekends"
 - **Anomaly Insights**: "Unusual transaction detected: $500 at XYZ Store"
 - **Budget Insights**: "80% of Groceries budget used this month"
 - **Forecast Insights**: "Predicted spending next month: $2,400"
 - **Optimization Insights**: "Move idle cash to high-yield savings"
 
 ## Performance Considerations
 
 - Analysis runs asynchronously (`async` method)
 - Results cached in `insights` property
 - `lastAnalysisDate` tracks when analysis was last run
 - `isAnalyzing` flag prevents concurrent analysis
 
 ## Example Usage
 ```swift
 let service = FinancialIntelligenceService.shared
 
 // Run comprehensive analysis
 await service.analyzeFinancialData(modelContext: context)
 
 // Access insights
 for insight in service.insights {
     print("\\(insight.title): \\(insight.description)")
 }
 
 // Auto-categorize new transaction
 if let category = service.suggestCategoryForTransaction(newTx) {
     newTx.category = category
 }
 ```
 
 - Note: This service requires a minimum dataset for meaningful insights:
   - At least 3 months of transaction history
   - At least 50 transactions across multiple categories
   - Active budget tracking for budget-related insights
 */
@MainActor
public class FinancialIntelligenceService: ObservableObject {
    @MainActor static let shared = FinancialIntelligenceService()

    @Published var insights: [FinancialInsight] = []
    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?

    private let mlModels = FinancialMLModels.shared
    private let patternAnalyzer = TransactionPatternAnalyzer.shared

    private init() {
        // Initialization handled by component models
    }

    // MARK: - Analysis Methods

    /// Performs a comprehensive analysis of financial data
    func analyzeFinancialData(modelContext: ModelContext) async {
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.insights = []
        }

        do {
            // Fetch all data
            let transactionsDescriptor = FetchDescriptor<FinancialTransaction>()
            let transactions = try modelContext.fetch(transactionsDescriptor)

            let categoriesDescriptor = FetchDescriptor<ExpenseCategory>()
            let categories = try modelContext.fetch(categoriesDescriptor)

            let accountsDescriptor = FetchDescriptor<FinancialAccount>()
            let accounts = try modelContext.fetch(accountsDescriptor)

            let budgetsDescriptor = FetchDescriptor<Budget>()
            let budgets = try modelContext.fetch(budgetsDescriptor)

            // Delegate to specialized analysis methods in Helpers
            let spendingPatternInsights = self.analyzeSpendingPatterns(
                transactions: transactions, categories: categories
            )
            let anomalyInsights = self.detectAnomalies(transactions: transactions)
            let budgetInsights = self.analyzeBudgets(transactions: transactions, budgets: budgets)
            let forecastInsights = fi_generateForecasts(
                transactions: transactions, accounts: accounts
            )
            let optimizationInsights = self.suggestOptimizations(
                transactions: transactions,
                accounts: accounts
            )

            // Combine all insights and sort by priority
            var allInsights =
                spendingPatternInsights + anomalyInsights + budgetInsights + forecastInsights
                    + optimizationInsights
            allInsights.sort { $0.priority > $1.priority }

            // Update the UI
            DispatchQueue.main.async {
                self.insights = allInsights
                self.isAnalyzing = false
                self.lastAnalysisDate = Date()
            }
        } catch {
            print("Error analyzing financial data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAnalyzing = false
            }
        }
    }

    /// Categorizes a new transaction based on historical data
    func suggestCategoryForTransaction(_ transaction: FinancialTransaction) -> ExpenseCategory? {
        self.mlModels.suggestCategoryForTransaction(transaction)
    }

    // MARK: - Specific Analysis Methods (Delegate to Helpers)

    private func analyzeSpendingPatterns(
        transactions: [FinancialTransaction], categories: [ExpenseCategory]
    ) -> [FinancialInsight] {
        fi_analyzeSpendingPatterns(transactions: transactions, categories: categories)
    }

    private func detectAnomalies(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        fi_detectAnomalies(transactions: transactions)
    }

    private func analyzeBudgets(transactions: [FinancialTransaction], budgets: [Budget])
        -> [FinancialInsight] {
        fi_analyzeBudgets(transactions: transactions, budgets: budgets)
    }

    // Forecasting is implemented canonically in
    // FinancialIntelligenceService.Forecasting.swift — use fi_generateForecasts to call it.

    private func suggestOptimizations(
        transactions: [FinancialTransaction], accounts: [FinancialAccount]
    ) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        insights.append(
            contentsOf: fi_suggestIdleCashInsights(transactions: transactions, accounts: accounts)
        )
        insights.append(contentsOf: fi_suggestCreditUtilizationInsights(accounts: accounts))
        insights.append(contentsOf: fi_suggestDuplicatePaymentInsights(transactions: transactions))

        return insights
    }
}
