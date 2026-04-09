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
        case let .network(error): "network_\(error.id)"
        case let .data(error): "data_\(error.id)"
        case let .validation(error): "validation_\(error.id)"
        case let .authentication(error): "auth_\(error.id)"
        case let .permission(error): "permission_\(error.id)"
        case .custom: "custom_\(UUID().uuidString)"
        case .unknown: "unknown_\(UUID().uuidString)"
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .network(error): error.errorDescription
        case let .data(error): error.errorDescription
        case let .validation(error): error.errorDescription
        case let .authentication(error): error.errorDescription
        case let .permission(error): error.errorDescription
        case let .custom(message, _): message
        case let .unknown(error): error.localizedDescription
        }
    }

    public var failureReason: String? {
        switch self {
        case let .network(error): error.failureReason
        case let .data(error): error.failureReason
        case let .validation(error): error.failureReason
        case let .authentication(error): error.failureReason
        case let .permission(error): error.failureReason
        case let .custom(_, underlying): underlying?.localizedDescription
        case let .unknown(error): error.localizedDescription
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
        case .noInternet: "no_internet"
        case .timeout: "timeout"
        case let .serverError(code): "server_\(code)"
        case .invalidResponse: "invalid_response"
        case .decodingFailed: "decoding_failed"
        case .encodingFailed: "encoding_failed"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .noInternet: "No internet connection"
        case .timeout: "Request timed out"
        case let .serverError(code): "Server error (\(code))"
        case .invalidResponse: "Invalid server response"
        case .decodingFailed: "Failed to decode response"
        case .encodingFailed: "Failed to encode request"
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
        case .saveFailed: "save_failed"
        case .loadFailed: "load_failed"
        case .deleteFailed: "delete_failed"
        case .notFound: "not_found"
        case .duplicate: "duplicate"
        case .invalidData: "invalid_data"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .saveFailed: "Failed to save data"
        case .loadFailed: "Failed to load data"
        case .deleteFailed: "Failed to delete data"
        case .notFound: "Data not found"
        case .duplicate: "Duplicate data"
        case .invalidData: "Invalid data"
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
        case let .required(field): "required_\(field)"
        case let .invalidFormat(field): "format_\(field)"
        case let .tooShort(field, _): "short_\(field)"
        case let .tooLong(field, _): "long_\(field)"
        case let .invalidValue(field): "value_\(field)"
        case let .outOfRange(field, _, _): "range_\(field)"
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .required(field): "\(field) is required"
        case let .invalidFormat(field): "Invalid \(field) format"
        case let .tooShort(field, min): "\(field) must be at least \(min) characters"
        case let .tooLong(field, max): "\(field) must be no more than \(max) characters"
        case let .invalidValue(field): "Invalid \(field) value"
        case let .outOfRange(field, min, max): "\(field) must be between \(min) and \(max)"
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
        case .invalidCredentials: "invalid_credentials"
        case .sessionExpired: "session_expired"
        case .accountLocked: "account_locked"
        case .accountDisabled: "account_disabled"
        case .biometricFailed: "biometric_failed"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Invalid username or password"
        case .sessionExpired: "Your session has expired"
        case .accountLocked: "Account is locked"
        case .accountDisabled: "Account is disabled"
        case .biometricFailed: "Biometric authentication failed"
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
        case .cameraDenied: "camera_denied"
        case .photoLibraryDenied: "photo_denied"
        case .locationDenied: "location_denied"
        case .notificationDenied: "notification_denied"
        case .calendarDenied: "calendar_denied"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .cameraDenied: "Camera access denied"
        case .photoLibraryDenied: "Photo library access denied"
        case .locationDenied: "Location access denied"
        case .notificationDenied: "Notification access denied"
        case .calendarDenied: "Calendar access denied"
        }
    }
}
