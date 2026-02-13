//
//  ExportTypes.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// Export format types supported by the application
public enum ExportFormat: String, Codable, CaseIterable, Sendable {
    case csv = "CSV"
    case json = "JSON"
    case pdf = "PDF"
    case excel = "Excel"

    public var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .json: "json"
        case .pdf: "pdf"
        case .excel: "xlsx"
        }
    }

    public var mimeType: String {
        switch self {
        case .csv: "text/csv"
        case .json: "application/json"
        case .pdf: "application/pdf"
        case .excel: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
    }

    public var displayName: String {
        switch self {
        case .csv: "CSV"
        case .json: "JSON Data"
        case .pdf: "PDF Report"
        case .excel: "Excel Spreadsheet"
        }
    }

    public var icon: String {
        switch self {
        case .csv: "tablecells"
        case .json: "curlybraces"
        case .pdf: "doc.text"
        case .excel: "tablecells.fill"
        }
    }
}

public struct ExportConstants {
    public static let csvFilename = "MomentumFinance_Export.csv"
    public static let pdfFilename = "MomentumFinance_Report.pdf"
    public static let jsonFilename = "MomentumFinance_Backup.json"
}

public enum DateRange: String, Codable, CaseIterable, Sendable {
    case lastWeek
    case lastMonth
    case lastThreeMonths
    case lastSixMonths
    case lastYear
    case allTime
    case custom

    public var displayName: String {
        switch self {
        case .lastWeek: "Last Week"
        case .lastMonth: "Last Month"
        case .lastThreeMonths: "Last 3 Months"
        case .lastSixMonths: "Last 6 Months"
        case .lastYear: "Last Year"
        case .allTime: "All Time"
        case .custom: "Custom Range"
        }
    }
}

public struct ExportSettings: Sendable {
    public let format: ExportFormat
    public let dateRange: DateRange
    public let startDate: Date
    public let endDate: Date
    public let includeTransactions: Bool
    public let includeAccounts: Bool
    public let includeBudgets: Bool
    public let includeSubscriptions: Bool
    public let includeGoals: Bool
    public let isEncrypted: Bool

    public init(
        format: ExportFormat,
        dateRange: DateRange,
        startDate: Date,
        endDate: Date,
        includeTransactions: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true,
        includeSubscriptions: Bool = true,
        includeGoals: Bool = true,
        isEncrypted: Bool = false
    ) {
        self.format = format
        self.dateRange = dateRange
        self.startDate = startDate
        self.endDate = endDate
        self.includeTransactions = includeTransactions
        self.includeAccounts = includeAccounts
        self.includeBudgets = includeBudgets
        self.includeSubscriptions = includeSubscriptions
        self.includeGoals = includeGoals
        self.isEncrypted = isEncrypted
    }
}

/// Export options for customizing the export process
public struct ExportOptions: Codable, Sendable {
    public let format: ExportFormat
    public let dateRange: DateInterval?
    public let includeCategories: Bool
    public let includeTags: Bool
    public let includeNotes: Bool
    public let groupByCategory: Bool

    public init(
        format: ExportFormat,
        dateRange: DateInterval? = nil,
        includeCategories: Bool = true,
        includeTags: Bool = true,
        includeNotes: Bool = true,
        groupByCategory: Bool = false
    ) {
        self.format = format
        self.dateRange = dateRange
        self.includeCategories = includeCategories
        self.includeTags = includeTags
        self.includeNotes = includeNotes
        self.groupByCategory = groupByCategory
    }
}

/// Import format types supported by the application
public enum ImportFormat: String, Codable, CaseIterable, Sendable {
    case csv = "CSV"
    case json = "JSON"
    case qif = "QIF"
    case ofx = "OFX"

    public var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .json: "json"
        case .qif: "qif"
        case .ofx: "ofx"
        }
    }
}

/// Import result containing success/failure information
public struct ImportResult: Sendable {
    public let success: Bool
    public let importedCount: Int
    public let failedCount: Int
    public let errors: [String]
    public let validationErrors: [ImportValidationError]
    public let warnings: [String]

    public init(
        success: Bool,
        importedCount: Int = 0,
        failedCount: Int = 0,
        errors: [String] = [],
        validationErrors: [ImportValidationError] = [],
        warnings: [String] = []
    ) {
        self.success = success
        self.importedCount = importedCount
        self.failedCount = failedCount
        self.errors = errors
        self.validationErrors = validationErrors
        self.warnings = warnings
    }

    public init(
        success: Bool,
        itemsImported: Int,
        itemsFailed: Int = 0,
        errors: [String] = [],
        validationErrors: [ImportValidationError] = [],
        warnings: [String] = []
    ) {
        self.init(
            success: success,
            importedCount: itemsImported,
            failedCount: itemsFailed,
            errors: errors,
            validationErrors: validationErrors,
            warnings: warnings
        )
    }

    public var itemsImported: Int { importedCount }
    public var itemsFailed: Int { failedCount }
}

/// Import validation error with detailed information
public struct ImportValidationError: Identifiable, Sendable {
    public let id = UUID()
    public let row: Int?
    public let field: String?
    public let message: String
    public let value: String?

    public init(row: Int? = nil, field: String? = nil, message: String, value: String? = nil) {
        self.row = row
        self.field = field
        self.message = message
        self.value = value
    }
}

/// Export result containing success/failure information
public struct ExportResult: Sendable {
    public let success: Bool
    public let fileURL: URL?
    public let exportedCount: Int
    public let errors: [String]
    public let warnings: [String]

    public init(
        success: Bool,
        fileURL: URL? = nil,
        exportedCount: Int = 0,
        errors: [String] = [],
        warnings: [String] = []
    ) {
        self.success = success
        self.fileURL = fileURL
        self.exportedCount = exportedCount
        self.errors = errors
        self.warnings = warnings
    }
}
