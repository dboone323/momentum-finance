import Foundation

#if canImport(SwiftData)
    import SwiftData
#endif

#if canImport(SwiftData)
    @MainActor
    public final class DataExporter {
        private let modelContainer: ModelContainer

        public init(modelContainer: ModelContainer) {
            self.modelContainer = modelContainer
        }

        public func exportData(settings: ExportSettings) async throws -> URL {
            guard settings.format == .csv else {
                throw ImportError.invalidFormat("Only CSV export is implemented in this engine.")
            }

            let context = ModelContext(self.modelContainer)
            var csvSections: [String] = []
            let isoFormatter = ISO8601DateFormatter()

            if settings.includeTransactions {
                let descriptor = FetchDescriptor<FinancialTransaction>()
                let transactions = ((try? context.fetch(descriptor)) ?? [])
                    .filter { $0.date >= settings.startDate && $0.date <= settings.endDate }

                var rows = ["TRANSACTIONS", "date,title,amount,type,notes,category,account"]
                for transaction in transactions {
                    rows.append(
                        "\(isoFormatter.string(from: transaction.date)),\(Self.sanitizedField(transaction.title)),\(transaction.amount.description),\(transaction.transactionType.rawValue),\(Self.sanitizedField(transaction.notes ?? "")),\(Self.sanitizedField(transaction.category?.name ?? "")),\(Self.sanitizedField(transaction.account?.name ?? ""))"
                    )
                }
                csvSections.append(rows.joined(separator: "\n"))
            }

            if settings.includeAccounts {
                let descriptor = FetchDescriptor<FinancialAccount>()
                let accounts = (try? context.fetch(descriptor)) ?? []

                var rows = ["ACCOUNTS", "name,balance,type,currency,createdDate"]
                for account in accounts {
                    rows.append(
                        "\(Self.sanitizedField(account.name)),\(account.balance.description),\(account.accountType.rawValue),\(account.currencyCode),\(isoFormatter.string(from: account.createdDate))"
                    )
                }
                csvSections.append(rows.joined(separator: "\n"))
            }

            if csvSections.isEmpty {
                csvSections.append("No data selected for export.")
            }

            let csvContent = csvSections.joined(separator: "\n\n")
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("momentum-finance-export")
                .appendingPathExtension(settings.format.fileExtension)

            if settings.isEncrypted {
                let data = csvContent.data(using: .utf8) ?? Data()
                let encryptedData = try DataEncryptionService.shared.encrypt(data)
                try encryptedData.write(to: fileURL, options: .atomic)
                Logger.logInfo("Data exported and encrypted successfully")
            } else {
                try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
                Logger.logInfo("Data exported successfully")
            }

            return fileURL
        }

        private static func sanitizedField(_ value: String) -> String {
            value.replacingOccurrences(of: ",", with: " ")
        }
    }

#endif
