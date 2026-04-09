// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation

#if canImport(os)
    import os

    /// Centralized logging system for MomentumFinance
    /// Provides structured logging across different categories and severity levels
    public enum Logger {
        public typealias LogCategoryHandle = OSLog

        private static let subsystem = Bundle.main.bundleIdentifier ?? "com.momentumfinance"

        private static let uiLogger = os.Logger(subsystem: subsystem, category: "UI")
        private static let dataLogger = os.Logger(subsystem: subsystem, category: "Data")
        private static let businessLogger = os.Logger(subsystem: subsystem, category: "Business")
        private static let networkLogger = os.Logger(subsystem: subsystem, category: "Network")
        private static let performanceLogger = os.Logger(
            subsystem: subsystem,
            category: "Performance"
        )
        private static let generalLogger = os.Logger(subsystem: subsystem, category: "General")

        static let ui = OSLog(subsystem: subsystem, category: "UI")
        static let data = OSLog(subsystem: subsystem, category: "Data")
        static let business = OSLog(subsystem: subsystem, category: "Business")
        static let network = OSLog(subsystem: subsystem, category: "Network")
        static let performance = OSLog(subsystem: subsystem, category: "Performance")
        public static let defaultLog = OSLog(subsystem: subsystem, category: "General")

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

        public static func logDebug(
            _ message: String,
            category: LogCategoryHandle = defaultLog,
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

        public static func logInfo(_ message: String, category: LogCategoryHandle = defaultLog) {
            let sanitized = sanitizeForLogging(message)
            getLogger(for: category).info("\(sanitized, privacy: .public)")
        }

        public static func logWarning(_ message: String, category: LogCategoryHandle = defaultLog) {
            let sanitized = sanitizeForLogging(message)
            getLogger(for: category).warning("\(sanitized, privacy: .public)")
        }

        public static func logBusiness(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            businessLogger.info(
                "[BUSINESS] \(message, privacy: .public) [\(source, privacy: .public)]"
            )
        }

        public static func logUI(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            uiLogger.info("[UI] \(message, privacy: .public) [\(source, privacy: .public)]")
        }

        public static func logData(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            dataLogger.info("[DATA] \(message, privacy: .public) [\(source, privacy: .public)]")
        }

        public static func logNetwork(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            networkLogger.info(
                "[NETWORK] \(message, privacy: .public) [\(source, privacy: .public)]"
            )
        }

        public static func measurePerformance<T>(_ operation: String, block: () throws -> T)
            rethrows -> T
        {
            let startTime = Date().timeIntervalSinceReferenceDate
            let result = try block()
            let timeElapsed = Date().timeIntervalSinceReferenceDate - startTime
            performanceLogger.info(
                "[PERFORMANCE] \(operation, privacy: .public) completed in \(timeElapsed, privacy: .public) seconds"
            )
            return result
        }

        public static func startPerformanceMeasurement(_ operation: String) -> PerformanceMeasurement {
            PerformanceMeasurement(
                operation: operation,
                startTime: Date().timeIntervalSinceReferenceDate
            )
        }

        private static func getLogger(for category: LogCategoryHandle) -> os.Logger {
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
#else
    /// Centralized logging system for MomentumFinance
    /// Linux fallback implementation without OSLog dependency.
    public enum Logger {
        public struct LogCategoryHandle: Equatable, Sendable {
            public let name: String
            public init(_ name: String) {
                self.name = name
            }
        }

        private static let subsystem = Bundle.main.bundleIdentifier ?? "com.momentumfinance"

        static let ui = LogCategoryHandle("UI")
        static let data = LogCategoryHandle("Data")
        static let business = LogCategoryHandle("Business")
        static let network = LogCategoryHandle("Network")
        static let performance = LogCategoryHandle("Performance")
        public static let defaultLog = LogCategoryHandle("General")

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
            print("[ERROR][\(subsystem)] \(message)")
        }

        public static func logDebug(
            _ message: String,
            category: LogCategoryHandle = defaultLog,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            #if DEBUG
                let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
                let sanitized = sanitizeForLogging(message)
                print("[DEBUG][\(category.name)] \(sanitized) [\(source)]")
            #endif
        }

        public static func logInfo(_ message: String, category: LogCategoryHandle = defaultLog) {
            let sanitized = sanitizeForLogging(message)
            print("[INFO][\(category.name)] \(sanitized)")
        }

        public static func logWarning(
            _ message: String,
            category: LogCategoryHandle = defaultLog
        ) {
            let sanitized = sanitizeForLogging(message)
            print("[WARN][\(category.name)] \(sanitized)")
        }

        public static func logBusiness(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            print("[BUSINESS] \(sanitizeForLogging(message)) [\(source)]")
        }

        public static func logUI(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            print("[UI] \(sanitizeForLogging(message)) [\(source)]")
        }

        public static func logData(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            print("[DATA] \(sanitizeForLogging(message)) [\(source)]")
        }

        public static func logNetwork(
            _ message: String,
            file: String = #file,
            function: String = #function,
            line: Int = #line
        ) {
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            print("[NETWORK] \(sanitizeForLogging(message)) [\(source)]")
        }

        public static func measurePerformance<T>(_ operation: String, block: () throws -> T)
            rethrows -> T
        {
            let start = Date().timeIntervalSinceReferenceDate
            let result = try block()
            let elapsed = Date().timeIntervalSinceReferenceDate - start
            print("[PERFORMANCE] \(operation) completed in \(elapsed) seconds")
            return result
        }

        public static func startPerformanceMeasurement(_ operation: String) -> PerformanceMeasurement {
            PerformanceMeasurement(
                operation: operation,
                startTime: Date().timeIntervalSinceReferenceDate
            )
        }

        fileprivate static func sanitizeForLogging(_ message: String) -> String {
            InputValidator.redactPII(message)
        }
    }
#endif

// MARK: - Performance Measurement Helper

public struct PerformanceMeasurement {
    let operation: String
    let startTime: TimeInterval

    func end() {
        let timeElapsed = Date().timeIntervalSinceReferenceDate - self.startTime
        Logger.logInfo(
            "[PERFORMANCE] \(self.operation) completed in \(String(format: "%.4f", timeElapsed)) seconds",
            category: Logger.performance
        )
    }
}
