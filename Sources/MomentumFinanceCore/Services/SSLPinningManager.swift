//
// SSLPinningManager.swift
// MomentumFinance
//

import CryptoKit
import Foundation

/// Manager for SSL certificate pinning to prevent MitM attacks.
/// This class is now thread-safe for use in URLSession delegates.
public final class SSLPinningManager: NSObject, @unchecked Sendable {
    @MainActor public static let shared = SSLPinningManager()

    private let lock = NSLock()
    /// SHA256 hashes of pinned certificate public keys.
    private var pinnedCertificateHashes: Set<String> = []
    /// Domains that require certificate pinning.
    private var pinnedDomains: Set<String> = []

    override private init() {
        super.init()
    }

    // MARK: - Configuration

    @MainActor
    public func configure(certificateHashes: [String], domains: [String]) {
        lock.lock()
        pinnedCertificateHashes = Set(certificateHashes)
        pinnedDomains = Set(domains.map { $0.lowercased() })
        lock.unlock()
        print(
            "[SSLPinning] Configured with \(certificateHashes.count) certificates for \(domains.count) domains"
        )
    }

    @MainActor
    public func addPinnedCertificate(hash: String) {
        lock.lock()
        pinnedCertificateHashes.insert(hash)
        lock.unlock()
    }

    @MainActor
    public func addPinnedDomain(_ domain: String) {
        lock.lock()
        pinnedDomains.insert(domain.lowercased())
        lock.unlock()
    }

    // MARK: - Validation

    public func requiresPinning(for domain: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return pinnedDomains.contains(domain.lowercased())
    }

    public func validate(serverTrust: SecTrust, for domain: String) -> Bool {
        guard requiresPinning(for: domain) else { return true }

        guard SecTrustGetCertificateCount(serverTrust) > 0 else {
            print("[SSLPinning] No certificates in server trust")
            return false
        }

        guard let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCertificate = certificate.first
        else {
            print("[SSLPinning] Could not extract leaf certificate")
            return false
        }

        guard let publicKey = SecCertificateCopyKey(leafCertificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
        else {
            print("[SSLPinning] Could not extract public key")
            return false
        }

        let hash = SHA256.hash(data: publicKeyData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()

        lock.lock()
        let isValid = pinnedCertificateHashes.contains(hashString)
        lock.unlock()

        if !isValid {
            print("[SSLPinning] Certificate hash mismatch for \(domain)")
        }

        return isValid
    }

    public func createPinnedSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        config.tlsMaximumSupportedProtocolVersion = .TLSv13
        return config
    }
}

// MARK: - URLSessionDelegate for Pinning

extension SSLPinningManager: URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let domain = challenge.protectionSpace.host

        // Perform validation synchronously on the delegate queue
        if self.validate(serverTrust: serverTrust, for: domain) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
