//
//  ExportTypes.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// Export format types supported by the application
public enum ExportFormat: String, Codable, CaseIterable {
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
}

/// Export options for customizing the export process
public struct ExportOptions: Codable {
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
public enum ImportFormat: String, Codable, CaseIterable {
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
public struct ImportResult {
    public let success: Bool
    public let importedCount: Int
    public let failedCount: Int
    public let errors: [ImportValidationError]
    public let warnings: [String]

    public init(
        success: Bool,
        importedCount: Int = 0,
        failedCount: Int = 0,
        errors: [ImportValidationError] = [],
        warnings: [String] = []
    ) {
        self.success = success
        self.importedCount = importedCount
        self.failedCount = failedCount
        self.errors = errors
        self.warnings = warnings
    }
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
public struct ExportResult {
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
