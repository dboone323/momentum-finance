// Momentum Finance - Network Security Manager
// Copyright © 2026 Momentum Finance. All rights reserved.

import Foundation
import os

/// Centralized manager for network security policies including SSL pinning and TLS enforcement.
@MainActor
public final class NetworkSecurityManager {
    // MARK: - Singleton

    /// Shared singleton instance
    public static let shared = NetworkSecurityManager()

    // MARK: - Properties

    private let pinningManager = SSLPinningManager.shared
    private let logger = Logger.self

    // MARK: - Configuration Constants

    /// Domains that require SSL pinning
    private let securedDomains = [
        "api.momentumfinance.io",
        "sync.momentumfinance.io",
        "auth.momentumfinance.io",
    ]

    /// SHA256 hashes of pinned public keys
    /// These should be replaced with actual production hashes
    private let pinnedHashes = [
        "h6Svlptv/6NoEVXEHh5L6X9Lno7j26/q0Y6uT8S6wYc=", // api.momentumfinance.io
        "d6Svlptv/6NoEVXEHh5L6X9Lno7j26/q0Y6uT8S6wYc=", // sync.momentumfinance.io
        "a6Svlptv/6NoEVXEHh5L6X9Lno7j26/q0Y6uT8S6wYc=", // auth.momentumfinance.io
    ]

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /**
     Initialize network security policies.
     Should be called during app launch.
     */
    @MainActor
    public func initialize() {
        // Configure SSL Pinning
        self.pinningManager.configure(
            certificateHashes: self.pinnedHashes,
            domains: self.securedDomains
        )

        Logger.logInfo("Network security policies initialized")
    }

    /**
     Creates a URLSession configuration with security policies applied.
     - Returns: A secure URLSessionConfiguration.
     */
    public func createSecureConfiguration() -> URLSessionConfiguration {
        let configuration = self.pinningManager.createPinnedSessionConfiguration()

        // Additional security headers
        configuration.httpAdditionalHeaders = [
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY",
            "X-XSS-Protection": "1; mode=block",
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
        ]

        return configuration
    }

    /**
     Creates a secure URLSession with the manager as delegate for SSL pinning.
     - Returns: A secure URLSession instance.
     */
    public func createSecureSession() -> URLSession {
        let configuration = self.createSecureConfiguration()
        return URLSession(
            configuration: configuration,
            delegate: self.pinningManager,
            delegateQueue: nil
        )
    }
}
