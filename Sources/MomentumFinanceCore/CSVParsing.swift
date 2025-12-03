import Foundation

// MARK: - CSV Column Mapping

public struct CSVColumnMapping: Sendable {
    public var dateIndex: Int?
    public var titleIndex: Int?
    public var amountIndex: Int?
    public var typeIndex: Int?
    public var notesIndex: Int?
    public var accountIndex: Int?
    public var categoryIndex: Int?

    public init(
        dateIndex: Int? = nil,
        titleIndex: Int? = nil,
        amountIndex: Int? = nil,
        typeIndex: Int? = nil,
        notesIndex: Int? = nil,
        accountIndex: Int? = nil,
        categoryIndex: Int? = nil
    ) {
        self.dateIndex = dateIndex
        self.titleIndex = titleIndex
        self.amountIndex = amountIndex
        self.typeIndex = typeIndex
        self.notesIndex = notesIndex
        self.accountIndex = accountIndex
        self.categoryIndex = categoryIndex
    }
}

// MARK: - CSV Parser

public enum CSVParser {
    public static func parseCSVRow(_ row: String) -> [String] {
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
                fields.append(current)
                current = ""
            default:
                current.append(character)
            }
        }

        fields.append(current)
        return fields
    }

    public static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()

        for (index, rawHeader) in headers.enumerated() {
            let header = rawHeader.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            switch header {
            case "date", "transaction date":
                mapping.dateIndex = index
            case "title", "description", "transaction", "name":
                mapping.titleIndex = index
            case "amount", "value", "balance":
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

// MARK: - Data Parsing Helpers

public enum DataParser {
    public static func parseDate(_ string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: string) else {
            throw ImportError.invalidDateFormat(string)
        }
        return date
    }

    public static func parseAmount(_ string: String) throws -> Double {
        let cleaned = string
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(cleaned) else {
            throw ImportError.invalidAmountFormat(string)
        }
        return value
    }

    public static func parseTransactionType(_ string: String, fallbackAmount amount: Double)
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
