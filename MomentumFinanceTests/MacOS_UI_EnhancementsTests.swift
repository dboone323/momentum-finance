import XCTest
@testable import MomentumFinance

class MacOSUIEnhancementsTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testMainWindowExists() {
        XCTAssertTrue(NSApp.mainWindow != nil, "Main window not found")
    }

    /// Test DashboardListView
    func testDashboardListView() {
        let dashboardView = ContentView_macOS().environment(\.modelContext, modelContext)

        // Check if the list view is displayed correctly
        XCTAssertTrue(!dashboardView.accounts.isEmpty, "No accounts found in the dashboard")
        XCTAssertTrue(!dashboardView.recentTransactions.isEmpty, "No recent transactions found in the dashboard")
    }

    /// Test TransactionsListView
    func testTransactionsListView() {
        let transactionsView = ContentView_macOS().environment(\.modelContext, modelContext)

        // Check if the list view is displayed correctly
        XCTAssertTrue(!transactionsView.transactions.isEmpty, "No transactions found in the transactions")
    }

    /// Test Button actions
    func testButtonActions() {
        let dashboardView = ContentView_macOS().environment(\.modelContext, modelContext)

        // Click on the "Add New Account" button
        app.buttons["Add New Account"].tap()

        // Check if the new account is added to the list view
        XCTAssertTrue(!dashboardView.accounts.isEmpty, "New account not added to the dashboard")
    }

    func testRefreshButton() {
        let transactionsView = ContentView_macOS().environment(\.modelContext, modelContext)

        // Click on the "Refresh" button
        app.buttons["Refresh"].tap()

        // Check if the list view is refreshed correctly
        XCTAssertTrue(!transactionsView.transactions.isEmpty, "List view not refreshed")
    }
}
