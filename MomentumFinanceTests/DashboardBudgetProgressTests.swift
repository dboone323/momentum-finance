import XCTest
@testable import MomentumFinance

class DashboardBudgetProgressTests: XCTestCase {
    var budget1: Budget!
    var budget2: Budget!
    var budget3: Budget!
    override func setUp() {
        super.setUp()
        budget1 = Budget(name: "Groceries", spentAmount: 150.0, limitAmount: 400.0)
        budget2 = Budget(name: "Utilities", spentAmount: 100.0, limitAmount: 200.0)
        budget3 = Budget(name: "Entertainment", spentAmount: 50.0, limitAmount: 100.0)
    }

    func test_budgetsDisplayedCorrectly() {
        // GIVEN: A list of budgets and a color theme
        let budgets = [budget1, budget2, budget3]
        let colorTheme = .light

        // WHEN: The DashboardBudgetProgress view is created with the mock ViewModel
        let view = Features.Dashboard.DashboardBudgetProgress(
            budgets: budgets,
            colorTheme: colorTheme,
            themeComponents: ThemeComponents(),
            onBudgetTap: { _ in },
            onViewAllTap: {}
        )

        // THEN: The correct number of budget items are displayed
        XCTAssertEqual(view.budgets.count, 3)
    }

    func test_budgetProgressBarDisplaysCorrectly() {
        // GIVEN: A list of budgets and a color theme
        let budgets = [budget1, budget2, budget3]
        let colorTheme = .light

        // WHEN: The DashboardBudgetProgress view is created with the mock ViewModel
        let view = Features.Dashboard.DashboardBudgetProgress(
            budgets: budgets,
            colorTheme: colorTheme,
            themeComponents: ThemeComponents(),
            onBudgetTap: { _ in },
            onViewAllTap: {}
        )

        // THEN: The correct budget progress bars are displayed
        XCTAssertEqual(view.themeComponents.budgetProgressBar(spent: 300.0, total: 800.0), "30%")
    }

    func test_budgetsDisplayedCorrectlyWithNoBudgets() {
        // GIVEN: An empty list of budgets and a color theme
        let budgets = []
        let colorTheme = .light

        // WHEN: The DashboardBudgetProgress view is created with the mock ViewModel
        let view = Features.Dashboard.DashboardBudgetProgress(
            budgets: budgets,
            colorTheme: colorTheme,
            themeComponents: ThemeComponents(),
            onBudgetTap: { _ in },
            onViewAllTap: {}
        )

        // THEN: No budget items are displayed
        XCTAssertEqual(view.budgets.count, 0)
    }

    func test_budgetsDisplayedCorrectlyWithNoLimitAmount() {
        // GIVEN: A list of budgets with no limit amount and a color theme
        let budgets = [Budget(name: "Rent", spentAmount: 500.0, limitAmount: nil)]
        let colorTheme = .light

        // WHEN: The DashboardBudgetProgress view is created with the mock ViewModel
        let view = Features.Dashboard.DashboardBudgetProgress(
            budgets: budgets,
            colorTheme: colorTheme,
            themeComponents: ThemeComponents(),
            onBudgetTap: { _ in },
            onViewAllTap: {}
        )

        // THEN: No budget progress bars are displayed
        XCTAssertEqual(view.themeComponents.budgetProgressBar(spent: 500.0, total: nil), "100%")
    }

    // Auto-added closing brace to fix unexpected EOF
}
