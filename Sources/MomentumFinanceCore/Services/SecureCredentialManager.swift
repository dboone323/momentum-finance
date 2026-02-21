// Momentum Finance - Secure Credential Manager
// Copyright © 2026 Momentum Finance. All rights reserved.

import Foundation
#if canImport(CryptoKit)
    import CryptoKit
#elseif canImport(Crypto)
    import Crypto
#endif
#if canImport(Security)
    import Security
#endif

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

    #if !canImport(Security)
        /// File-backed storage root for non-Apple platforms.
        private let storageRootURL: URL
        private let fileManager = FileManager.default
    #endif

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
        #if canImport(Security)
            case keychainError(OSStatus)
        #else
            case storageError(String)
        #endif
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
            #if canImport(Security)
                case let .keychainError(status):
                    "Keychain error: \(status)"
            #else
                case let .storageError(message):
                    "Credential storage error: \(message)"
            #endif
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
        #if !canImport(Security)
            self.storageRootURL = Self.defaultStorageRootURL()
        #endif
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
        #if canImport(Security)
            var query = baseQuery(forKey: key)
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked

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
                let updateStatus = SecItemUpdate(
                    baseQuery(forKey: key) as CFDictionary, attributesToUpdate as CFDictionary
                )
                guard updateStatus == errSecSuccess else {
                    throw CredentialError.keychainError(updateStatus)
                }
            } else if status != errSecSuccess {
                throw CredentialError.keychainError(status)
            }
        #else
            if requireBiometric || syncWithiCloud {
                throw CredentialError.biometricNotAvailable
            }
            try ensureStorageDirectoryExists()
            let encryptedData = try encryptForFileStore(data)
            let fileURL = credentialFileURL(for: key)
            do {
                try encryptedData.write(to: fileURL, options: [.atomic])
                try secureFilePermissions(at: fileURL)
            } catch {
                throw CredentialError.storageError(error.localizedDescription)
            }
        #endif
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
        #if canImport(Security)
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
        #else
            if requireBiometric {
                throw CredentialError.biometricNotAvailable
            }
            let fileURL = credentialFileURL(for: key)
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return nil
            }
            do {
                let encryptedData = try Data(contentsOf: fileURL)
                return try decryptFromFileStore(encryptedData)
            } catch {
                throw CredentialError.storageError(error.localizedDescription)
            }
        #endif
    }

    public func delete(_ key: CredentialKey) throws {
        #if canImport(Security)
            let query = baseQuery(forKey: key)
            let status = SecItemDelete(query as CFDictionary)

            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw CredentialError.keychainError(status)
            }
        #else
            let fileURL = credentialFileURL(for: key)
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return
            }
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                throw CredentialError.storageError(error.localizedDescription)
            }
        #endif
    }

    public func exists(_ key: CredentialKey) -> Bool {
        #if canImport(Security)
            var query = baseQuery(forKey: key)
            query[kSecReturnData as String] = kCFBooleanFalse
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            return status == errSecSuccess
        #else
            fileManager.fileExists(atPath: credentialFileURL(for: key).path)
        #endif
    }

    // MARK: - Helper Methods

    #if canImport(Security)
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
    #else
        private static func defaultStorageRootURL() -> URL {
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".momentumfinance", isDirectory: true)
                .appendingPathComponent("credentials", isDirectory: true)
        }

        private func ensureStorageDirectoryExists() throws {
            if !fileManager.fileExists(atPath: storageRootURL.path) {
                try fileManager.createDirectory(
                    at: storageRootURL,
                    withIntermediateDirectories: true
                )
            }
            try secureFilePermissions(at: storageRootURL, permissions: 0o700)
        }

        private func credentialFileURL(for key: CredentialKey) -> URL {
            storageRootURL.appendingPathComponent("\(key.fullyQualifiedKey).bin")
        }

        private func primaryKeyFileURL() -> URL {
            storageRootURL.appendingPathComponent("master.key")
        }

        private func loadOrCreatePrimaryKey() throws -> SymmetricKey {
            let keyURL = primaryKeyFileURL()
            if fileManager.fileExists(atPath: keyURL.path) {
                let existing = try Data(contentsOf: keyURL)
                guard existing.count == 32 else {
                    throw CredentialError.storageError("Invalid stored master key length")
                }
                return SymmetricKey(data: existing)
            }

            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data($0) }
            try keyData.write(to: keyURL, options: [.atomic])
            try secureFilePermissions(at: keyURL)
            return key
        }

        private func encryptForFileStore(_ plaintext: Data) throws -> Data {
            let key = try loadOrCreatePrimaryKey()
            let sealed = try AES.GCM.seal(plaintext, using: key)
            guard let combined = sealed.combined else {
                throw CredentialError.storageError("Failed to produce encrypted payload")
            }
            return combined
        }

        private func decryptFromFileStore(_ ciphertext: Data) throws -> Data {
            let key = try loadOrCreatePrimaryKey()
            let sealed = try AES.GCM.SealedBox(combined: ciphertext)
            return try AES.GCM.open(sealed, using: key)
        }

        private func secureFilePermissions(at url: URL, permissions: UInt16 = 0o600) throws {
            try fileManager.setAttributes(
                [.posixPermissions: NSNumber(value: permissions)],
                ofItemAtPath: url.path
            )
        }
    #endif
}
