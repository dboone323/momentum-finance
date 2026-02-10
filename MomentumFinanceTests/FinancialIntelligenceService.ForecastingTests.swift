import XCTest
@testable import MomentumFinance

class FinancialIntelligenceServiceTests: XCTestCase {
    var service: FinancialIntelligenceService!

    /// Test generateForecasts method with sample data
    func testGenerateForecasts() throws {
        let transactions = [
            FinancialTransaction(date: Date(), amount: 100.0, account: FinancialAccount(id: "1", name: "Checking")),
            FinancialTransaction(
                date: Date().addingTimeInterval(30 * 24 * 60 * 60),
                amount: -50.0,
                account: FinancialAccount(id: "1", name: "Checking")
            ),
        ]
        let accounts = [
            FinancialAccount(id: "1", name: "Checking", currencyCode: "USD"),
        ]

        let insights = service.generateForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 2)
        XCTAssertTrue(insights[0].type == .forecast)
        XCTAssertTrue(insights[1].type == .forecast)
    }

    /// Test generateAccountForecastInsight method with sample data
    func testGenerateAccountForecastInsight() throws {
        let account = FinancialAccount(id: "1", name: "Checking", currencyCode: "USD")
        let transactions = [
            FinancialTransaction(date: Date(), amount: 100.0, account: account),
            FinancialTransaction(date: Date().addingTimeInterval(30 * 24 * 60 * 60), amount: -50.0, account: account),
        ]
        let calendar = Calendar.current

        let insight = service.generateAccountForecastInsight(
            account: account,
            transactions: transactions,
            calendar: calendar
        )

        XCTAssertEqual(insight?.type, .forecast)
        XCTAssertTrue(insight?.priority == .medium)
    }

    /// Test generateForecasts method with no transactions
    func testGenerateForecastsNoTransactions() throws {
        let transactions = []
        let accounts = [
            FinancialAccount(id: "1", name: "Checking", currencyCode: "USD"),
        ]

        let insights = service.generateForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 0)
    }

    /// Test generateAccountForecastInsight method with no account
    func testGenerateAccountForecastInsightNoAccount() throws {
        let account = FinancialAccount(id: "1", name: "Checking", currencyCode: "USD")
        let transactions = [
            FinancialTransaction(date: Date(), amount: 100.0, account: account),
        ]
        let calendar = Calendar.current

        let insight = service.generateAccountForecastInsight(
            account: nil,
            transactions: transactions,
            calendar: calendar
        )

        XCTAssertNil(insight)
    }
}
