// Momentum Finance - Security Tests
// Copyright © 2026 Momentum Finance. All rights reserved.

import XCTest
@testable import MomentumFinanceCore

/// Comprehensive security test suite for MomentumFinance.
///
/// Tests credential management, encryption, input validation, and biometric auth.
final class SecurityTests: XCTestCase {
    // MARK: - Test Setup

    override func setUp() {
        super.setUp()
        // Clean up any test credentials
        try? SecureCredentialManager.shared.deleteAll()
    }

    override func tearDown() {
        // Clean up after tests
        try? SecureCredentialManager.shared.deleteAll()
        super.tearDown()
    }

    // MARK: - Secure Credential Manager Tests

    func testStoreAndRetrieveCredential() throws {
        let credentialManager = SecureCredentialManager.shared
        let testKey: SecureCredentialManager.CredentialKey = .apiKey
        let testValue = "test-api-key-12345"

        // Store credential
        try credentialManager.store(testValue, forKey: testKey)

        // Retrieve credential
        let retrieved = try credentialManager.retrieve(testKey)

        XCTAssertEqual(retrieved, testValue, "Retrieved credential should match stored value")
    }

    func testCredentialOverwrite() throws {
        let credentialManager = SecureCredentialManager.shared
        let testKey: SecureCredentialManager.CredentialKey = .authToken

        // Store initial value
        try credentialManager.store("first-value", forKey: testKey)

        // Overwrite with new value
        try credentialManager.store("second-value", forKey: testKey)

        // Should retrieve the latest value
        let retrieved = try credentialManager.retrieve(testKey)
        XCTAssertEqual(retrieved, "second-value", "Should retrieve overwritten value")
    }

    func testDeleteCredential() throws {
        let credentialManager = SecureCredentialManager.shared
        let testKey: SecureCredentialManager.CredentialKey = .syncToken

        // Store credential
        try credentialManager.store("test-token", forKey: testKey)
        XCTAssertTrue(credentialManager.exists(testKey), "Credential should exist")

        // Delete credential
        try credentialManager.delete(testKey)
        XCTAssertFalse(credentialManager.exists(testKey), "Credential should be deleted")

        // Attempt to retrieve should return nil
        let retrieved = try credentialManager.retrieve(testKey)
        XCTAssertNil(retrieved, "Deleted credential should return nil")
    }

    func testCredentialExists() throws {
        let credentialManager = SecureCredentialManager.shared
        let testKey: SecureCredentialManager.CredentialKey = .refreshToken

        // Initially should not exist
        XCTAssertFalse(credentialManager.exists(testKey), "Credential should not exist initially")

        // After storing should exist
        try credentialManager.store("test", forKey: testKey)
        XCTAssertTrue(credentialManager.exists(testKey), "Credential should exist after storing")
    }

    func testDeleteAllCredentials() throws {
        let credentialManager = SecureCredentialManager.shared

        // Store multiple credentials
        try credentialManager.store("key1", forKey: .apiKey)
        try credentialManager.store("key2", forKey: .authToken)
        try credentialManager.store("key3", forKey: .encryptionKey)

        // Delete all
        try credentialManager.deleteAll()

        // Verify all are deleted
        XCTAssertFalse(credentialManager.exists(.apiKey))
        XCTAssertFalse(credentialManager.exists(.authToken))
        XCTAssertFalse(credentialManager.exists(.encryptionKey))
    }

    // MARK: - Data Encryption Service Tests

    func testEncryptDecryptString() throws {
        let encryptionService = DataEncryptionService.shared
        let plaintext = "Sensitive financial data: Account #123456789, Balance: $50,000.00"

        // Encrypt
        let encrypted = try encryptionService.encrypt(plaintext)

        // Encrypted data should be different from plaintext
        XCTAssertNotEqual(encrypted, plaintext, "Encrypted data should differ from plaintext")

        // Decrypt
        let decrypted = try encryptionService.decrypt(encrypted)

        // Decrypted should match original
        XCTAssertEqual(decrypted, plaintext, "Decrypted data should match original plaintext")
    }

    func testEncryptionDeterminism() throws {
        let encryptionService = DataEncryptionService.shared
        let plaintext = "Test data"

        // Encrypt same data twice
        let encrypted1 = try encryptionService.encrypt(plaintext)
        let encrypted2 = try encryptionService.encrypt(plaintext)

        // Should produce different ciphertexts (due to random nonce)
        XCTAssertNotEqual(encrypted1, encrypted2, "Encryption should use random nonce")

        // But both should decrypt to same plaintext
        let decrypted1 = try encryptionService.decrypt(encrypted1)
        let decrypted2 = try encryptionService.decrypt(encrypted2)

        XCTAssertEqual(decrypted1, plaintext)
        XCTAssertEqual(decrypted2, plaintext)
    }

    func testEncryptDecryptFields() throws {
        let encryptionService = DataEncryptionService.shared
        let fields = [
            "accountNumber": "123456789",
            "routingNumber": "987654321",
            "balance": "50000.00",
        ]

        // Encrypt fields
        let encrypted = try encryptionService.encryptFields(fields)

        // All values should be encrypted
        XCTAssertNotEqual(encrypted["accountNumber"], fields["accountNumber"])
        XCTAssertNotEqual(encrypted["routingNumber"], fields["routingNumber"])
        XCTAssertNotEqual(encrypted["balance"], fields["balance"])

        // Decrypt fields
        let decrypted = try encryptionService.decryptFields(encrypted)

        // Should match original
        XCTAssertEqual(decrypted, fields)
    }

    func testInvalidDecryption() {
        let encryptionService = DataEncryptionService.shared

        // Try to decrypt invalid data
        XCTAssertThrowsError(try encryptionService.decrypt("invalid-encrypted-data")) { error in
            XCTAssertTrue(error is DataEncryptionService.EncryptionError)
        }
    }

    // MARK: - Input Validator Tests

    func testValidateAmount() throws {
        let validator = InputValidator.shared

        // Valid amounts
        XCTAssertEqual(try validator.validateAmount("$123.45"), Decimal(string: "123.45"))
        XCTAssertEqual(try validator.validateAmount("1,234.56"), Decimal(string: "1234.56"))
        XCTAssertEqual(try validator.validateAmount("-50.00"), Decimal(string: "-50.00"))

        // Invalid amounts
        XCTAssertThrowsError(try validator.validateAmount("not-a-number"))
        XCTAssertThrowsError(try validator.validateAmount("$1,000,000,000,000.00")) // Too large
    }

    func testValidateAccountNumber() {
        let validator = InputValidator.shared

        // Valid account numbers
        XCTAssertTrue(validator.isValidAccountNumber("12345678"))
        XCTAssertTrue(validator.isValidAccountNumber("123456789012345"))
        XCTAssertTrue(validator.isValidAccountNumber("1234-5678-9012"))

        // Invalid account numbers
        XCTAssertFalse(validator.isValidAccountNumber("123")) // Too short
        XCTAssertFalse(validator.isValidAccountNumber("123456789012345678")) // Too long
        XCTAssertFalse(validator.isValidAccountNumber("ABCD1234")) // Contains letters
    }

    func testValidateRoutingNumber() {
        let validator = InputValidator.shared

        // Valid routing numbers (with correct checksum)
        XCTAssertTrue(validator.isValidRoutingNumber("021000021")) // Chase
        XCTAssertTrue(validator.isValidRoutingNumber("011103093")) // Bank of America

        // Invalid checksum
        XCTAssertFalse(validator.isValidRoutingNumber("123456789"))

        // Invalid format
        XCTAssertFalse(validator.isValidRoutingNumber("12345")) // Too short
        XCTAssertFalse(validator.isValidRoutingNumber("ABC123456")) // Contains letters
    }

    func testSQLInjectionDetection() {
        let validator = InputValidator.shared

        // SQL injection attempts
        XCTAssertTrue(validator.containsSQLInjectionPatterns("'; DROP TABLE users;--"))
        XCTAssertTrue(validator.containsSQLInjectionPatterns("1' OR '1'='1"))
        XCTAssertTrue(validator.containsSQLInjectionPatterns("admin' --"))
        XCTAssertTrue(validator.containsSQLInjectionPatterns("SELECT * FROM accounts"))

        // Safe strings
        XCTAssertFalse(validator.containsSQLInjectionPatterns("John's Coffee Shop"))
        XCTAssertFalse(validator.containsSQLInjectionPatterns("Normal transaction description"))
    }

    func testXSSDetection() {
        let validator = InputValidator.shared

        // XSS attempts
        XCTAssertTrue(validator.containsXSSPatterns("<script>alert('XSS')</script>"))
        XCTAssertTrue(validator.containsXSSPatterns("<img src=x onerror=alert('XSS')>"))
        XCTAssertTrue(validator.containsXSSPatterns("javascript:alert('XSS')"))
        XCTAssertTrue(validator.containsXSSPatterns("<iframe src='malicious.com'>"))

        // Safe strings
        XCTAssertFalse(validator.containsXSSPatterns("Coffee at Java Script Cafe"))
        XCTAssertFalse(validator.containsXSSPatterns("Normal text with <brackets>"))
    }

    func testInputSanitization() {
        let validator = InputValidator.shared

        // SQL injection sanitization
        let sqlInput = "Robert'); DROP TABLE users;--"
        let sanitized = validator.sanitize(sqlInput)
        XCTAssertNotEqual(sanitized, sqlInput, "Should sanitize SQL injection")
        XCTAssertFalse(sanitized.contains("DROP"), "Should escape dangerous SQL")

        // XSS sanitization
        let xssInput = "<script>alert('XSS')</script>"
        let sanitizedXSS = validator.sanitize(xssInput)
        XCTAssertFalse(sanitizedXSS.contains("<script>"), "Should escape script tags")
        XCTAssertTrue(
            sanitizedXSS.contains("&lt;") || sanitizedXSS.contains("&gt;"),
            "Should use HTML entities"
        )
    }

    func testEmailValidation() {
        let validator = InputValidator.shared

        // Valid emails
        XCTAssertTrue(validator.isValidEmail("test@example.com"))
        XCTAssertTrue(validator.isValidEmail("user.name+tag@example.co.uk"))
        XCTAssertTrue(validator.isValidEmail("test_123@subdomain.example.com"))

        // Invalid emails
        XCTAssertFalse(validator.isValidEmail("invalid"))
        XCTAssertFalse(validator.isValidEmail("@example.com"))
        XCTAssertFalse(validator.isValidEmail("test@"))
        XCTAssertFalse(validator.isValidEmail("test@.com"))
    }

    func testPIIRedaction() {
        let validator = InputValidator.shared

        // Credit card redaction
        let textWithCard = "My card number is 1234-5678-9012-3456"
        let redacted = validator.redactPII(textWithCard)
        XCTAssertFalse(redacted.contains("1234-5678-9012-3456"))
        XCTAssertTrue(redacted.contains("[CARD REDACTED]"))

        // Email redaction
        let textWithEmail = "Contact me at user@example.com for details"
        let redactedEmail = validator.redactPII(textWithEmail)
        XCTAssertFalse(redactedEmail.contains("user@example.com"))
        XCTAssertTrue(redactedEmail.contains("[EMAIL REDACTED]"))

        // SSN redaction
        let textWithSSN = "SSN: 123-45-6789"
        let redactedSSN = validator.redactPII(textWithSSN)
        XCTAssertFalse(redactedSSN.contains("123-45-6789"))
        XCTAssertTrue(redactedSSN.contains("[SSN REDACTED]"))
    }

    func testLengthValidation() throws {
        let validator = InputValidator.shared

        // Valid length
        XCTAssertNoThrow(try validator.validateLength("Normal text", minLength: 5, maxLength: 20))

        // Too short
        XCTAssertThrowsError(try validator.validateLength("Hi", minLength: 5)) { error in
            guard case InputValidator.ValidationError.stringTooShort = error else {
                XCTFail("Expected stringTooShort error")
                return
            }
        }

        // Too long
        XCTAssertThrowsError(
            try validator.validateLength("This is a very long string", maxLength: 10)
        ) { error in
            guard case InputValidator.ValidationError.stringTooLong = error else {
                XCTFail("Expected stringTooLong error")
                return
            }
        }
    }

    // MARK: - Biometric Auth Manager Tests (MockTests - simulator safe)

    func testBiometricAvailability() {
        let biometricManager = BiometricAuthManager.shared

        // Just verify we can check availability without crashing
        let isAvailable = biometricManager.isBiometricAvailable
        let biometricType = biometricManager.biometricType

        // On simulator, typically returns .none
        XCTAssertNotNil(biometricType, "Should return a biometric type")
    }

    // MARK: - Integration Tests

    func testEndToEndEncryptedCredentialStorage() throws {
        let credentialManager = SecureCredentialManager.shared
        let encryptionService = DataEncryptionService.shared

        // Sensitive data
        let accountNumber = "123456789"

        // Encrypt then store
        let encrypted = try encryptionService.encrypt(accountNumber)
        try credentialManager.store(encrypted, forKey: .apiKey)

        // Retrieve and decrypt
        guard let retrieved = try credentialManager.retrieve(.apiKey) else {
            XCTFail("Should retrieve stored credential")
            return
        }

        let decrypted = try encryptionService.decrypt(retrieved)

        XCTAssertEqual(decrypted, accountNumber, "End-to-end encryption should preserve data")
    }

    func testValidatedEncryptedStorage() throws {
        let validator = InputValidator.shared
        let encryptionService = DataEncryptionService.shared

        // Validate input
        let accountNumber = "123456789"
        XCTAssertTrue(
            validator.isValidAccountNumber(accountNumber), "Should validate account number"
        )

        // Sanitize (in case of user input)
        let sanitized = validator.sanitize(accountNumber)

        // Encrypt
        let encrypted = try encryptionService.encrypt(sanitized)

        // Decrypt and verify
        let decrypted = try encryptionService.decrypt(encrypted)
        XCTAssertEqual(decrypted, accountNumber)
    }
}
