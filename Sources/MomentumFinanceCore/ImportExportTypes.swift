import Foundation

// MARK: - Export Types

public enum ExportFormat: String, CaseIterable, Sendable {
    case csv
    case pdf
    case json

    public var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .pdf: "pdf"
        case .json: "json"
        }
    }
}

public enum DateRange: String, CaseIterable, Sendable {
    case lastWeek
    case lastMonth
    case lastThreeMonths
    case lastSixMonths
    case lastYear
    case allTime
    case custom
}

public struct ExportSettings: Sendable {
    public let format: ExportFormat
    public let dateRange: DateRange
    public let includeCategories: Bool
    public let includeAccounts: Bool
    public let includeBudgets: Bool
    public let startDate: Date
    public let endDate: Date

    public init(
        format: ExportFormat,
        dateRange: DateRange,
        includeCategories: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true,
        startDate: Date,
        endDate: Date
    ) {
        self.format = format
        self.dateRange = dateRange
        self.includeCategories = includeCategories
        self.includeAccounts = includeAccounts
        self.includeBudgets = includeBudgets
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Import Types

public enum ImportError: LocalizedError, Sendable {
    case fileAccessDenied
    case invalidFormat(String)
    case parsingError(String)
    case missingRequiredField(String)
    case emptyFile
    case invalidDateFormat(String)
    case invalidAmountFormat(String)

    public var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            "The selected file could not be accessed."
        case let .invalidFormat(message):
            message
        case let .parsingError(message):
            message
        case let .missingRequiredField(field):
            "CSV is missing required field: \(field)."
        case .emptyFile:
            "CSV file is empty."
        case let .invalidDateFormat(value):
            "Invalid date format: \(value)."
        case let .invalidAmountFormat(value):
            "Invalid amount format: \(value)."
        }
    }
}

public struct ImportResult: Sendable {
    public let success: Bool
    public let itemsImported: Int
    public let errors: [String]

    public init(success: Bool, itemsImported: Int, errors: [String]) {
        self.success = success
        self.itemsImported = itemsImported
        self.errors = errors
    }
}
