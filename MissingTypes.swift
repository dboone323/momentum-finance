import Foundation
import SwiftData
import SwiftUI
import UserNotifications

// MARK: - REMOVED: Types moved to proper files

// - CoreFinancialModels.swift: FinancialAccount, ExpenseCategory, FinancialTransaction, Budget
// - FinancialIntelligenceModels.swift: FinancialInsight, InsightPriority, ForecastData
// - DataImportModels.swift: ValidationError, ImportResult, CSVColumnMapping
// - ThemeModels.swift: ThemeMode, ColorDefinitions, DarkModePreference
// - TransactionModels.swift: TransactionFilter, BreadcrumbItem, DeepLink
// - FinancialServices.swift: EntityManager, DefaultEntityManager, ExportEngineService, FinancialMLModels,
// TransactionPatternAnalyzer
// - AnimationComponents.swift: AnimatedCardComponent, AnimatedButtonComponent, etc.
// - ImportComponents.swift: DataImportHeaderComponent, FileSelectionComponent, etc.
// - InsightsComponents.swift: InsightsLoadingView, InsightRowView, etc.
// - TransactionComponents.swift: TransactionEmptyStateView, TransactionListView, etc.
// - ButtonStyles.swift: PrimaryButtonStyle, SecondaryButtonStyle, etc.
// - ThemeDemoComponents.swift: ThemeSelectorCard, ThemeFinancialSummaryCard, etc.
// - ThemeSettingsComponents.swift: ThemeBudgetProgress, ThemeSettingsSheet, etc.
// - FinancialUtilities.swift: formatCurrency, fi_* functions

// MARK: - ModelContext for compatibility

#if !canImport(SwiftData)
    public struct ModelContext: Sendable {
        public init() {}
    }
#endif
