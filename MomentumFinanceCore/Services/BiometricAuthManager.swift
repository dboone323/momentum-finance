//
// BiometricAuthManager.swift
// MomentumFinance
//
// Step 11: Biometric authentication for sensitive financial data.
//

import Foundation
import LocalAuthentication

/// Manager for biometric authentication (Face ID / Touch ID).
public final class BiometricAuthManager {
    public static let shared = BiometricAuthManager()

    private let context = LAContext()

    private init() {}

    // MARK: - Availability

    /// Checks if biometric authentication is available.
    public var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Type of biometric available (Face ID, Touch ID, or none).
    public var biometricType: BiometricType {
        guard isBiometricAvailable else { return .none }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }

    public enum BiometricType: String {
        case faceID = "Face ID"
        case touchID = "Touch ID"
        case opticID = "Optic ID"
        case none = "None"
    }

    // MARK: - Authentication

    /// Authenticates user with biometrics.
    /// - Parameters:
    ///   - reason: Reason displayed to user.
    ///   - completion: Callback with success status and optional error.
    public func authenticate(
        reason: String = "Authenticate to access your financial data",
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            completion(false, BiometricError.notAvailable)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("[BiometricAuth] Authentication successful")
                    completion(true, nil)
                } else if let error = error as? LAError {
                    print("[BiometricAuth] Authentication failed: \(error.localizedDescription)")
                    completion(false, self.mapError(error))
                } else {
                    completion(false, error)
                }
            }
        }
    }

    /// Async version of authenticate.
    @available(iOS 15.0, macOS 12.0, *)
    public func authenticate(reason: String = "Authenticate to access your financial data") async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            authenticate(reason: reason) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    // MARK: - Error Handling

    public enum BiometricError: LocalizedError {
        case notAvailable
        case notEnrolled
        case userCancel
        case lockout
        case failed

        public var errorDescription: String? {
            switch self {
            case .notAvailable:
                "Biometric authentication is not available on this device."
            case .notEnrolled:
                "No biometric data is enrolled. Please set up Face ID or Touch ID."
            case .userCancel:
                "Authentication was cancelled."
            case .lockout:
                "Biometric authentication is locked. Please use your passcode."
            case .failed:
                "Authentication failed. Please try again."
            }
        }
    }

    private func mapError(_ error: LAError) -> BiometricError {
        switch error.code {
        case .biometryNotAvailable:
            .notAvailable
        case .biometryNotEnrolled:
            .notEnrolled
        case .userCancel, .appCancel, .systemCancel:
            .userCancel
        case .biometryLockout:
            .lockout
        default:
            .failed
        }
    }
}
