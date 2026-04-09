//
//  Logger.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import OSLog

/// Centralized logging system for the Momentum Finance application
@MainActor
public final class Logger {
    public static let shared = Logger()

    private let logger: os.Logger
    private let queue = DispatchQueue(label: "com.momentumfinance.logger", qos: .utility)

    private init() {
        self.logger = os.Logger(subsystem: "com.momentumfinance", category: "app")
    }

    /// Log an informational message
    /// - Parameter message: The message to log
    public func info(_ message: String) {
        queue.async {
            self.logger.info("\(message)")
        }
    }

    /// Log a debug message
    /// - Parameter message: The message to log
    public func debug(_ message: String) {
        queue.async {
            self.logger.debug("\(message)")
        }
    }

    /// Log a warning message
    /// - Parameter message: The message to log
    public func warning(_ message: String) {
        queue.async {
            self.logger.warning("\(message)")
        }
    }

    /// Log an error
    /// - Parameter error: The error to log
    public func log(error: Error) {
        queue.async {
            self.logger.error("\(error.localizedDescription)")
        }
    }

    /// Log an error with additional context
    /// - Parameters:
    ///   - error: The error to log
    ///   - context: Additional context information
    public func log(error: Error, context: String) {
        queue.async {
            self.logger.error("\(context): \(error.localizedDescription)")
        }
    }

    /// Log a custom message with specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    public func log(_ message: String, level: LogLevel) {
        queue.async {
            switch level {
            case .info:
                self.logger.info("\(message)")
            case .debug:
                self.logger.debug("\(message)")
            case .warning:
                self.logger.warning("\(message)")
            case .error:
                self.logger.error("\(message)")
            case .critical:
                self.logger.critical("\(message)")
            }
        }
    }

    /// Log performance metrics
    /// - Parameters:
    ///   - operation: The operation name
    ///   - duration: The duration in seconds
    public func logPerformance(operation: String, duration: TimeInterval) {
        queue.async {
            self.logger.info("Performance: \(operation) took \(String(format: "%.3f", duration))s")
        }
    }

    /// Log user action
    /// - Parameter action: The user action description
    public func logUserAction(_ action: String) {
        queue.async {
            self.logger.info("User Action: \(action)")
        }
    }

    /// Log network request
    /// - Parameters:
    ///   - url: The request URL
    ///   - method: The HTTP method
    ///   - statusCode: The response status code
    ///   - duration: The request duration
    public func logNetworkRequest(url: String, method: String, statusCode: Int?, duration: TimeInterval) {
        queue.async {
            let status = statusCode.map { " (\($0))" } ?? ""
            self.logger.info("Network: \(method) \(url)\(status) - \(String(format: "%.3f", duration))s")
        }
    }
}

/// Log levels for different types of messages
public enum LogLevel {
    case info
    case debug
    case warning
    case error
    case critical
}

/// Convenience functions for logging
public extension Logger {
    static func info(_ message: String) {
        shared.info(message)
    }

    static func debug(_ message: String) {
        shared.debug(message)
    }

    static func warning(_ message: String) {
        shared.warning(message)
    }

    static func error(_ error: Error) {
        shared.log(error: error)
    }

    static func error(_ error: Error, context: String) {
        shared.log(error: error, context: context)
    }

    static func logError(_ error: Error, context: String) {
        shared.log(error: error, context: context)
    }

    static func performance(operation: String, duration: TimeInterval) {
        shared.logPerformance(operation: operation, duration: duration)
    }

    static func userAction(_ action: String) {
        shared.logUserAction(action)
    }

    static func networkRequest(url: String, method: String, statusCode: Int?, duration: TimeInterval) {
        shared.logNetworkRequest(url: url, method: method, statusCode: statusCode, duration: duration)
    }
}
