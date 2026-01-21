//
// SSLPinningTests.swift
// MomentumFinanceTests
//
// Unit tests for SSL/Certificate Pinning validation.
//

import CryptoKit
@testable import MomentumFinance
import Security
import XCTest

final class SSLPinningTests: XCTestCase {
    var pinningManager: SSLPinningManager!

    override func setUpWithError() throws {
        pinningManager = SSLPinningManager.shared
    }

    override func tearDownWithError() throws {
        // Reset configuration
    }

    // MARK: - Configuration Tests

    func testPinningManagerConfiguration() {
        let hashes = ["abc123", "def456"]
        let domains = ["api.example.com", "secure.example.com"]

        pinningManager.configure(certificateHashes: hashes, domains: domains)

        XCTAssertTrue(pinningManager.requiresPinning(for: "api.example.com"))
        XCTAssertTrue(pinningManager.requiresPinning(for: "secure.example.com"))
        XCTAssertFalse(pinningManager.requiresPinning(for: "other.example.com"))
    }

    func testAddPinnedDomain() {
        pinningManager.addPinnedDomain("new.example.com")

        XCTAssertTrue(pinningManager.requiresPinning(for: "new.example.com"))
    }

    func testDomainMatchingIsCaseInsensitive() {
        pinningManager.addPinnedDomain("API.Example.COM")

        XCTAssertTrue(pinningManager.requiresPinning(for: "api.example.com"))
        XCTAssertTrue(pinningManager.requiresPinning(for: "API.EXAMPLE.COM"))
    }

    // MARK: - Session Configuration Tests

    func testPinnedSessionConfiguration() {
        let config = pinningManager.createPinnedSessionConfiguration()

        XCTAssertEqual(config.tlsMinimumSupportedProtocolVersion, .TLSv12)
        XCTAssertEqual(config.tlsMaximumSupportedProtocolVersion, .TLSv13)
    }

    // MARK: - Hash Computation Tests

    func testSHA256HashComputation() {
        let testData = Data("Test Public Key Data".utf8)
        let hash = SHA256.hash(data: testData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()

        XCTAssertEqual(hashString.count, 64) // SHA256 produces 64 hex characters
    }

    // MARK: - Validation Tests

    func testNonPinnedDomainAllowed() {
        // Domains not in pinned list should pass validation
        let result = pinningManager.validate(serverTrust: createMockServerTrust(), for: "unpinned.example.com")

        // Non-pinned domains should pass
        XCTAssertTrue(result)
    }

    // Helper to create mock server trust for testing
    private func createMockServerTrust() -> SecTrust {
        // Create a minimal mock for testing
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        SecTrustCreateWithCertificates([] as CFArray, policy, &trust)
        return trust!
    }
}
