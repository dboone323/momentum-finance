import Foundation
import SwiftData

/// Detects recurring transactions and suggests subscriptions
public final class RecurringTransactionDetector {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Detect recurring patterns in transactions
    public func detectRecurringTransactions() async -> [RecurringPattern] {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())
            
            // Group by normalized title
            var titleGroups: [String: [FinancialTransaction]] = [:]
            for transaction in transactions {
                let normalized = normalizeTitle(transaction.title)
                titleGroups[normalized, default: []].append(transaction)
            }
            
            // Find patterns (3+ occurrences)
            var patterns: [RecurringPattern] = []
            for (title, group) in titleGroups where group.count >= 3 {
                let sortedDates = group.map { $0.date }.sorted()
                let intervals = calculateIntervals(sortedDates)
                
                if let frequency = detectFrequency(intervals) {
                    patterns.append(RecurringPattern(
                        title: title,
                        amount: group.map { $0.amount }.reduce(0, +) / Double(group.count),
                        frequency: frequency,
                        occurrences: group.count,
                        lastDate: sortedDates.last ?? Date(),
                        category: group.first?.category?.name
                    ))
                }
            }
            
            return patterns.sorted { $0.occurrences > $1.occurrences }
        } catch {
            print("Error detecting recurring transactions: \(error)")
            return []
        }
    }
    
    private func normalizeTitle(_ title: String) -> String {
        // Remove numbers, dates, transaction IDs
        var normalized = title.lowercased()
        normalized = normalized.replacingOccurrences(of: #"\d+"#, with: "", options: .regularExpression)
        normalized = normalized.replacingOccurrences(of: #"#\w+"#, with: "", options: .regularExpression)
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func calculateIntervals(_ dates: [Date]) -> [TimeInterval] {
        guard dates.count > 1 else { return [] }
        var intervals: [TimeInterval] = []
        for i in 1..<dates.count {
            intervals.append(dates[i].timeIntervalSince(dates[i-1]))
        }
        return intervals
    }
    
    private func detectFrequency(_ intervals: [TimeInterval]) -> RecurringFrequency? {
        guard !intervals.isEmpty else { return nil }
        
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let dayInterval = avgInterval / 86400 // Convert to days
        
        // Monthly (25-35 days)
        if dayInterval >= 25 && dayInterval <= 35 {
            return .monthly
        }
        // Weekly (5-9 days)
        else if dayInterval >= 5 && dayInterval <= 9 {
            return .weekly
        }
        // Bi-weekly (12-16 days)
        else if dayInterval >= 12 && dayInterval <= 16 {
            return .biweekly
        }
        // Quarterly (85-95 days)
        else if dayInterval >= 85 && dayInterval <= 95 {
            return .quarterly
        }
        // Yearly (350-380 days)
        else if dayInterval >= 350 && dayInterval <= 380 {
            return .yearly
        }
        
        return nil
    }
}

public struct RecurringPattern: Identifiable {
    public let id = UUID()
    public let title: String
    public let amount: Double
    public let frequency: RecurringFrequency
    public let occurrences: Int
    public let lastDate: Date
    public let category: String?
}

public enum RecurringFrequency: String, Codable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
}
