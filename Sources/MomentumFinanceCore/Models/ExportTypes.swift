import Foundation

// MARK: - Export Types

public enum ExportFormat: String, CaseIterable, Sendable, Codable {
    case csv
    case pdf
    case json
    case excel

    public var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .pdf: "pdf"
        case .json: "json"
        case .excel: "xlsx"
        }
    }

    public var displayName: String {
        switch self {
        case .csv: "CSV"
        case .pdf: "PDF Report"
        case .json: "JSON Data"
        case .excel: "Excel Spreadsheet"
        }
    }

    public var icon: String {
        switch self {
        case .csv: "tablecells"
        case .pdf: "doc.text"
        case .json: "curlybraces"
        case .excel: "tablecells.fill"
        }
    }
}

public enum ExportError: LocalizedError, Sendable {
    case invalidSettings
    case fileAccessFailure
    case pdfGenerationFailed
    case encodingFailed
    case fileWriteFailed
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .invalidSettings: "Invalid export settings."
        case .fileAccessFailure: "Failed to access file location."
        case .pdfGenerationFailed: "Failed to generate PDF document."
        case .encodingFailed: "Failed to encode data."
        case .fileWriteFailed: "Failed to write data to file."
        case .invalidData: "Invalid data for export."
        }
    }
}

public struct ExportConstants: Sendable {
    public static let csvFilename = "MomentumFinance_Export.csv"
    public static let pdfFilename = "MomentumFinance_Report.pdf"
    public static let jsonFilename = "MomentumFinance_Backup.json"
}

public enum DateRange: String, CaseIterable, Sendable, Codable {
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

/// Detailed validation error for import process
public struct ImportValidationError: Identifiable, Sendable, Codable {
    public let id: UUID
    public let field: String?
    public let message: String
    public let row: Int?

    public init(id: UUID = UUID(), field: String? = nil, message: String, row: Int? = nil) {
        self.id = id
        self.field = field
        self.message = message
        self.row = row
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
    case invalidData
    case decodingFailed
    case validationFailed([ImportValidationError])

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
        case .invalidData:
            "The import data is invalid or missing."
        case .decodingFailed:
            "Failed to decode import data."
        case .validationFailed(let errors):
            "Validation failed with \(errors.count) errors."
        }
    }
}

public struct ImportResult: Sendable {
    public let success: Bool
    public let itemsImported: Int
    public let itemsFailed: Int
    public let errors: [String]
    public let validationErrors: [ImportValidationError]
    public let warnings: [String]

    public init(
        success: Bool,
        itemsImported: Int,
        itemsFailed: Int = 0,
        errors: [String] = [],
        validationErrors: [ImportValidationError] = [],
        warnings: [String] = []
    ) {
        self.success = success
        self.itemsImported = itemsImported
        self.itemsFailed = itemsFailed
        self.errors = errors
        self.validationErrors = validationErrors
        self.warnings = warnings
    }
}

// MARK: - Column Mapping

/// Represents mapping between CSV columns and data model properties
public struct ColumnMapping: Codable, Sendable {
    public let csvColumn: String
    public let modelProperty: String
    public let dataType: DataType
    public let isRequired: Bool
    public let defaultValue: String?

    public init(
        csvColumn: String,
        modelProperty: String,
        dataType: DataType,
        isRequired: Bool = false,
        defaultValue: String? = nil
    ) {
        self.csvColumn = csvColumn
        self.modelProperty = modelProperty
        self.dataType = dataType
        self.isRequired = isRequired
        self.defaultValue = defaultValue
    }
}

// MARK: - Data Type

/// Supported data types for import mapping
public enum DataType: String, CaseIterable, Codable, Sendable {
    case string
    case integer
    case decimal
    case date
    case boolean

    public var displayName: String {
        switch self {
        case .string:
            "Text"
        case .integer:
            "Whole Number"
        case .decimal:
            "Decimal Number"
        case .date:
            "Date"
        case .boolean:
            "Yes/No"
        }
    }
}

// MARK: - Entity Type

/// Types of entities that can be imported
public enum EntityType: String, CaseIterable, Codable, Sendable {
    case transaction
    case account
    case category
    case budget
    case goal

    public var displayName: String {
        switch self {
        case .transaction:
            "Transaction"
        case .account:
            "Account"
        case .category:
            "Category"
        case .budget:
            "Budget"
        case .goal: "Goal"
        }
    }
}

// MARK: - Validation Error

/// Represents a data validation error during import
public struct DataValidationError: Identifiable, Codable, Sendable {
    public let id: UUID
    public let field: String
    public let message: String
    public let severity: Severity

    public init(
        id: UUID = UUID(),
        field: String,
        message: String,
        severity: Severity = .error
    ) {
        self.id = id
        self.field = field
        self.message = message
        self.severity = severity
    }

    public enum Severity: String, Codable, Sendable {
        case warning
        case error

        public var displayName: String {
            switch self {
            case .warning:
                "Warning"
            case .error:
                "Error"
            }
        }
    }
}
