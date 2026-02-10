import XCTest
@testable import MomentumFinance

class EnhancedReportsSectionViewsTests: XCTestCase {
    var viewModel: Features.GoalsAndReports.EnhancedReportsSectionViewModel!

    /// Test the header section
    func testHeaderSection() {
        let expectedTitle = "Financial Reports"
        let expectedSubtitle = "Analyze your financial patterns"

        XCTAssertEqual(viewModel.headerTitle, expectedTitle)
        XCTAssertEqual(viewModel.headerSubtitle, expectedSubtitle)
    }

    /// Test the timeframe picker
    func testTimeframePicker() {
        let expectedTimeframes = ["This Week", "This Month", "Last 3 Months", "This Year"]

        for timeframe in expectedTimeframes {
            let button = viewModel.timeframeButton(for: timeframe)
            XCTAssertEqual(button.titleLabel?.text, timeframe)
        }
    }

    /// Test the content section
    func testContentSection() {
        let expectedSummaryCard = EnhancedFinancialSummaryCard(transactions: [], timeframe: .thisMonth)
        let expectedSpendingChart = SpendingByCategoryChart(transactions: [])
        let expectedBudgetPerformanceChart = BudgetPerformanceChart(budgets: [], transactions: [])
        let expectedRecentTransactionsList = RecentTransactionsList(transactions: [])

        XCTAssertEqual(viewModel.contentSection, VStack(spacing: 20) {
            expectedSummaryCard
            expectedSpendingChart
            expectedBudgetPerformanceChart
            expectedRecentTransactionsList
        })
    }

    /// Test the empty state section
    func testEmptyStateSection() {
        let expectedTitle = "No Transactions"
        let expectedSubtitle = "Start by adding some transactions"

        XCTAssertEqual(viewModel.emptyStateTitle, expectedTitle)
        XCTAssertEqual(viewModel.emptyStateSubtitle, expectedSubtitle)
    }
}
