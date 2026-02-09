// Momentum Finance - Security Integration Example
// Copyright © 2026 Momentum Finance. All rights reserved.
//
// This file demonstrates how to use the security services together

import Foundation
import SwiftUI

/**
 Integration example showing how to use all security services together.

 Use this as a reference when integrating security into MomentumFinanceApp.
 */

// MARK: - Example 1: Secure API Key Storage

/// Store an API key securely
@MainActor
func storeAPIKey(_ apiKey: String) throws {
    let credentialManager = SecureCredentialManager.shared

    // Store in Keychain with biometric protection
    try credentialManager.store(
        apiKey,
        forKey: .apiKey,
        requireBiometric: true // Require Face ID/Touch ID to retrieve
    )

    Logger.logInfo("API key stored securely")
}

/// Retrieve API key with biometric auth
@MainActor
func retrieveAPIKey() throws -> String? {
    let credentialManager = SecureCredentialManager.shared

    // This will prompt for biometric authentication
    let apiKey = try credentialManager.retrieve(.apiKey, requireBiometric: true)

    if apiKey != nil {
        Logger.logInfo("API key retrieved successfully")
    }

    return apiKey
}

// MARK: - Example 2: Validate and Encrypt User Input

/// Safely process user input with validation and encryption
@MainActor
func processFinancialTransaction(
    amount: String,
    description: String,
    accountNumber: String
) throws -> String {
    let validator = InputValidator.shared
    let encryption = DataEncryptionService.shared

    // 1. Validate inputs
    let validatedAmount = try validator.validateAmount(amount)

    guard validator.isValidAccountNumber(accountNumber) else {
        throw InputValidator.ValidationError.invalidAccountNumber
    }

    // 2. Sanitize description (remove potential injection attacks)
    let sanitizedDescription = validator.sanitize(description)

    // 3. Encrypt sensitive data
    let encryptedAccountNumber = try encryption.encrypt(accountNumber)

    // 4. Log transaction (PII automatically redacted by Logger)
    Logger.logBusiness(
        "Transaction processed: \(validatedAmount) for account \(accountNumber)"
        // Logger will redact the account number automatically
    )

    return encryptedAccountNumber
}

// MARK: - Example 3: Secure Data Export

/// Export financial data with encryption
@MainActor
func exportFinancialData(transactions: [CoreTransaction]) throws -> URL {
    let encryption = DataEncryptionService.shared

    // Convert to dictionary for encryption
    let data = transactions.map { transaction in
        [
            "id": transaction.id.uuidString,
            "amount": String(describing: transaction.amount),
            "description": transaction.note,
            "date": ISO8601DateFormatter().string(from: transaction.date),
        ]
    }

    // Encrypt the entire dataset
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(data)

    let encrypted = try encryption.encrypt(jsonData)

    // Save to file
    let tempURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("transactions_encrypted.json")

    try encrypted.write(to: tempURL, options: .atomic)

    Logger.logData("Exported \(transactions.count) transactions securely")

    return tempURL
}

// MARK: - Example 4: Form Validation in SwiftUI

struct SecureTransactionForm: View {
    @State private var amount: String = ""
    @State private var accountNumber: String = ""
    @State private var errorMessage: String?

    private let validator = InputValidator.shared

    var body: some View {
        Form {
            TextField("Amount", text: $amount)
                .onChange(of: amount) { _, newValue in
                    validateAmount(newValue)
                }

            TextField("Account Number", text: $accountNumber)
                .onChange(of: accountNumber) { _, newValue in
                    validateAccountNumber(newValue)
                }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Submit") {
                Task { @MainActor in
                    submitTransaction()
                }
            }
            .disabled(errorMessage != nil)
        }
    }

    @MainActor
    private func validateAmount(_ value: String) {
        do {
            _ = try validator.validateAmount(value)
            errorMessage = nil
        } catch {
            errorMessage = "Invalid amount format"
        }
    }

    @MainActor
    private func validateAccountNumber(_ value: String) {
        if !validator.isValidAccountNumber(value) {
            errorMessage = "Invalid account number (8-17 digits required)"
        } else {
            errorMessage = nil
        }
    }

    @MainActor
    private func submitTransaction() {
        do {
            let encryptedAccount = try processFinancialTransaction(
                amount: amount,
                description: "Transaction",
                accountNumber: accountNumber
            )

            Logger.logInfo("Transaction submitted successfully")

            // Store encrypted account for later use
            try SecureCredentialManager.shared.store(
                encryptedAccount,
                forKey: .apiKey // Use appropriate key
            )

        } catch {
            ErrorHandler.shared.handle(error, context: "Transaction submission")
        }
    }
}

// MARK: - Example 5: Biometric Authentication Flow

@MainActor
class BiometricAuthExample {
    private let biometricAuth = BiometricAuthManager.shared

    /// Check if biometrics are available
    func checkBiometricSupport() -> String {
        if biometricAuth.isBiometricAvailable {
            "Biometric authentication available: \(biometricAuth.biometricType.rawValue)"
        } else {
            "Biometric authentication not available"
        }
    }

    /// Authenticate user before accessing sensitive data
    func accessSensitiveData() async throws -> String {
        // Require biometric auth
        let authenticated = try await biometricAuth.authenticate(
            reason: "Authenticate to view account balance"
        )

        guard authenticated else {
            throw BiometricAuthManager.BiometricError.failed
        }

        // User authenticated - retrieve sensitive data
        guard
            let apiKey = try SecureCredentialManager.shared.retrieve(
                .apiKey, requireBiometric: false
            )
        else {
            throw NSError(
                domain: "App", code: 1, userInfo: [NSLocalizedDescriptionKey: "No API key found"]
            )
        }

        return apiKey
    }
}

// MARK: - Example 6: Logging with Automatic PII Redaction

func demonstratePIIRedaction() {
    // All of these will have PII automatically redacted by Logger

    Logger.logInfo("User email: test@example.com")
    // Logs as: "User email: [EMAIL]"

    Logger.logError(
        NSError(
            domain: "App", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Payment failed for card 1234-5678-9012-3456"]
        ),
        context: "Processing payment"
    )
    // Logs card as: "[CARD]"

    Logger.logBusiness("SSN check for 123-45-6789 completed")
    // Logs as: "SSN check for [SSN] completed"
}
