// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import os

/// Centralized logging system for MomentumFinance
/// Provides structured logging across different categories and severity levels
public enum Logger {
    // MARK: - Core Logger Categories

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.momentumfinance"

    private static let uiLogger = os.Logger(subsystem: subsystem, category: "UI")
    private static let dataLogger = os.Logger(subsystem: subsystem, category: "Data")
    private static let businessLogger = os.Logger(subsystem: subsystem, category: "Business")
    private static let networkLogger = os.Logger(subsystem: subsystem, category: "Network")
    private static let performanceLogger = os.Logger(subsystem: subsystem, category: "Performance")
    private static let generalLogger = os.Logger(subsystem: subsystem, category: "General")

    // For compatibility with existing OSLog usages
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let data = OSLog(subsystem: subsystem, category: "Data")
    static let business = OSLog(subsystem: subsystem, category: "Business")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let performance = OSLog(subsystem: subsystem, category: "Performance")
    public static let defaultLog = OSLog(subsystem: subsystem, category: "General")

    // MARK: - Core Logging Methods

    /// Log error messages with context
    /// Automatically redacts PII before logging
    public static func logError(
        _ error: Error,
        context: String = "",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        let sanitizedContext = sanitizeForLogging(context)
        let sanitizedError = sanitizeForLogging(error.localizedDescription)
        let message =
            "\(sanitizedContext.isEmpty ? "" : "\(sanitizedContext) - ")\(sanitizedError) [\(source)]"
        generalLogger.error("\(message, privacy: .public)")
    }

    /// Log debug information
    /// PII redaction applied even in debug mode for security
    public static func logDebug(
        _ message: String,
        category: OSLog = defaultLog,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            let sanitized = sanitizeForLogging(message)
            let logger = getLogger(for: category)
            logger.debug("[DEBUG] \(sanitized, privacy: .public) [\(source, privacy: .public)]")
        #endif
    }

    /// Log informational messages
    /// Automatically sanitizes and redacts PII
    public static func logInfo(_ message: String, category: OSLog = defaultLog) {
        let sanitized = sanitizeForLogging(message)
        let logger = getLogger(for: category)
        logger.info("\(sanitized, privacy: .public)")
    }

    /// Log warning messages
    /// Automatically sanitizes and redacts PII
    public static func logWarning(_ message: String, category: OSLog = defaultLog) {
        let sanitized = sanitizeForLogging(message)
        let logger = getLogger(for: category)
        logger.warning("\(sanitized, privacy: .public)")
    }

    // MARK: - Business Logic Logging

    public static func logBusiness(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        businessLogger.info("[BUSINESS] \(message, privacy: .public) [\(source, privacy: .public)]")
    }

    public static func logUI(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        uiLogger.info("[UI] \(message, privacy: .public) [\(source, privacy: .public)]")
    }

    public static func logData(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        dataLogger.info("[DATA] \(message, privacy: .public) [\(source, privacy: .public)]")
    }

    public static func logNetwork(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        networkLogger.info("[NETWORK] \(message, privacy: .public) [\(source, privacy: .public)]")
    }

    // MARK: - Performance Measurement

    public static func measurePerformance<T>(_ operation: String, block: () throws -> T) rethrows
        -> T
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        performanceLogger.info(
            "[PERFORMANCE] \(operation, privacy: .public) completed in \(timeElapsed, privacy: .public) seconds"
        )
        return result
    }

    public static func startPerformanceMeasurement(_ operation: String) -> PerformanceMeasurement {
        PerformanceMeasurement(operation: operation, startTime: CFAbsoluteTimeGetCurrent())
    }

    // MARK: - Private Helpers

    private static func getLogger(for category: OSLog) -> os.Logger {
        switch category {
        case ui: uiLogger
        case data: dataLogger
        case business: businessLogger
        case network: networkLogger
        case performance: performanceLogger
        default: generalLogger
        }
    }

    fileprivate static func sanitizeForLogging(_ message: String) -> String {
        InputValidator.redactPII(message)
    }
}

// MARK: - Performance Measurement Helper

public struct PerformanceMeasurement {
    let operation: String
    let startTime: CFAbsoluteTime

    func end() {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - self.startTime
        Logger.logInfo(
            "[PERFORMANCE] \(self.operation) completed in \(String(format: "%.4f", timeElapsed)) seconds",
            category: Logger.performance
        )
    }
}
