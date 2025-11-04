import Foundation
import SwiftData

@MainActor
public final class DataExporter {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    public func exportData(settings: ExportSettings) async throws -> URL {
        guard settings.format == .csv else {
            throw ImportError.invalidFormat("Only CSV export is implemented for tests.")
        }

        let context = ModelContext(self.modelContainer)
        let descriptor = FetchDescriptor<FinancialTransaction>()

        let transactions = ((try? context.fetch(descriptor)) ?? [])
            .filter { transaction in
                transaction.date >= settings.startDate && transaction.date <= settings.endDate
            }
        var rows = ["date,title,amount,type,notes,category,account"]

        if transactions.isEmpty {
            let placeholder = ISO8601DateFormatter().string(from: Date())
            rows.append("\(placeholder),No Data,0.0,info,,,")
        } else {
            let isoFormatter = ISO8601DateFormatter()
            for transaction in transactions {
                let dateString = isoFormatter.string(from: transaction.date)
                let sanitizedTitle = Self.sanitizedField(transaction.title)
                let amountString = String(format: "%.2f", transaction.amount)
                let type = transaction.transactionType.rawValue
                let notes = Self.sanitizedField(transaction.notes ?? "")
                let category = Self.sanitizedField(transaction.category?.name ?? "")
                let account = Self.sanitizedField(transaction.account?.name ?? "")

                rows.append(
                    "\(dateString),\(sanitizedTitle),\(amountString),\(type),\(notes),\(category),\(account)"
                )
            }
        }

        let csvContent = rows.joined(separator: "\n")
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("momentum-finance-export")
            .appendingPathExtension(settings.format.fileExtension)

        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    private static func sanitizedField(_ value: String) -> String {
        value.replacingOccurrences(of: ",", with: " ")
    }
}