import Foundation

/// Column index mapping for CSV imports.
struct CSVColumnMapping: Sendable {
    var dateIndex: Int?
    var titleIndex: Int?
    var amountIndex: Int?
    var typeIndex: Int?
    var notesIndex: Int?
    var accountIndex: Int?
    var categoryIndex: Int?
}
