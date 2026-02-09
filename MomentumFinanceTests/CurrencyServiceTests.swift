//
// CurrencyServiceTests.swift
// MomentumFinanceTests
//
// Tests for multi-currency support and exchange rates
//

import XCTest
@testable import MomentumFinance

final class CurrencyServiceTests: XCTestCase {
    var service: CurrencyService!

    override func setUpWithError() throws {
        service = CurrencyService.shared
    }

    // MARK: - Currency Symbol Tests

    func testUSDSymbol() {
        XCTAssertEqual(Currency.usd.symbol, "$")
    }

    func testEURSymbol() {
        XCTAssertEqual(Currency.eur.symbol, "€")
    }

    func testGBPSymbol() {
        XCTAssertEqual(Currency.gbp.symbol, "£")
    }

    func testJPYSymbol() {
        XCTAssertEqual(Currency.jpy.symbol, "¥")
    }

    func testCADSymbol() {
        XCTAssertEqual(Currency.cad.symbol, "$")
    }

    // MARK: - Currency ID Tests

    func testCurrencyIdentifiers() {
        XCTAssertEqual(Currency.usd.id, "USD")
        XCTAssertEqual(Currency.eur.id, "EUR")
        XCTAssertEqual(Currency.gbp.id, "GBP")
        XCTAssertEqual(Currency.jpy.id, "JPY")
        XCTAssertEqual(Currency.cad.id, "CAD")
    }

    // MARK: - Currency Conversion Tests

    func testConvertUSDToUSD() {
        let result = service.convert(amount: 100, from: .usd, to: .usd)
        XCTAssertEqual(result, 100)
    }

    func testConvertUSDToEUR() {
        let result = service.convert(amount: 100, from: .usd, to: .eur)
        // With rate EUR = 0.92, $100 USD = €92
        XCTAssertEqual(result, 92)
    }

    func testConvertEURToUSD() {
        let result = service.convert(amount: 92, from: .eur, to: .usd)
        // €92 should convert back to $100
        XCTAssertEqual(result, 100)
    }

    func testConvertUSDToJPY() {
        let result = service.convert(amount: 100, from: .usd, to: .jpy)
        // With rate JPY = 150.5, $100 USD = ¥15,050
        XCTAssertEqual(result, Decimal(15050.0))
    }

    func testConvertGBPToCAD() {
        let result = service.convert(amount: 79, from: .gbp, to: .cad)
        // £79 GBP → USD → CAD
        // £79 / 0.79 = $100 USD, $100 * 1.35 = $135 CAD
        XCTAssertEqual(result, 135)
    }

    // MARK: - Currency Formatting Tests

    func testFormatUSD() {
        let formatted = service.format(123.45, currency: .usd)
        XCTAssertTrue(formatted.contains("$"))
        XCTAssertTrue(formatted.contains("123"))
    }

    func testFormatEUR() {
        let formatted = service.format(99.99, currency: .eur)
        XCTAssertTrue(formatted.contains("€") || formatted.contains("EUR"))
        XCTAssertTrue(formatted.contains("99"))
    }

    func testFormatJPY() {
        let formatted = service.format(10000, currency: .jpy)
        XCTAssertTrue(formatted.contains("¥") || formatted.contains("JPY"))
    }

    // MARK: - All Currencies Test

    func testAllCurrenciesCaseIterable() {
        let allCurrencies = Currency.allCases
        XCTAssertEqual(allCurrencies.count, 5)
        XCTAssertTrue(allCurrencies.contains(.usd))
        XCTAssertTrue(allCurrencies.contains(.eur))
        XCTAssertTrue(allCurrencies.contains(.gbp))
        XCTAssertTrue(allCurrencies.contains(.jpy))
        XCTAssertTrue(allCurrencies.contains(.cad))
    }
}
