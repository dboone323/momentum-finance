//
//  ImportExport.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-01-27.
//  Copyright © 2025 Momentum Finance. All rights reserved.
//

import Foundation
import SwiftData

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
        case .goal:
            "Goal"
        }
    }
}

// MARK: - Validation Error

/// Represents a data validation error during import
public struct ValidationError: Identifiable, Codable, Sendable {
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

// MARK: - Export/Import Types

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
        dateRange: DateRange = .allTime,
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

/// Minimal CSV importer used by tests and settings UI.
public final class DataImporter {
    private let modelContainer: ModelContainer?

    public init(modelContainer: ModelContainer?) {
        self.modelContainer = modelContainer
    }

    public func importFromCSV(_ content: String) async throws -> ImportResult {
        var errors: [String] = []
        var imported = 0

        let lines = content.split(whereSeparator: { $0.isNewline })
        guard !lines.isEmpty else {
            return ImportResult(success: false, itemsImported: 0, errors: ["CSV file is empty."])
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for (index, line) in lines.enumerated() {
            // Skip header if present
            if index == 0 && line.lowercased().contains("date") { continue }
            let columns = line.split(separator: ",")
            guard columns.count >= 3 else {
                errors.append("Error importing line \(index + 1): Missing fields")
                continue
            }

            let dateString = String(columns[0])
            let title = String(columns[1])
            let amountString = String(columns[2])

            guard let amount = Double(amountString) else {
                errors.append("Error importing line \(index + 1): Invalid amount")
                continue
            }

            guard let date = dateFormatter.date(from: dateString) else {
                errors.append("Error importing line \(index + 1): Invalid date")
                continue
            }

            let transaction = FinancialTransaction(
                title: title,
                amount: amount,
                date: date,
                transactionType: amount >= 0 ? .income : .expense
            )

            if let container = modelContainer {
                let context = ModelContext(container)
                context.insert(transaction)
                try? context.save()
            }

            imported += 1
        }

        return ImportResult(success: errors.isEmpty, itemsImported: imported, errors: errors)
    }
}

/// Minimal exporter that writes CSV rows for transactions within a date range.
public final class DataExporter {
    private let modelContainer: ModelContainer?

    public init(modelContainer: ModelContainer?) {
        self.modelContainer = modelContainer
    }

    public func exportData(settings: ExportSettings) async throws -> URL {
        let header = "date,title,amount,type,notes,category,account"
        var rows: [String] = [header]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let container = modelContainer {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<FinancialTransaction>()
            let transactions = (try? context.fetch(descriptor)) ?? []
            let filtered = transactions.filter { tx in
                tx.date >= settings.startDate && tx.date <= settings.endDate
            }

            if filtered.isEmpty {
                rows.append("No Data")
            } else {
                for tx in filtered.sorted(by: { $0.date < $1.date }) {
                    let dateString = formatter.string(from: tx.date)
                    let title = tx.title.replacingOccurrences(of: ",", with: ";")
                    let amount = tx.amount
                    let type = tx.transactionType.rawValue
                    let notes = (tx.notes ?? "").replacingOccurrences(of: ",", with: ";")
                    let category = tx.category?.name.replacingOccurrences(of: ",", with: ";") ?? ""
                    let account = tx.account?.name.replacingOccurrences(of: ",", with: ";") ?? ""
                    rows.append("\(dateString),\(title),\(amount),\(type),\(notes),\(category),\(account)")
                }
            }
        } else {
            rows.append("No Data")
        }

        let output = rows.joined(separator: "\n")
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("MomentumFinance_Export")
            .appendingPathExtension(settings.format.fileExtension)
        try output.data(using: .utf8)?.write(to: fileURL)
        return fileURL
    }
}


