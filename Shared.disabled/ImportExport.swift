//
//  ImportExport.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// Protocol for exportable data
public protocol Exportable {
    /// Convert to dictionary representation for export
    func toExportDictionary() -> [String: Any]

    /// Get export headers for CSV format
    static var exportHeaders: [String] { get }
}

/// Protocol for importable data
public protocol Importable {
    /// Initialize from import dictionary
    init?(fromImportDictionary: [String: Any])

    /// Validate import data
    static func validateImportData(_ data: [String: Any]) -> [ImportValidationError]
}

/// CSV export/import utilities
public enum CSVUtilities {
    /// Export data to CSV string
    public static func exportToCSV<T: Exportable>(_ items: [T]) -> String {
        var csvString = T.exportHeaders.joined(separator: ",") + "\n"

        for item in items {
            let values = T.exportHeaders.map { header in
                let value = item.toExportDictionary()[header] ?? ""
                return escapeCSVValue(String(describing: value))
            }
            csvString += values.joined(separator: ",") + "\n"
        }

        return csvString
    }

    /// Parse CSV string to array of dictionaries
    public static func parseCSV(_ csvString: String) -> [[String: String]] {
        let rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard let headerRow = rows.first else { return [] }

        let headers = parseCSVRow(headerRow)
        var result: [[String: String]] = []

        for row in rows.dropFirst() {
            let values = parseCSVRow(row)
            guard values.count == headers.count else { continue }

            var dict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                dict[header] = values[index]
            }
            result.append(dict)
        }

        return result
    }

    /// Parse a single CSV row handling quoted values
    private static func parseCSVRow(_ row: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false

        for char in row {
            switch char {
            case "\"":
                inQuotes.toggle()
            case ",":
                if inQuotes {
                    current.append(char)
                } else {
                    result.append(current)
                    current = ""
                }
            default:
                current.append(char)
            }
        }

        result.append(current)
        return result.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    /// Escape CSV value
    private static func escapeCSVValue(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
}

/// JSON export/import utilities
public enum JSONUtilities {
    /// Export data to JSON string
    public static func exportToJSON(_ items: [some Encodable]) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(items)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw ExportError.encodingFailed
        }

        return jsonString
    }

    /// Import data from JSON string
    public static func importFromJSON<T: Decodable>(_ jsonString: String) throws -> [T] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let data = jsonString.data(using: .utf8) else {
            throw ImportError.invalidData
        }

        return try decoder.decode([T].self, from: data)
    }
}

/// File system utilities for import/export
public enum FileUtilities {
    /// Write string to file
    public static func writeToFile(_ content: String, at url: URL) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Read string from file
    public static func readFromFile(at url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    /// Get documents directory URL
    public static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Generate export filename with timestamp
    public static func exportFilename(for format: ExportFormat, type: String) -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        return "\(type)_export_\(timestamp).\(format.fileExtension)"
    }
}

/// Date utilities for import/export
public enum DateUtilities {
    /// Format date for export
    public static func formatForExport(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }

    /// Parse date from import
    public static func parseFromImport(_ dateString: String) -> Date? {
        // Try ISO8601 first
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Try localized date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.date(from: dateString)
    }
}

/// Number utilities for import/export
public enum NumberUtilities {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    /// Format number for export
    public static func formatForExport(_ number: Double) -> String {
        decimalFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Parse number from import
    public static func parseFromImport(_ numberString: String) -> Double? {
        // Try decimal format first
        if let number = decimalFormatter.number(from: numberString)?.doubleValue {
            return number
        }

        // Try currency format
        if let number = currencyFormatter.number(from: numberString)?.doubleValue {
            return number
        }

        // Try direct conversion
        return Double(numberString)
    }
}
