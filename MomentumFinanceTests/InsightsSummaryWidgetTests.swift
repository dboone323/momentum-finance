import XCTest
@testable import MomentumFinance

class InsightsSummaryWidgetTests: XCTestCase {
    var widget: InsightsSummaryWidget!

    override func setUp() {
        super.setUp()
        widget = InsightsSummaryWidget()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test Case 1: Insight Empty State View
    func testInsightEmptyStateView() {
        // GIVEN: No accounts and transactions
        let viewModel = InsightsViewModel(transactions: [], accounts: [], budgets: [])

        // WHEN: The widget is presented
        let view = viewModel.view()

        // THEN: The insight empty state view is displayed
        XCTAssertEqual(view, InsightEmptyStateView())
    }

    // MARK: - Test Case 2: Insight Content View
    func testInsightContentView() {
        // GIVEN: Real test data with specific values
        let transactions = [
            FinancialTransaction(amount: 1000.00),
            FinancialTransaction(amount: -500.00)
        ]
        let accounts = [
            FinancialAccount(name: "Checking", balance: 2000.00),
            FinancialAccount(name: "Savings", balance: 3000.00)
        ]
        let budgets = [
            Budget(name: "Monthly", amount: 5000.00)
        ]

        // WHEN: The widget is presented
        let viewModel = InsightsViewModel(transactions: transactions, accounts: accounts, budgets: budgets)

        // THEN: The insight content view is displayed with correct data
        XCTAssertEqual(viewModel.view(), InsightContentView(totalBalance: 1500.00, recentSpending: -500.00, monthlyChange: 25.0%, monthComparisonRatio: 0.8))
    }

    // MARK: - Test Case 3: Monthly Trend View
    func testMonthlyTrendView() {
        // GIVEN: A positive value for monthly change
        let viewModel = InsightsViewModel(transactions: [], accounts: [], budgets: [])
        let view = viewModel.monthlyTrendView(value: 25.0)

        // THEN: The monthly trend view displays the correct image and text
        XCTAssertEqual(view, HStack(spacing: 4) {
            Image(systemName: "arrow.up.right")
                .foregroundColor(.green)

            Text("25%")
                .font(.subheadline)
                .foregroundColor(.green)
        })
    }

    // MARK: - Test Case 4: Expense Comparison View
    func testExpenseComparisonView() {
        // GIVEN: A positive value for month comparison ratio
        let viewModel = InsightsViewModel(transactions: [], accounts: [], budgets: [])
        let view = viewModel.expenseComparisonView()

        // THEN: The expense comparison view displays the correct text
        XCTAssertEqual(view, HStack(spacing: 4) {
            Text("This month vs last month")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("0.8x")
                .font(.headline)
                .foregroundColor(.accentColor)
        })
    }
}
