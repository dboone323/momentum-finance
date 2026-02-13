import Foundation
import MomentumFinanceCore

enum CSVParser {
    static func parseCSVRow(_ row: String) -> [String] {
        guard !row.isEmpty else { return [""] }

        var fields: [String] = []
        var current = ""
        var insideQuotes = false

        for character in row {
            switch character {
            case "\"":
                insideQuotes.toggle()
                current.append(character)
            case "," where !insideQuotes:
                fields.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
            default:
                current.append(character)
            }
        }

        fields.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        return fields
    }

    static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()

        for (index, rawHeader) in headers.enumerated() {
            let header = rawHeader.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            switch header {
            case "date", "transaction date":
                mapping.dateIndex = index
            case "title", "description", "transaction", "name":
                mapping.titleIndex = index
            case "amount", "value":
                mapping.amountIndex = index
            case "type", "transaction type":
                mapping.typeIndex = index
            case "notes", "memo", "comments":
                mapping.notesIndex = index
            case "account", "account name":
                mapping.accountIndex = index
            case "category", "category name":
                mapping.categoryIndex = index
            default:
                continue
            }
        }

        return mapping
    }
}

enum DataParser {
    static func parseDate(_ string: String) throws -> Date {
        let formats = ["yyyy-MM-dd", "MM/dd/yyyy", "M/d/yyyy"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                return date
            }
        }

        throw ImportError.invalidDateFormat(string)
    }

    static func parseAmount(_ string: String) throws -> Double {
        let cleaned =
            string
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let value = Double(cleaned) else {
            throw ImportError.invalidAmountFormat(string)
        }

        return value
    }

    static func parseTransactionType(_ string: String, fallbackAmount amount: Double)
        -> TransactionType
    {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        switch normalized {
        case "income", "credit", "deposit":
            return .income
        case "expense", "debit", "withdrawal":
            return .expense
        case "transfer":
            return .transfer
        default:
            return amount >= 0 ? .income : .expense
        }
    }
}
