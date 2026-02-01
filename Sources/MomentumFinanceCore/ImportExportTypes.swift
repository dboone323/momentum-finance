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

    public var displayName: String {
        switch self {
        case .csv: "CSV"
        case .pdf: "PDF Report"
        case .json: "JSON Data"
        }
    }

    public var icon: String {
        switch self {
        case .csv: "tablecells"
        case .pdf: "doc.text"
        case .json: "curlybraces"
        }
    }
}

public enum ExportError: LocalizedError, Sendable {
    case invalidSettings
    case fileAccessFailure
    case pdfGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .invalidSettings: "Invalid export settings."
        case .fileAccessFailure: "Failed to access file location."
        case .pdfGenerationFailed: "Failed to generate PDF document."
        }
    }
}

public struct ExportConstants: Sendable {
    public static let csvFilename = "MomentumFinance_Export.csv"
    public static let pdfFilename = "MomentumFinance_Report.pdf"
    public static let jsonFilename = "MomentumFinance_Backup.json"
}

public enum DateRange: String, CaseIterable, Sendable {
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

    public init(
        format: ExportFormat,
        dateRange: DateRange,
        startDate: Date,
        endDate: Date,
        includeTransactions: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true,
        includeSubscriptions: Bool = true,
        includeGoals: Bool = true
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
    }
}

// MARK: - Import Types

public enum ImportError: LocalizedError, Sendable {
    case fileAccessDenied
    case invalidFormat(String)
    case parsingError(String)
    case missingRequiredField(String)
    case emptyRequiredField(String)
    case emptyFile
    case invalidDateFormat(String)
    case invalidAmountFormat(String)
    case duplicateTransaction
    case invalidTransactionType(String)

    public var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            "The selected file could not be accessed."
        case .invalidFormat(let message):
            message
        case .parsingError(let message):
            message
        case .missingRequiredField(let field):
            "CSV is missing required field: \(field)."
        case .emptyRequiredField(let field):
            "Required field is empty: \(field)."
        case .emptyFile:
            "CSV file is empty."
        case .invalidDateFormat(let value):
            "Invalid date format: \(value)."
        case .invalidAmountFormat(let value):
            "Invalid amount format: \(value)."
        case .duplicateTransaction:
            "This transaction already exists."
        case .invalidTransactionType(let value):
            "Invalid transaction type: \(value)."

        }
    }
}

public struct ImportResult: Sendable {
    public let success: Bool
    public let itemsImported: Int
    public let errors: [String]
    public let warnings: [String]

    public init(success: Bool, itemsImported: Int, errors: [String] = [], warnings: [String] = []) {
        self.success = success
        self.itemsImported = itemsImported
        self.errors = errors
        self.warnings = warnings
    }
}
