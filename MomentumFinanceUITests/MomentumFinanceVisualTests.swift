//
//  MomentumFinanceVisualTests.swift
//  MomentumFinanceUITests
//
//  Visual regression testing with screenshot capture for all major views
//

import XCTest

final class MomentumFinanceVisualTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to fully load
        sleep(2)
    }
    
    // MARK: - Helper Functions
    
    /// Captures a screenshot with a descriptive name
    private func captureScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Safely tap a tab bar button if it exists
    private func tapTab(_ tabName: String) -> Bool {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let tab = tabBar.buttons[tabName].firstMatch
            if tab.exists {
                tab.tap()
                sleep(1)
                return true
            }
        }
        return false
    }
    
    /// Safely tap a navigation button
    private func tapButton(_ buttonName: String) -> Bool {
        let button = app.buttons[buttonName].firstMatch
        if button.exists && button.isHittable {
            button.tap()
            sleep(1)
            return true
        }
        return false
    }
    
    // MARK: - Main Tab Screenshots
    
    @MainActor
    func testAllMainTabsScreenshots() throws {
        // Capture initial launch state (likely Dashboard)
        captureScreenshot(named: "01_Launch_Dashboard")
        
        // Capture each main tab
        let tabs = ["Transactions", "Accounts", "Budgets", "Reports", "Dashboard"]
        
        for (index, tabName) in tabs.enumerated() {
            if tapTab(tabName) {
                captureScreenshot(named: String(format: "Tab%02d_%@", index + 1, tabName))
            }
        }
    }
    
    // MARK: - Dashboard View Screenshots
    
    @MainActor
    func testDashboardScreenshots() throws {
        // Navigate to Dashboard
        _ = tapTab("Dashboard")
        captureScreenshot(named: "Dashboard_Main")
        
        // Scroll to see more content
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            sleep(1)
            captureScreenshot(named: "Dashboard_Scrolled")
        }
        
        // Check for insights section
        let insightsSection = app.staticTexts["Insights"].firstMatch
        if insightsSection.exists {
            captureScreenshot(named: "Dashboard_WithInsights")
        }
    }
    
    // MARK: - Transactions View Screenshots
    
    @MainActor
    func testTransactionsScreenshots() throws {
        // Navigate to Transactions
        if tapTab("Transactions") {
            captureScreenshot(named: "Transactions_Main")
            
            // Test empty state if visible
            let emptyState = app.staticTexts.matching(identifier: "EmptyState").firstMatch
            if emptyState.exists {
                captureScreenshot(named: "Transactions_EmptyState")
            }
            
            // Scroll the list
            let transactionList = app.tables.firstMatch
            if transactionList.exists {
                transactionList.swipeUp()
                sleep(1)
                captureScreenshot(named: "Transactions_Scrolled")
            }
        }
    }
    
    @MainActor
    func testAddTransactionFlowScreenshots() throws {
        // Navigate to Transactions
        _ = tapTab("Transactions")
        
        // Try to open Add Transaction sheet
        if tapButton("Add Transaction") || tapButton("add") || tapButton("+") {
            sleep(1)
            captureScreenshot(named: "AddTransaction_Sheet")
            
            // Check for form fields
            let amountField = app.textFields["Amount"].firstMatch
            if amountField.exists {
                captureScreenshot(named: "AddTransaction_Form")
            }
            
            // Dismiss the sheet
            tapButton("Cancel")
        }
    }
    
    // MARK: - Accounts View Screenshots
    
    @MainActor
    func testAccountsScreenshots() throws {
        // Navigate to Accounts
        if tapTab("Accounts") {
            captureScreenshot(named: "Accounts_Main")
            
            // Scroll to see more accounts
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Accounts_Scrolled")
            }
            
            // Try to tap on first account for detail view
            let accountCells = app.cells.allElementsBoundByIndex
            if accountCells.isNotEmpty, accountCells.count > 0 {
                accountCells[0].tap()
                sleep(1)
                captureScreenshot(named: "Account_Detail")
            }
        }
    }
    
    // MARK: - Budgets View Screenshots
    
    @MainActor
    func testBudgetsScreenshots() throws {
        // Navigate to Budgets
        if tapTab("Budgets") {
            captureScreenshot(named: "Budgets_Main")
            
            // Check for progress indicators
            let progressBars = app.progressIndicators.allElementsBoundByIndex
            if progressBars.count > 0 {
                captureScreenshot(named: "Budgets_WithProgress")
            }
            
            // Scroll to see more budgets
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Budgets_Scrolled")
            }
        }
    }
    
    // MARK: - Reports View Screenshots
    
    @MainActor
    func testReportsScreenshots() throws {
        // Navigate to Reports
        if tapTab("Reports") {
            captureScreenshot(named: "Reports_Main")
            
            // Check for charts
            let chartViews = app.otherElements.matching(identifier: "chart").allElementsBoundByIndex
            if chartViews.count > 0 {
                captureScreenshot(named: "Reports_WithCharts")
            }
            
            // Scroll for more reports
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Reports_Scrolled")
            }
        }
    }
    
    // MARK: - Settings View Screenshots
    
    @MainActor
    func testSettingsScreenshots() throws {
        // Try to find and tap Settings button (often in navigation bar)
        let settingsButton = app.buttons["Settings"].firstMatch
        let gearButton = app.buttons["gear"].firstMatch
        
        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
            captureScreenshot(named: "Settings_Main")
            
            // Scroll settings
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Settings_Scrolled")
            }
        } else if gearButton.exists {
            gearButton.tap()
            sleep(1)
            captureScreenshot(named: "Settings_Main")
        }
    }
    
    // MARK: - Subscriptions View Screenshots
    
    @MainActor
    func testSubscriptionsScreenshots() throws {
        // Try different navigation paths to Subscriptions
        if tapTab("Subscriptions") || tapButton("Subscriptions") {
            captureScreenshot(named: "Subscriptions_Main")
            
            // Scroll to see more subscriptions
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Subscriptions_Scrolled")
            }
        }
    }
    
    // MARK: - Goals View Screenshots
    
    @MainActor
    func testGoalsScreenshots() throws {
        // Try different navigation paths to Goals
        if tapTab("Goals") || tapButton("Goals") {
            captureScreenshot(named: "Goals_Main")
            
            // Check for savings goals
            let savingsGoals = app.staticTexts["Savings Goals"].firstMatch
            if savingsGoals.exists {
                captureScreenshot(named: "Goals_SavingsSection")
            }
            
            // Scroll for more content
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                captureScreenshot(named: "Goals_Scrolled")
            }
        }
    }
    
    // MARK: - Search Functionality Screenshots
    
    @MainActor
    func testSearchScreenshots() throws {
        // Find and tap search
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            sleep(1)
            captureScreenshot(named: "Search_Active")
            
            // Type a search query
            searchField.typeText("Coffee")
            sleep(1)
            captureScreenshot(named: "Search_WithQuery")
            
            // Clear search
            let clearButton = app.buttons["Clear text"].firstMatch
            if clearButton.exists {
                clearButton.tap()
            }
        }
    }
    
    // MARK: - Empty States Screenshots
    
    @MainActor
    func testEmptyStatesScreenshots() throws {
        // Navigate through tabs looking for empty states
        let tabsToCheck = ["Transactions", "Budgets", "Goals", "Subscriptions"]
        
        for tabName in tabsToCheck {
            if tapTab(tabName) {
                // Check for empty state indicators
                let emptyLabels = app.staticTexts.matching(
                    NSPredicate(format: "label CONTAINS[c] 'no' OR label CONTAINS[c] 'empty' OR label CONTAINS[c] 'add your first'")
                ).allElementsBoundByIndex
                
                if emptyLabels.count > 0 {
                    captureScreenshot(named: "\(tabName)_EmptyState")
                }
            }
        }
    }
    
    // MARK: - Full App Tour Screenshots
    
    @MainActor
    func testFullAppScreenshotTour() throws {
        // Comprehensive tour of the entire app
        
        // 1. Launch/Dashboard
        captureScreenshot(named: "Tour_01_Launch")
        
        // 2. Dashboard
        if tapTab("Dashboard") {
            captureScreenshot(named: "Tour_02_Dashboard")
        }
        
        // 3. Transactions
        if tapTab("Transactions") {
            captureScreenshot(named: "Tour_03_Transactions")
        }
        
        // 4. Accounts
        if tapTab("Accounts") {
            captureScreenshot(named: "Tour_04_Accounts")
        }
        
        // 5. Budgets
        if tapTab("Budgets") {
            captureScreenshot(named: "Tour_05_Budgets")
        }
        
        // 6. Reports
        if tapTab("Reports") {
            captureScreenshot(named: "Tour_06_Reports")
        }
        
        // Return to start
        _ = tapTab("Dashboard")
        captureScreenshot(named: "Tour_07_ReturnToDashboard")
    }
    
    // MARK: - Accessibility Verification
    
    @MainActor
    func testAccessibilityLabelsExist() throws {
        // Verify key elements have accessibility labels
        captureScreenshot(named: "Accessibility_Verification")
        
        // Check buttons
        let buttons = app.buttons.allElementsBoundByIndex
        var labeledButtonCount = 0
        for button in buttons.prefix(10) {
            if button.isHittable && !(button.label.isEmpty) {
                labeledButtonCount += 1
            }
        }
        XCTAssertGreaterThan(labeledButtonCount, 0, "Should have buttons with accessibility labels")
        
        // Check tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
    }
    
    // MARK: - Theme Screenshots (Light/Dark)
    
    @MainActor
    func testThemeAppearance() throws {
        // Capture current appearance (depends on system settings)
        captureScreenshot(named: "Theme_CurrentAppearance")
        
        // If there's a theme toggle in the app, use it
        if tapButton("Settings") || tapButton("gear") {
            let darkModeToggle = app.switches["Dark Mode"].firstMatch
            if darkModeToggle.exists {
                captureScreenshot(named: "Theme_Settings")
            }
        }
    }
}

// Extension for array isEmpty check
extension Sequence {
    var isNotEmpty: Bool {
        return !Array(self).isEmpty
    }
}
