//
// DataEncryptionService.swift
// MomentumFinance
//

import CryptoKit
import Foundation

@MainActor
public final class DataEncryptionService {
    // MARK: - Singleton

    public static let shared = DataEncryptionService()

    // MARK: - Configuration

    private let credentialManager = SecureCredentialManager.shared
    private let encryptionKeyIdentifier: SecureCredentialManager.CredentialKey = .encryptionKey

    private init() {}

    // MARK: - Encryption / Decryption

    public func encrypt(_ text: String) throws -> String {
        let data = text.data(using: .utf8)!
        let encryptedData = try encrypt(data)
        return encryptedData.base64EncodedString()
    }

    public func decrypt(_ base64Text: String) throws -> String {
        guard let data = Data(base64Encoded: base64Text) else {
            throw NSError(
                domain: "Encryption", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid base64"]
            )
        }
        let decryptedData = try decrypt(data)
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(
                domain: "Encryption", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid utf8"]
            )
        }
        return text
    }

    public func encrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    public func decrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Key Management

    private func getOrCreateKey() throws -> SymmetricKey {
        if let keyData = try credentialManager.retrieveData(encryptionKeyIdentifier) {
            return SymmetricKey(data: keyData)
        }

        // Create new key
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        try credentialManager.store(keyData, forKey: encryptionKeyIdentifier)
        return key
    }
}
