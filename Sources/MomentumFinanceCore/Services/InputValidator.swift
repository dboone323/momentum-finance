//
// InputValidator.swift
// MomentumFinance
//

import Foundation

@MainActor
public final class InputValidator {

    public static let shared = InputValidator()

    public enum ValidationError: Error {
        case emptyInput
        case invalidAmount
        case invalidAccountNumber
        case potentialInjection
    }

    private init() {}

    public func validateAmount(_ amount: String) throws -> Decimal {
        guard !amount.isEmpty else { throw ValidationError.emptyInput }
        let sanitized = amount.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: sanitized) else {
            throw ValidationError.invalidAmount
        }
        return decimal
    }

    public func isValidAccountNumber(_ number: String) -> Bool {
        let pattern = "^[0-9]{8,17}$"
        return number.range(of: pattern, options: .regularExpression) != nil
    }

    /// Sanitizes input by removing potentially dangerous characters.
    public nonisolated static func sanitize(_ input: String) -> String {
        // Basic sanitization
        var sanitized = input
        let noisyChars = ["<", ">", ";", "'", "--"]
        for char in noisyChars {
            sanitized = sanitized.replacingOccurrences(of: char, with: "")
        }
        return sanitized
    }

    public nonisolated func sanitize(_ input: String) -> String {
        Self.sanitize(input)
    }

    /// Redacts PII from a message.
    /// This is nonisolated so it can be called from logging contexts.
    public nonisolated static func redactPII(_ message: String) -> String {
        var redacted = message

        // Redact email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        redacted = redacted.replacingOccurrences(
            of: emailRegex, with: "[EMAIL]", options: .regularExpression
        )

        // Redact cards
        let cardRegex = "\\b\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}\\b"
        redacted = redacted.replacingOccurrences(
            of: cardRegex, with: "[CARD]", options: .regularExpression
        )

        return redacted
    }

    public nonisolated func redactPII(_ message: String) -> String {
        Self.redactPII(message)
    }
}
