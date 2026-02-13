import EnterpriseScalingFramework
import Foundation
import SharedKit

@available(iOS 17.0, macOS 14.0, *)
public struct RuntimeHealthSnapshot: Sendable {
    public let serviceStatuses: [String: String]
    public let enterpriseSummary: EnterpriseSummary
    public let generatedAt: Date

    public init(
        serviceStatuses: [String: String],
        enterpriseSummary: EnterpriseSummary,
        generatedAt: Date = Date()
    ) {
        self.serviceStatuses = serviceStatuses
        self.enterpriseSummary = enterpriseSummary
        self.generatedAt = generatedAt
    }
}

@available(iOS 17.0, macOS 14.0, *)
public struct EnterpriseSummary: Sendable {
    public let totalTenants: Int
    public let activeTenants: Int
    public let averageLoad: Double
    public let scalingEvents: Int

    public init(
        totalTenants: Int,
        activeTenants: Int,
        averageLoad: Double,
        scalingEvents: Int
    ) {
        self.totalTenants = totalTenants
        self.activeTenants = activeTenants
        self.averageLoad = averageLoad
        self.scalingEvents = scalingEvents
    }
}

@available(iOS 17.0, macOS 14.0, *)
public actor SharedKitEnterpriseBridge {
    public static let shared = SharedKitEnterpriseBridge()

    public init() {}

    public func createRuntimeSnapshot() async throws -> RuntimeHealthSnapshot {
        try await ServiceManager.shared.initializeServices()
        let statuses = await ServiceManager.shared.getServicesHealthStatus()
        let normalizedStatuses = Dictionary(
            uniqueKeysWithValues: statuses.map { key, status in
                (key, mapServiceStatus(status))
            }
        )

        let metrics = await EnterpriseEngine.shared.getEnterpriseMetrics()
        let summary = EnterpriseSummary(
            totalTenants: metrics.totalTenants,
            activeTenants: metrics.activeTenants,
            averageLoad: metrics.averageLoad,
            scalingEvents: metrics.scalingEvents
        )

        return RuntimeHealthSnapshot(
            serviceStatuses: normalizedStatuses,
            enterpriseSummary: summary
        )
    }

    private func mapServiceStatus(_ status: ServiceHealthStatus) -> String {
        switch status {
        case .healthy:
            return "healthy"
        case .degraded(let reason):
            return "degraded: \(reason)"
        case .unhealthy(let error):
            return "unhealthy: \(error.localizedDescription)"
        }
    }
}
