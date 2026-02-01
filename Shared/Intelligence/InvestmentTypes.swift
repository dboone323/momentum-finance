import Foundation

public enum RiskTolerance: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

public struct Investment: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let symbol: String
    public let value: Double

    public init(id: UUID = UUID(), name: String, symbol: String, value: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.value = value
    }
}
