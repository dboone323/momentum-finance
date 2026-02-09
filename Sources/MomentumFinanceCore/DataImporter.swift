import Foundation

#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @MainActor
    public class DataImporter {
        private let modelContainer: ModelContainer
        public init(modelContainer: ModelContainer) { self.modelContainer = modelContainer }

        public func importFromCSV(_ content: String) async throws -> ImportResult {
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            guard !lines.isEmpty else {
                return ImportResult(
                    success: false, itemsImported: 0, errors: ["CSV file is empty"]
                )
            }
            let headers = CSVParser.parseCSVRow(lines[0])
            let mapping = CSVParser.mapColumns(headers: headers)

            var imported = 0
            var errors: [String] = []
            let warnings: [String] = []

            let context = ModelContext(modelContainer)

            for line in lines.dropFirst() {
                let fields = CSVParser.parseCSVRow(line)
                do {
                    guard let dateIndex = mapping.dateIndex, dateIndex < fields.count else {
                        throw ImportError.missingRequiredField("date")
                    }
                    let date = try DataParser.parseDate(fields[dateIndex])

                    guard let amountIndex = mapping.amountIndex, amountIndex < fields.count else {
                        throw ImportError.missingRequiredField("amount")
                    }
                    let amount = try DataParser.parseAmount(fields[amountIndex])

                    let typeString =
                        mapping.typeIndex.flatMap { $0 < fields.count ? fields[$0] : nil } ?? ""
                    let txType = DataParser.parseTransactionType(typeString, fallbackAmount: amount)

                    guard let titleIndex = mapping.titleIndex, titleIndex < fields.count else {
                        throw ImportError.missingRequiredField("title")
                    }
                    let title = fields[titleIndex]

                    let notes = mapping.notesIndex.flatMap { $0 < fields.count ? fields[$0] : nil }

                    // Use default entities or handle as needed
                    let account = FinancialAccount(
                        name: "Imported Account", balance: Decimal(0), iconName: "creditcard"
                    )
                    let category = ExpenseCategory(name: "Imported Category", iconName: "tag")

                    let transaction = FinancialTransaction(
                        title: title,
                        amount: amount < 0 ? -amount : amount,
                        date: date,
                        transactionType: txType,
                        notes: notes
                    )
                    transaction.account = account
                    transaction.category = category

                    context.insert(transaction)
                    imported += 1
                } catch {
                    errors.append("Error importing line: \(line) - \(error.localizedDescription)")
                }
            }

            try context.save()

            return ImportResult(
                success: errors.isEmpty, itemsImported: imported, errors: errors, warnings: warnings
            )
        }

        public func importFromEncryptedData(_ data: Data) async throws -> ImportResult {
            let decryptedData = try DataEncryptionService.shared.decrypt(data)
            guard let content = String(data: decryptedData, encoding: .utf8) else {
                throw ImportError.invalidFormat("Decrypted data is not valid UTF-8 text.")
            }
            return try await importFromCSV(content)
        }
    }
#endif
