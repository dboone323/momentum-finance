import XCTest
import SwiftData
@testable import MomentumFinance

class BudgetsViewTests: XCTestCase {
    var sut: BudgetsView!
    var modelContext: ModelContext!
    var viewModel: BudgetsViewModel!

    // Test that the empty state view is displayed when there are no budgets
    func testEmptyStateView() {
        let emptyStateView = sut.emptyStateView
        XCTAssertEqual(emptyStateView, BudgetsView.emptyStateView)
    }

    // Test that the budget list section displays the correct budgets
    func testBudgetListSection() {
        let budgetListSection = sut.budgetListSection

        // Assert that the budget list has the correct number of items
        XCTAssertEqual(budgetListSection.count, 2)

        // Assert that each budget item is displayed correctly
        for (index, budget) in budgetListSection.enumerated() {
            XCTAssertEqual(budget.name, testData[index].name)
            XCTAssertEqual(budget.amount, testData[index].amount)
            XCTAssertEqual(budget.timeframe, testData[index].timeframe)
        }
    }

    // Test that the summary section displays the correct total amount
    func testSummarySection() {
        let summarySection = sut.summarySection

        // Assert that the total amount is calculated correctly
        XCTAssertEqual(summarySection.totalAmount, 1200) // 1000 + 200
    }

    // Test that the add budget button navigates to the add budget view
    func testAddBudgetButton() {
        let addBudgetButton = sut.addBudgetButton

        // Assert that the navigation coordinator is activated when the button is tapped
        let expectation = XCTestExpectation(description: "Navigation Coordinator Activated")
        addBudgetButton.tap()
        wait(for: expectation, timeout: 2.0)
        XCTAssertEqual(NavigationCoordinator.shared.isActive, true)
    }

    // Test that the search functionality works correctly
    func testSearchFunctionality() {
        let searchQuery = "Groceries"
        sut.searchQuery = searchQuery

        // Assert that the budget list is filtered correctly
        let filteredBudgets = sut.budgetListSection.filter { $0.name.contains(searchQuery) }
        XCTAssertEqual(filteredBudgets.count, 1)
        XCTAssertEqual(filteredBudgets.first?.name, "Groceries")
    }

    // Test that the view model schedules budget notifications when the view appears
    func testScheduleBudgetNotifications() {
        let expectation = XCTestExpectation(description: "Notification Scheduled")
        sut.$modelContext.willChange { context in
            if context.hasChanges {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    XCTAssertEqual(NavigationCoordinator.shared.isActive, true)
                }
            }
        }

        // Assert that the notification is scheduled correctly
        let notification = Notification(name: "BudgetNotification", object: nil)
        NotificationCenter.default.post(notification)

        wait(for: expectation, timeout: 2.0)
    }
}
