//
// SSLPinningManager.swift
// MomentumFinance
//
// Provides SSL/TLS certificate pinning for secure API communication.
// Critical for finance apps to prevent Man-in-the-Middle attacks.
//

import Foundation
import CryptoKit

/// Manager for SSL certificate pinning to prevent MitM attacks.
public final class SSLPinningManager: NSObject {
    
    public static let shared = SSLPinningManager()
    
    /// SHA256 hashes of pinned certificate public keys.
    /// These should be updated when rotating certificates.
    private var pinnedCertificateHashes: Set<String> = []
    
    /// Domains that require certificate pinning.
    private var pinnedDomains: Set<String> = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Configuration
    
    /// Configures the pinning manager with certificate hashes.
    /// - Parameters:
    ///   - hashes: SHA256 hashes of the public keys to pin.
    ///   - domains: Domains to enforce pinning for.
    public func configure(certificateHashes: [String], domains: [String]) {
        pinnedCertificateHashes = Set(certificateHashes)
        pinnedDomains = Set(domains.map { $0.lowercased() })
        print("[SSLPinning] Configured with \(hashes.count) certificates for \(domains.count) domains")
    }
    
    /// Adds a certificate hash to the pinned set.
    public func addPinnedCertificate(hash: String) {
        pinnedCertificateHashes.insert(hash)
    }
    
    /// Adds a domain to the pinned domains.
    public func addPinnedDomain(_ domain: String) {
        pinnedDomains.insert(domain.lowercased())
    }
    
    // MARK: - Validation
    
    /// Checks if a domain requires certificate pinning.
    public func requiresPinning(for domain: String) -> Bool {
        pinnedDomains.contains(domain.lowercased())
    }
    
    /// Validates a server trust against pinned certificates.
    /// - Parameter serverTrust: The server trust from the authentication challenge.
    /// - Returns: True if the certificate is valid and pinned.
    public func validate(serverTrust: SecTrust, for domain: String) -> Bool {
        guard requiresPinning(for: domain) else {
            // No pinning required for this domain
            return true
        }
        
        guard SecTrustGetCertificateCount(serverTrust) > 0 else {
            print("[SSLPinning] No certificates in server trust")
            return false
        }
        
        // Get the leaf certificate
        guard let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCertificate = certificate.first else {
            print("[SSLPinning] Could not extract leaf certificate")
            return false
        }
        
        // Extract public key and compute hash
        guard let publicKey = SecCertificateCopyKey(leafCertificate) else {
            print("[SSLPinning] Could not extract public key")
            return false
        }
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            print("[SSLPinning] Could not get public key data")
            return false
        }
        
        // Compute SHA256 hash of public key
        let hash = SHA256.hash(data: publicKeyData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        let isValid = pinnedCertificateHashes.contains(hashString)
        
        if !isValid {
            print("[SSLPinning] Certificate hash mismatch for \(domain)")
            print("[SSLPinning] Expected one of: \(pinnedCertificateHashes)")
            print("[SSLPinning] Got: \(hashString)")
        }
        
        return isValid
    }
    
    /// Creates a URLSession configuration with pinning.
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
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let domain = challenge.protectionSpace.host
        
        if validate(serverTrust: serverTrust, for: domain) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Certificate validation failed - reject connection
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
