import Foundation

enum ImportError: LocalizedError {
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

    var errorDescription: String? {
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
        }
    }
}
