import Foundation
import MomentumFinanceCore
import SwiftData

/// Import/export service bound to the main actor to safely access ModelContext.
@MainActor
final class ImportExportService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CSV Import (Background)

    func importCSVAsync(from url: URL) async throws -> InternalImportResult {
        // Read file on background
        let csvContent = try await readFileAsync(url)

        // Parse on background
        let rows = await parseCSVAsync(csvContent)

        // Create entities on main actor
        let transactions = try await createTransactionsAsync(from: rows)

        return InternalImportResult(
            successCount: transactions.count,
            failureCount: 0,
            errors: []
        )
    }

    private func readFileAsync(_ url: URL) async throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    private func parseCSVAsync(_ content: String) async -> [[String]] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            guard !line.isEmpty else { return nil }
            return parseCSVLine(line)
        }
    }

    private func parseCSVLine(_ line: String) -> [String] {
        // Handle quoted fields with commas
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        fields.append(currentField.trimmingCharacters(in: .whitespaces))
        return fields
    }

    private func createTransactionsAsync(from rows: [[String]]) async throws
        -> [FinancialTransaction]
    {
        var transactions: [FinancialTransaction] = []

        // Skip header row
        for row in rows.dropFirst() {
            guard row.count >= 7 else { continue }

            // Parse fields
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            guard let date = dateFormatter.date(from: row[0]) else { continue }

            let title = row[1]
            guard let amount = Double(row[2]) else { continue }
            guard let type = TransactionType(rawValue: row[3]) else { continue }

            let transaction = FinancialTransaction(
                title: title,
                amount: amount,
                date: date,
                transactionType: type
            )

            transactions.append(transaction)
        }

        return transactions
    }

    // MARK: - CSV Export (Background)

    func exportCSVAsync(_ transactions: [FinancialTransaction]) async throws -> URL {
        // Generate CSV on background
        let csvContent = await generateCSVAsync(transactions)

        // Write to file on background
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(Date().timeIntervalSince1970).csv")

        try csvContent.write(to: url, atomically: true, encoding: .utf8)

        return url
    }

    private func generateCSVAsync(_ transactions: [FinancialTransaction]) async -> String {
        var lines = ["Date,Title,Amount,Type,Category,Account,Notes"]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.date)
            let title = escapeCSVField(transaction.title)
            let amount = String(format: "%.2f", transaction.amount)
            let type = transaction.transactionType.rawValue
            let category = escapeCSVField(transaction.category ?? "")
            let account = escapeCSVField(transaction.account?.name ?? "")
            let notes = escapeCSVField(transaction.notes ?? "")

            lines.append("\(date),\(title),\(amount),\(type),\(category),\(account),\(notes)")
        }

        return lines.joined(separator: "\n")
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    // MARK: - JSON Export (Background)

    func exportJSONAsync(_ transactions: [FinancialTransaction]) async throws -> URL {
        let isoFormatter = ISO8601DateFormatter()
        let payload = transactions.map { transaction in
            [
                "id": transaction.id.uuidString,
                "title": transaction.title,
                "amount": transaction.amount,
                "date": isoFormatter.string(from: transaction.date),
                "type": transaction.transactionType.rawValue,
                "category": transaction.category ?? "",
                "account": transaction.account?.name ?? "",
                "notes": transaction.notes ?? "",
            ] as [String: Any]
        }
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted])

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(Date().timeIntervalSince1970).json")

        try data.write(to: url)

        return url
    }

    // MARK: - Progress Reporting

    func importWithProgress(
        from url: URL,
        progressHandler: @escaping @Sendable (Double) -> Void
    ) async throws -> InternalImportResult {
        let content = try await readFileAsync(url)
        let rows = await parseCSVAsync(content)

        var successCount = 0
        var errors: [RowImportError] = []

        for (index, row) in rows.enumerated() {
            do {
                _ = try await createTransactionsAsync(from: [row])
                successCount += 1
            } catch {
                errors.append(RowImportError(row: index, error: error))
            }

            // Report progress
            let progress = Double(index + 1) / Double(rows.count)
            await MainActor.run {
                progressHandler(progress)
            }
        }

        return InternalImportResult(
            successCount: successCount,
            failureCount: errors.count,
            errors: errors
        )
    }
}

// MARK: - Supporting Types

struct InternalImportResult {
    let successCount: Int
    let failureCount: Int
    let errors: [RowImportError]
}

struct RowImportError {
    let row: Int
    let error: Error
}
