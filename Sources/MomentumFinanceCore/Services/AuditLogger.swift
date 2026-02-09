//
// AuditLogger.swift
// MomentumFinance
//

import Foundation
import os

/// Audit event severity levels.
public enum AuditSeverity: String, Codable, Sendable {
    case info = "INFO"
    case warning = "WARNING"
    case critical = "CRITICAL"
}

/// Represents an auditable event.
public struct AuditEvent: Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let severity: AuditSeverity
    public let action: String
    public let details: String
    public let userId: String?
    public let ipAddress: String?
    public let deviceId: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        severity: AuditSeverity,
        action: String,
        details: String,
        userId: String? = nil,
        ipAddress: String? = nil,
        deviceId: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.action = action
        self.details = details
        self.userId = userId
        self.ipAddress = ipAddress
        self.deviceId = deviceId
    }
}

/// Manager for audit logging of sensitive operations.
@MainActor
public final class AuditLogger {
    public static let shared = AuditLogger()

    private let osLogger = os.Logger(subsystem: "com.momentumfinance", category: "Audit")
    private var auditLog: [AuditEvent] = []
    private let maxLogSize = 10000

    private init() {
        loadPersistedLog()
    }

    // MARK: - Logging

    /// Logs a sensitive operation.
    public func log(
        action: String,
        details: String,
        severity: AuditSeverity = .info,
        userId: String? = nil
    ) {
        let event = AuditEvent(
            severity: severity,
            action: action,
            details: details,
            userId: userId,
            deviceId: getDeviceId()
        )

        appendEvent(event)

        // Also log to system
        switch severity {
        case .info:
            osLogger.info("[\(action)] \(details)")
        case .warning:
            osLogger.warning("[\(action)] \(details)")
        case .critical:
            osLogger.critical("[\(action)] \(details)")
        }
    }

    /// Logs authentication attempts.
    public func logAuthentication(success: Bool, method: String, userId: String?) {
        log(
            action: success ? "AUTH_SUCCESS" : "AUTH_FAILURE",
            details: "Authentication via \(method)",
            severity: success ? .info : .warning,
            userId: userId
        )
    }

    /// Logs data access events.
    public func logDataAccess(dataType: String, operation: String, userId: String?) {
        log(
            action: "DATA_ACCESS",
            details: "\(operation) on \(dataType)",
            severity: .info,
            userId: userId
        )
    }

    /// Logs financial transactions.
    public func logTransaction(type: String, amount: Double, currency: String, userId: String?) {
        log(
            action: "TRANSACTION",
            details: "\(type): \(String(format: "%.2f", amount)) \(currency)",
            severity: .critical,
            userId: userId
        )
    }

    /// Logs security events.
    public func logSecurityEvent(event: String, details: String) {
        log(
            action: "SECURITY",
            details: "\(event): \(details)",
            severity: .critical
        )
    }

    // MARK: - Retrieval

    /// Gets recent audit events.
    public func getRecentEvents(count: Int = 100) -> [AuditEvent] {
        Array(auditLog.suffix(count))
    }

    /// Gets events by severity.
    public func getEvents(severity: AuditSeverity) -> [AuditEvent] {
        auditLog.filter { $0.severity == severity }
    }

    /// Exports audit log.
    public func exportLog() -> Data? {
        try? JSONEncoder().encode(auditLog)
    }

    // MARK: - Private

    private func appendEvent(_ event: AuditEvent) {
        auditLog.append(event)

        // Trim if too large
        if auditLog.count > maxLogSize {
            auditLog = Array(auditLog.suffix(maxLogSize / 2))
        }

        persistLog()
    }

    private func getDeviceId() -> String {
        "device-identifier"
    }

    private var logFileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("audit_log.json")
    }

    private func persistLog() {
        guard let data = try? JSONEncoder().encode(auditLog) else { return }
        try? data.write(to: logFileURL)
    }

    private func loadPersistedLog() {
        guard let data = try? Data(contentsOf: logFileURL),
            let log = try? JSONDecoder().decode([AuditEvent].self, from: data)
        else {
            return
        }
        auditLog = log
    }
}
