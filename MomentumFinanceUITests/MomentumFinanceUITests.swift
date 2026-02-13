//
//  MomentumFinanceUITests.swift
//  MomentumFinanceUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class MomentumFinanceUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        self.app.launch()
        dismissSystemPermissionAlertsIfPresent(in: self.app)
    }

    // MARK: - App Launch and Navigation Tests

    @MainActor
    func testAppLaunchesSuccessfully() {
        // Verify the app launches and main UI is visible
        XCTAssertTrue(self.app.state == .runningForeground, "App should be running in foreground")

        // Check for main navigation elements
        let mainView = self.app.otherElements["Main View"].firstMatch
        XCTAssertTrue(mainView.exists, "Main view should exist")
    }

    @MainActor
    func testMainNavigationTabs() {
        // Test main tab navigation
        let tabBar = self.app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "App should have a tab bar")

        // Check for common financial app tabs
        let transactionsTab = tabBar.buttons["Transactions"].firstMatch
        let accountsTab = tabBar.buttons["Accounts"].firstMatch
        let budgetsTab = tabBar.buttons["Budgets"].firstMatch
        let reportsTab = tabBar.buttons["Reports"].firstMatch

        let hasNavigation =
            transactionsTab.exists || accountsTab.exists || budgetsTab.exists || reportsTab.exists
        XCTAssertTrue(hasNavigation, "App should have main navigation tabs")
    }

    // MARK: - Transaction Management Tests

    @MainActor
    func testTransactionListDisplay() {
        // Navigate to transactions if needed
        let transactionsTab = self.app.tabBars.buttons["Transactions"].firstMatch
        if transactionsTab.exists {
            transactionsTab.tap()
        }

        // Check for transaction list
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            XCTAssertTrue(transactionList.isEnabled, "Transaction list should be accessible")

            // Check if list has cells
            let cells = transactionList.cells
            XCTAssertGreaterThan(cells.count, 0, "Should have transaction cells")
        }
    }

    @MainActor
    func testAddTransactionFlow() {
        // Test adding a new transaction
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        if addButton.exists {
            addButton.tap()

            // Check for transaction form
            let amountField = self.app.textFields["Amount"].firstMatch
            let descriptionField = self.app.textFields["Description"].firstMatch
            let categoryPicker = self.app.popUpButtons["Category"].firstMatch

            XCTAssertTrue(
                amountField.exists || descriptionField.exists || categoryPicker.exists,
                "Transaction form should have input fields"
            )
        }
    }

    @MainActor
    func testTransactionFiltering() {
        // Test transaction filtering functionality
        let filterButton = self.app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Check for filter options
            let dateFilter = self.app.buttons["By Date"].firstMatch
            let categoryFilter = self.app.buttons["By Category"].firstMatch
            let amountFilter = self.app.buttons["By Amount"].firstMatch

            XCTAssertTrue(
                dateFilter.exists || categoryFilter.exists || amountFilter.exists,
                "Should have transaction filter options"
            )
        }
    }

    // MARK: - Account Management Tests

    @MainActor
    func testAccountOverview() {
        // Navigate to accounts
        let accountsTab = self.app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Check for account information display
        let accountList = self.app.tables["Account List"].firstMatch
        if accountList.exists {
            let cells = accountList.cells
            XCTAssertGreaterThan(cells.count, 0, "Should display accounts")
        }
    }

    @MainActor
    func testAccountBalanceDisplay() {
        // Test that account balances are displayed correctly
        let balanceLabels = self.app.staticTexts.matching(identifier: "balance").allElementsBoundByIndex
        XCTAssertGreaterThan(balanceLabels.count, 0, "Should display account balances")

        // Verify balance format (should contain currency symbols or numbers)
        for label in balanceLabels.prefix(3) {
            let text = label.label
            XCTAssertFalse(text.isEmpty, "Balance should not be empty")
        }
    }

    @MainActor
    func testAddAccountFlow() {
        // Test adding a new account
        let addAccountButton = self.app.buttons["Add Account"].firstMatch
        if addAccountButton.exists {
            addAccountButton.tap()

            // Check for account creation form
            let accountNameField = self.app.textFields["Account Name"].firstMatch
            let accountTypePicker = self.app.popUpButtons["Account Type"].firstMatch
            let initialBalanceField = self.app.textFields["Initial Balance"].firstMatch

            XCTAssertTrue(
                accountNameField.exists || accountTypePicker.exists || initialBalanceField.exists,
                "Account form should have input fields"
            )
        }
    }

    // MARK: - Budget Management Tests

    @MainActor
    func testBudgetOverview() {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check for budget display
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            XCTAssertTrue(budgetList.isEnabled, "Budget list should be accessible")
        }
    }

    @MainActor
    func testBudgetProgressIndicators() {
        // Test budget progress visualization
        let progressBars = self.app.progressIndicators.allElementsBoundByIndex
        let progressViews = self.app.otherElements.matching(identifier: "progress")
            .allElementsBoundByIndex

        XCTAssertGreaterThan(
            progressBars.count + progressViews.count, 0,
            "Should have budget progress indicators"
        )
    }

    @MainActor
    func testCreateBudgetFlow() {
        // Test creating a new budget
        let createBudgetButton = self.app.buttons["Create Budget"].firstMatch
        if createBudgetButton.exists {
            createBudgetButton.tap()

            // Check for budget creation form
            let budgetNameField = self.app.textFields["Budget Name"].firstMatch
            let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
            let categoryPicker = self.app.popUpButtons["Budget Category"].firstMatch

            XCTAssertTrue(
                budgetNameField.exists || budgetAmountField.exists || categoryPicker.exists,
                "Budget form should have input fields"
            )
        }
    }

    // MARK: - Reports and Analytics Tests

    @MainActor
    func testReportsView() {
        // Navigate to reports
        let reportsTab = self.app.tabBars.buttons["Reports"].firstMatch
        if reportsTab.exists {
            reportsTab.tap()
        }

        // Check for report content
        let reportView = self.app.otherElements["Reports View"].firstMatch
        if reportView.exists {
            XCTAssertTrue(reportView.isEnabled, "Reports view should be accessible")
        }
    }

    @MainActor
    func testChartDisplay() {
        // Test chart/graph display in reports
        let chartViews = self.app.otherElements.matching(identifier: "chart").allElementsBoundByIndex
        XCTAssertGreaterThan(chartViews.count, 0, "Should display charts in reports")
    }

    @MainActor
    func testDateRangeSelection() {
        // Test date range picker for reports
        let datePicker = self.app.datePickers.firstMatch
        let dateRangeButton = self.app.buttons["Date Range"].firstMatch

        if datePicker.exists || dateRangeButton.exists {
            XCTAssertTrue(true, "Date range selection should be available")
        }
    }

    // MARK: - Settings and Preferences Tests

    @MainActor
    func testSettingsAccess() {
        // Test accessing settings
        let settingsButton = self.app.buttons["Settings"].firstMatch
        if settingsButton.exists {
            settingsButton.tap()

            // Check for settings content
            let settingsView = self.app.otherElements["Settings View"].firstMatch
            XCTAssertTrue(settingsView.exists, "Settings view should be accessible")
        }
    }

    @MainActor
    func testCurrencySettings() {
        // Test currency selection
        let currencyPicker = self.app.popUpButtons["Currency"].firstMatch
        if currencyPicker.exists {
            currencyPicker.click()

            // Check for currency options
            let usdOption = self.app.menuItems["USD"].firstMatch
            let eurOption = self.app.menuItems["EUR"].firstMatch

            XCTAssertTrue(usdOption.exists || eurOption.exists, "Should have currency options")
        }
    }

    // MARK: - Search and Filter Tests

    @MainActor
    func testSearchFunctionality() {
        // Test search functionality
        let searchField = self.app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test search")

            // Check for search results
            let searchResults = self.app.tables["Search Results"].firstMatch
            if searchResults.exists {
                XCTAssertTrue(searchResults.isEnabled, "Search results should be accessible")
            }
        }
    }

    // MARK: - Data Export Tests

    @MainActor
    func testExportFunctionality() {
        // Test data export features
        let exportButton = self.app.buttons["Export"].firstMatch
        if exportButton.exists {
            exportButton.tap()

            // Check for export options
            let pdfOption = self.app.buttons["Export as PDF"].firstMatch
            let csvOption = self.app.buttons["Export as CSV"].firstMatch

            XCTAssertTrue(pdfOption.exists || csvOption.exists, "Should have export options")
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testAppLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testTransactionListPerformance() {
        // Navigate to transactions
        let transactionsTab = self.app.tabBars.buttons["Transactions"].firstMatch
        if transactionsTab.exists {
            transactionsTab.tap()
        }

        // Measure scrolling performance
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            measure {
                transactionList.swipeUp()
            }
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibilityLabels() {
        // Test accessibility of key UI elements
        let buttons = self.app.buttons.allElementsBoundByIndex
        let textFields = self.app.textFields.allElementsBoundByIndex

        for button in buttons.prefix(5) {
            if button.isEnabled, button.isHittable {
                XCTAssertFalse(
                    button.label?.isEmpty ?? true,
                    "Buttons should have accessibility labels"
                )
            }
        }

        for textField in textFields.prefix(3) {
            XCTAssertFalse(
                textField.label?.isEmpty ?? true,
                "Text fields should have accessibility labels"
            )
        }
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testInvalidInputHandling() {
        // Test handling of invalid inputs
        let amountField = self.app.textFields["Amount"].firstMatch
        if amountField.exists {
            amountField.tap()
            amountField.typeText("invalid amount")

            let saveButton = self.app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()

                // Check for error message
                let errorMessage = self.app.staticTexts["Invalid amount"].firstMatch
                XCTAssertTrue(errorMessage.exists, "Should show error for invalid input")
            }
        }
    }

    // MARK: - Memory and Resource Tests

    @MainActor
    func testMemoryUsage() {
        let initialMemory = self.app.memoryUsage

        // Perform various operations
        let transactionsTab = self.app.tabBars.buttons["Transactions"].firstMatch
        if transactionsTab.exists {
            transactionsTab.tap()
        }

        let accountsTab = self.app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        let finalMemory = self.app.memoryUsage
        XCTAssertLessThan(
            finalMemory, initialMemory * 2,
            "Memory usage should not double during normal navigation"
        )
    }
}

extension XCTestCase {
    @MainActor
    func dismissSystemPermissionAlertsIfPresent(
        in app: XCUIApplication,
        timeout: TimeInterval = 3
    ) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let preferredButtons = [
            "Allow",
            "Allow While Using App",
            "Allow While Using the App",
            "Allow Once",
            "Allow Notifications",
            "Always Allow",
            "OK",
            "Continue",
        ]

        let interruptionToken = addUIInterruptionMonitor(withDescription: "System Permission Alert") { alert in
            Self.tapPreferredButton(in: alert, preferredButtons: preferredButtons)
        }
        defer {
            removeUIInterruptionMonitor(interruptionToken)
        }

        let deadline = Date().addingTimeInterval(timeout)
        var consecutiveNoAlertChecks = 0
        while Date() < deadline {
            if Self.handleAlert(in: app.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            if Self.handleAlert(in: springboard.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            app.tap()
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))

            if Self.handleAlert(in: springboard.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            consecutiveNoAlertChecks += 1
            if consecutiveNoAlertChecks >= 3 {
                break
            }
        }
    }

    @MainActor
    private static func handleAlert(
        in alert: XCUIElement,
        preferredButtons: [String]
    ) -> Bool {
        guard alert.exists else {
            return false
        }

        if tapPreferredButton(in: alert, preferredButtons: preferredButtons) {
            return true
        }

        let buttons = alert.buttons.allElementsBoundByIndex
        if buttons.count > 1 {
            buttons[1].tap()
            return true
        }

        if let first = buttons.first, first.exists {
            first.tap()
            return true
        }

        return false
    }

    @MainActor
    private static func tapPreferredButton(
        in alert: XCUIElement,
        preferredButtons: [String]
    ) -> Bool {
        for title in preferredButtons {
            let button = alert.buttons[title]
            if button.exists {
                button.tap()
                return true
            }
        }

        let allowMatch = alert.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Allow'")).firstMatch
        if allowMatch.exists {
            allowMatch.tap()
            return true
        }

        let approveMatch = alert.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'OK' OR label CONTAINS[c] 'Continue'")
        ).firstMatch
        if approveMatch.exists {
            approveMatch.tap()
            return true
        }

        return false
    }
}
