import XCTest
@testable import MomentumFinance

class MacOS_UI_EnhancementsTests: XCTestCase {
    var app: App!
    
    override func setUp() {
        super.setUp()
        app = Application()
        continueAfterFailure = false
        
        // Launch the app and wait for it to load
        app.launch()
        
        // Wait for the main window to appear
        let mainWindow = app.windows.first(where: { $0.staticText.contains("Dashboard") })
        XCTAssertTrue(mainWindow != nil, "Main window not found")
    }
    
    override func tearDown() {
        super.tearDown()
        app.terminate()
    }
    
    // Test DashboardListView
    func testDashboardListView() {
        let dashboardView = ContentView_macOS().environment(\.modelContext, modelContext)
        
        // Check if the list view is displayed correctly
        XCTAssertTrue(dashboardView.accounts.count > 0, "No accounts found in the dashboard")
        XCTAssertTrue(dashboardView.recentTransactions.count > 0, "No recent transactions found in the dashboard")
    }
    
    // Test TransactionsListView
    func testTransactionsListView() {
        let transactionsView = ContentView_macOS().environment(\.modelContext, modelContext)
        
        // Check if the list view is displayed correctly
        XCTAssertTrue(transactionsView.transactions.count > 0, "No transactions found in the transactions")
    }
    
    // Test Button actions
    func testButtonActions() {
        let dashboardView = ContentView_macOS().environment(\.modelContext, modelContext)
        
        // Click on the "Add New Account" button
        app.buttons["Add New Account"].tap()
        
        // Check if the new account is added to the list view
        XCTAssertTrue(dashboardView.accounts.count > 0, "New account not added to the dashboard")
    }
    
    func testRefreshButton() {
        let transactionsView = ContentView_macOS().environment(\.modelContext, modelContext)
        
        // Click on the "Refresh" button
        app.buttons["Refresh"].tap()
        
        // Check if the list view is refreshed correctly
        XCTAssertTrue(transactionsView.transactions.count > 0, "List view not refreshed")
    }
}
