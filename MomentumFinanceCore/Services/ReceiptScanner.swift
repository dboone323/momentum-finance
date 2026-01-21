//
// ReceiptScanner.swift
// MomentumFinance
//
// Step 40: Receipt scanning with Vision framework.
//

import Foundation
import Vision
#if canImport(UIKit)
    import UIKit
#endif

/// Result of receipt scanning.
public struct ReceiptScanResult {
    public var merchantName: String?
    public var totalAmount: Double?
    public var date: Date?
    public var items: [ReceiptItem]
    public var rawText: String
    public var confidence: Double

    public struct ReceiptItem {
        public var name: String
        public var price: Double?
    }
}

/// Scanner for extracting data from receipt images.
public final class ReceiptScanner {
    public static let shared = ReceiptScanner()

    private init() {}

    // MARK: - Scanning

    #if canImport(UIKit)
        /// Scans a receipt image and extracts data.
        public func scan(image: UIImage) async throws -> ReceiptScanResult {
            guard let cgImage = image.cgImage else {
                throw ReceiptScanError.invalidImage
            }

            let text = try await recognizeText(in: cgImage)
            return parseReceipt(from: text)
        }
    #endif

    /// Recognizes text in an image using Vision.
    private func recognizeText(in image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: image, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Parsing

    private func parseReceipt(from text: String) -> ReceiptScanResult {
        var result = ReceiptScanResult(
            items: [],
            rawText: text,
            confidence: 0.0
        )

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            // Try to extract merchant name (usually first non-empty line)
            if result.merchantName == nil && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                result.merchantName = line.trimmingCharacters(in: .whitespaces)
            }

            // Try to extract total
            if let total = extractTotal(from: line) {
                result.totalAmount = total
            }

            // Try to extract date
            if let date = extractDate(from: line) {
                result.date = date
            }

            // Try to extract items with prices
            if let item = extractItem(from: line) {
                result.items.append(item)
            }
        }

        // Calculate confidence based on what was extracted
        var confidenceScore = 0.0
        if result.merchantName != nil { confidenceScore += 0.2 }
        if result.totalAmount != nil { confidenceScore += 0.3 }
        if result.date != nil { confidenceScore += 0.2 }
        if !result.items.isEmpty { confidenceScore += 0.3 }
        result.confidence = confidenceScore

        return result
    }

    private func extractTotal(from line: String) -> Double? {
        let patterns = [
            #"(?i)total[:\s]*\$?(\d+\.?\d*)"#,
            #"(?i)amount[:\s]*\$?(\d+\.?\d*)"#,
            #"(?i)grand total[:\s]*\$?(\d+\.?\d*)"#,
            #"\$(\d+\.\d{2})\s*$"#,
        ]

        for pattern in patterns {
            if let match = line.range(of: pattern, options: .regularExpression) {
                let matchedString = String(line[match])
                if let amount = extractAmount(from: matchedString) {
                    return amount
                }
            }
        }

        return nil
    }

    private func extractDate(from line: String) -> Date? {
        let datePatterns = [
            "MM/dd/yyyy",
            "MM-dd-yyyy",
            "yyyy-MM-dd",
            "MMM dd, yyyy",
        ]

        let formatter = DateFormatter()

        for pattern in datePatterns {
            formatter.dateFormat = pattern
            // Try to find date-like substring
            let words = line.components(separatedBy: .whitespaces)
            for word in words {
                if let date = formatter.date(from: word) {
                    return date
                }
            }
        }

        return nil
    }

    private func extractItem(from line: String) -> ReceiptScanResult.ReceiptItem? {
        // Pattern: item name followed by price
        let pattern = #"^(.+?)\s+\$?(\d+\.?\d*)$"#

        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line))
        {
            if let nameRange = Range(match.range(at: 1), in: line),
               let priceRange = Range(match.range(at: 2), in: line)
            {
                let name = String(line[nameRange]).trimmingCharacters(in: .whitespaces)
                let priceStr = String(line[priceRange])
                let price = Double(priceStr)

                if !name.isEmpty {
                    return ReceiptScanResult.ReceiptItem(name: name, price: price)
                }
            }
        }

        return nil
    }

    private func extractAmount(from string: String) -> Double? {
        let pattern = #"(\d+\.?\d*)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
           let range = Range(match.range, in: string)
        {
            return Double(String(string[range]))
        }
        return nil
    }

    // MARK: - Errors

    public enum ReceiptScanError: LocalizedError {
        case invalidImage
        case recognitionFailed

        public var errorDescription: String? {
            switch self {
            case .invalidImage:
                "Unable to process the image"
            case .recognitionFailed:
                "Text recognition failed"
            }
        }
    }
}
