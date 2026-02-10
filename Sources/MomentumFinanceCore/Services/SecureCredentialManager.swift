// Momentum Finance - Secure Credential Manager
// Copyright © 2026 Momentum Finance. All rights reserved.

import CryptoKit
import Foundation
import Security

/// Secure credential storage and retrieval using iOS/macOS Keychain.
@MainActor
public final class SecureCredentialManager {
    // MARK: - Singleton

    /// Shared singleton instance
    public static let shared = SecureCredentialManager()

    // MARK: - Configuration

    /// Service identifier for Keychain (bundle identifier)
    private let serviceName: String

    /// Access group for Keychain sharing (optional)
    private let accessGroup: String?

    // MARK: - Credential Keys

    /// Predefined credential keys for type safety
    public enum CredentialKey: String {
        case apiKey = "api_key"
        case authToken = "auth_token"
        case refreshToken = "refresh_token"
        case encryptionKey = "encryption_key"
        case biometricEnabled = "biometric_enabled"
        case syncToken = "sync_token"

        var fullyQualifiedKey: String {
            "com.momentumfinance.credential.\(rawValue)"
        }
    }

    // MARK: - Errors

    public enum CredentialError: Error, LocalizedError {
        case itemNotFound
        case duplicateItem
        case invalidData
        case encodingFailed
        case decodingFailed
        case keychainError(OSStatus)
        case biometricNotAvailable
        case biometricAuthFailed

        public var errorDescription: String? {
            switch self {
            case .itemNotFound:
                "Credential not found in keychain"
            case .duplicateItem:
                "Credential already exists"
            case .invalidData:
                "Invalid credential data"
            case .encodingFailed:
                "Failed to encode credential"
            case .decodingFailed:
                "Failed to decode credential"
            case let .keychainError(status):
                "Keychain error: \(status)"
            case .biometricNotAvailable:
                "Biometric authentication not available"
            case .biometricAuthFailed:
                "Biometric authentication failed"
            }
        }
    }

    // MARK: - Initialization

    private init(serviceName: String? = nil, accessGroup: String? = nil) {
        self.serviceName = serviceName ?? Bundle.main.bundleIdentifier ?? "com.momentumfinance"
        self.accessGroup = accessGroup
    }

    // MARK: - Storage Operations

    public func store(
        _ value: String, forKey key: CredentialKey, requireBiometric: Bool = false,
        syncWithiCloud: Bool = false
    ) throws {
        guard let data = value.data(using: .utf8) else {
            throw CredentialError.encodingFailed
        }

        try store(
            data, forKey: key, requireBiometric: requireBiometric, syncWithiCloud: syncWithiCloud
        )
    }

    /// Store a boolean value in the Keychain
    public func store(
        _ value: Bool, forKey key: CredentialKey, requireBiometric: Bool = false,
        syncWithiCloud: Bool = false
    ) throws {
        let data = value ? Data([1]) : Data([0])
        try store(
            data, forKey: key, requireBiometric: requireBiometric, syncWithiCloud: syncWithiCloud
        )
    }

    public func store(
        _ data: Data, forKey key: CredentialKey, requireBiometric: Bool = false,
        syncWithiCloud: Bool = false
    ) throws {
        var query = baseQuery(forKey: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked

        // Add biometric protection if requested
        if requireBiometric {
            #if !targetEnvironment(simulator)
                let access = SecAccessControlCreateWithFlags(
                    nil,
                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                    .userPresence,
                    nil
                )
                query[kSecAttrAccessControl as String] = access
            #endif
        }

        if syncWithiCloud {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data,
            ]
            SecItemUpdate(
                baseQuery(forKey: key) as CFDictionary, attributesToUpdate as CFDictionary
            )
        } else if status != errSecSuccess {
            throw CredentialError.keychainError(status)
        }
    }

    public func retrieve(_ key: CredentialKey, requireBiometric: Bool = false) throws -> String? {
        guard let data = try retrieveData(key, requireBiometric: requireBiometric) else {
            return nil
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw CredentialError.decodingFailed
        }

        return string
    }

    /// Retrieve a boolean value from the Keychain
    public func retrieveBool(_ key: CredentialKey, requireBiometric: Bool = false) throws -> Bool? {
        guard let data = try retrieveData(key, requireBiometric: requireBiometric) else {
            return nil
        }

        return data.first == 1
    }

    public func retrieveData(_ key: CredentialKey, requireBiometric: Bool = false) throws -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        if requireBiometric {
            query[kSecUseOperationPrompt as String] = "Authenticate to access credential"
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            throw CredentialError.keychainError(status)
        }

        guard let data = result as? Data else {
            throw CredentialError.invalidData
        }

        return data
    }

    public func delete(_ key: CredentialKey) throws {
        let query = baseQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialError.keychainError(status)
        }
    }

    public func exists(_ key: CredentialKey) -> Bool {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanFalse
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Helper Methods

    private func baseQuery(forKey key: CredentialKey) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.fullyQualifiedKey,
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}
