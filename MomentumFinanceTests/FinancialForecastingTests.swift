import XCTest
@testable import MomentumFinance

class FinancialForecastingTests: XCTestCase {

    // MARK: - Test setup

    override func setUp() {
        super.setUp()
        // Set up any necessary data for testing
    }

    override func tearDown() {
        super.tearDown()
        // Clean up any resources after each test
    }

    // MARK: - Income Forecasting Tests

    func test_incomeForecasting_withNoIncomeTransactions() throws {
        let transactions = []
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 0)
    }

    func test_incomeForecasting_withSinglePositiveTransaction() throws {
        let transactions = [FinancialTransaction(amount: 1000, date: Date())]
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 1)
        XCTAssertEqual(insights[0].title, "Income Forecast")
        XCTAssertEqual(insights[0].description, "Based on recent trends, your estimated monthly income is $1,000. This forecast helps with budgeting and financial planning.")
        XCTAssertEqual(insights[0].priority, InsightPriority.low)
        XCTAssertEqual(insights[0].type, InsightType.forecast)
        XCTAssertEqual(insights[0].visualizationType, VisualizationType.lineChart)
        XCTAssertEqual(insights[0].data.count, 2)
    }

    func test_incomeForecasting_withMultipleIncomeTransactions() throws {
        let transactions = [
            FinancialTransaction(amount: 1000, date: Date()),
            FinancialTransaction(amount: -500, date: Date()),
            FinancialTransaction(amount: 750, date: Date())
        ]
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 1)
        XCTAssertEqual(insights[0].title, "Income Forecast")
        XCTAssertEqual(insights[0].description, "Based on recent trends, your estimated monthly income is $1,250. This forecast helps with budgeting and financial planning.")
        XCTAssertEqual(insights[0].priority, InsightPriority.low)
        XCTAssertEqual(insights[0].type, InsightType.forecast)
        XCTAssertEqual(insights[0].visualizationType, VisualizationType.lineChart)
        XCTAssertEqual(insights[0].data.count, 2)
    }

    // MARK: - Spending Forecasting Tests

    func test_spendingForecasting_withNoExpenseTransactions() throws {
        let transactions = []
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 0)
    }

    func test_spendingForecasting_withSingleNegativeTransaction() throws {
        let transactions = [FinancialTransaction(amount: -1000, date: Date())]
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 1)
        XCTAssertEqual(insights[0].title, "Expense Forecast")
        XCTAssertEqual(insights[0].description, "Based on recent trends, your estimated monthly expenses are $1,000. Use this to plan your budget and savings goals.")
        XCTAssertEqual(insights[0].priority, InsightPriority.low)
        XCTAssertEqual(insights[0].type, InsightType.forecast)
        XCTAssertEqual(insights[0].visualizationType, VisualizationType.lineChart)
        XCTAssertEqual(insights[0].data.count, 2)
    }

    func test_spendingForecasting_withMultipleExpenseTransactions() throws {
        let transactions = [
            FinancialTransaction(amount: -1000, date: Date()),
            FinancialTransaction(amount: 500, date: Date()),
            FinancialTransaction(amount: -750, date: Date())
        ]
        let accounts = []

        let insights = fi_generateFinancialForecasts(transactions: transactions, accounts: accounts)

        XCTAssertEqual(insights.count, 1)
        XCTAssertEqual(insights[0].title, "Expense Forecast")
        XCTAssertEqual(insights[0].description, "Based on recent trends, your estimated monthly expenses are $375. Use this to plan your budget and savings goals.")
        XCTAssertEqual(insights[0].priority, InsightPriority.low)
        XCTAssertEqual(insights[0].type, InsightType.forecast)
        XCTAssertEqual(insights[0].visualizationType, VisualizationType.lineChart)
        XCTAssertEqual(insights[0].data.count, 2)
    }
