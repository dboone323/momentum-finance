//
//  ErrorHandler.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftUI

/// Centralized error handling for the Momentum Finance application
@MainActor
public final class ErrorHandler: ObservableObject {
    public static let shared = ErrorHandler()

    @Published public var currentError: AppError?
    @Published public var showErrorAlert = false

    private init() {}

    /// Handle an error by displaying it to the user
    /// - Parameter error: The error to handle
    public func handle(_ error: Error) {
        let appError = error as? AppError ?? .unknown(error)
        currentError = appError
        showErrorAlert = true

        // Log the error
        Logger.shared.log(error: appError)

        // In debug mode, also print to console
        #if DEBUG
        print("Error handled: \(appError.localizedDescription)")
        #endif
    }

    /// Handle an error with a custom message
    /// - Parameters:
    ///   - error: The error to handle
    ///   - message: Custom message to display
    public func handle(_ error: Error, message: String) {
        let appError = AppError.custom(message: message, underlying: error)
        currentError = appError
        showErrorAlert = true

        Logger.shared.log(error: appError)
    }

    /// Clear the current error
    public func clearError() {
        currentError = nil
        showErrorAlert = false
    }

    /// Handle async operations with error handling
    /// - Parameter operation: The async operation to perform
    /// - Returns: The result of the operation
    public func perform<T>(_ operation: () async throws -> T) async -> T? {
        do {
            return try await operation()
        } catch {
            handle(error)
            return nil
        }
    }
}

/// Application-specific error types
public enum AppError: LocalizedError, Identifiable {
    case network(NetworkError)
    case data(DataError)
    case validation(ValidationError)
    case authentication(AuthenticationError)
    case permission(PermissionError)
    case custom(message: String, underlying: Error?)
    case unknown(Error)

    public var id: String {
        switch self {
        case .network(let error): return "network_\(error.id)"
        case .data(let error): return "data_\(error.id)"
        case .validation(let error): return "validation_\(error.id)"
        case .authentication(let error): return "auth_\(error.id)"
        case .permission(let error): return "permission_\(error.id)"
        case .custom: return "custom_\(UUID().uuidString)"
        case .unknown: return "unknown_\(UUID().uuidString)"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .network(let error): return error.errorDescription
        case .data(let error): return error.errorDescription
        case .validation(let error): return error.errorDescription
        case .authentication(let error): return error.errorDescription
        case .permission(let error): return error.errorDescription
        case .custom(let message, _): return message
        case .unknown(let error): return error.localizedDescription
        }
    }

    public var failureReason: String? {
        switch self {
        case .network(let error): return error.failureReason
        case .data(let error): return error.failureReason
        case .validation(let error): return error.failureReason
        case .authentication(let error): return error.failureReason
        case .permission(let error): return error.failureReason
        case .custom(_, let underlying): return underlying?.localizedDescription
        case .unknown(let error): return error.localizedDescription
        }
    }
}

/// Network-related errors
public enum NetworkError: LocalizedError, Identifiable {
    case noInternet
    case timeout
    case serverError(code: Int)
    case invalidResponse
    case decodingFailed
    case encodingFailed

    public var id: String {
        switch self {
        case .noInternet: return "no_internet"
        case .timeout: return "timeout"
        case .serverError(let code): return "server_\(code)"
        case .invalidResponse: return "invalid_response"
        case .decodingFailed: return "decoding_failed"
        case .encodingFailed: return "encoding_failed"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .noInternet: return "No internet connection"
        case .timeout: return "Request timed out"
        case .serverError(let code): return "Server error (\(code))"
        case .invalidResponse: return "Invalid server response"
        case .decodingFailed: return "Failed to decode response"
        case .encodingFailed: return "Failed to encode request"
        }
    }
}

/// Data-related errors
public enum DataError: LocalizedError, Identifiable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case notFound
    case duplicate
    case invalidData

    public var id: String {
        switch self {
        case .saveFailed: return "save_failed"
        case .loadFailed: return "load_failed"
        case .deleteFailed: return "delete_failed"
        case .notFound: return "not_found"
        case .duplicate: return "duplicate"
        case .invalidData: return "invalid_data"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .saveFailed: return "Failed to save data"
        case .loadFailed: return "Failed to load data"
        case .deleteFailed: return "Failed to delete data"
        case .notFound: return "Data not found"
        case .duplicate: return "Duplicate data"
        case .invalidData: return "Invalid data"
        }
    }
}

/// Validation errors
public enum ValidationError: LocalizedError, Identifiable {
    case required(field: String)
    case invalidFormat(field: String)
    case tooShort(field: String, minLength: Int)
    case tooLong(field: String, maxLength: Int)
    case invalidValue(field: String)
    case outOfRange(field: String, min: Double, max: Double)

    public var id: String {
        switch self {
        case .required(let field): return "required_\(field)"
        case .invalidFormat(let field): return "format_\(field)"
        case .tooShort(let field, _): return "short_\(field)"
        case .tooLong(let field, _): return "long_\(field)"
        case .invalidValue(let field): return "value_\(field)"
        case .outOfRange(let field, _, _): return "range_\(field)"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .required(let field): return "\(field) is required"
        case .invalidFormat(let field): return "Invalid \(field) format"
        case .tooShort(let field, let min): return "\(field) must be at least \(min) characters"
        case .tooLong(let field, let max): return "\(field) must be no more than \(max) characters"
        case .invalidValue(let field): return "Invalid \(field) value"
        case .outOfRange(let field, let min, let max): return "\(field) must be between \(min) and \(max)"
        }
    }
}

/// Authentication errors
public enum AuthenticationError: LocalizedError, Identifiable {
    case invalidCredentials
    case sessionExpired
    case accountLocked
    case accountDisabled
    case biometricFailed

    public var id: String {
        switch self {
        case .invalidCredentials: return "invalid_credentials"
        case .sessionExpired: return "session_expired"
        case .accountLocked: return "account_locked"
        case .accountDisabled: return "account_disabled"
        case .biometricFailed: return "biometric_failed"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid username or password"
        case .sessionExpired: return "Your session has expired"
        case .accountLocked: return "Account is locked"
        case .accountDisabled: return "Account is disabled"
        case .biometricFailed: return "Biometric authentication failed"
        }
    }
}

/// Permission errors
public enum PermissionError: LocalizedError, Identifiable {
    case cameraDenied
    case photoLibraryDenied
    case locationDenied
    case notificationDenied
    case calendarDenied

    public var id: String {
        switch self {
        case .cameraDenied: return "camera_denied"
        case .photoLibraryDenied: return "photo_denied"
        case .locationDenied: return "location_denied"
        case .notificationDenied: return "notification_denied"
        case .calendarDenied: return "calendar_denied"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .cameraDenied: return "Camera access denied"
        case .photoLibraryDenied: return "Photo library access denied"
        case .locationDenied: return "Location access denied"
        case .notificationDenied: return "Notification access denied"
        case .calendarDenied: return "Calendar access denied"
        }
    }
}
