import SwiftData
import XCTest
@testable import MomentumFinance

class DashboardViewTests: XCTestCase {
    var dashboardView: DashboardView!
    var modelContext: ModelContext!

    // Test case for the timeOfDayGreeting property
    func testTimeOfDayGreeting() {
        // GIVEN
        let now = Date()
        let morning = Calendar.current.date(byAdding: .hours, value: 6, to: now)!
        let afternoon = Calendar.current.date(byAdding: .hours, value: 12, to: now)!
        let evening = Calendar.current.date(byAdding: .hours, value: 18, to: now)!

        // WHEN
        let greeting = dashboardView.timeOfDayGreeting(for: morning)
        let afternoonGreeting = dashboardView.timeOfDayGreeting(for: afternoon)
        let eveningGreeting = dashboardView.timeOfDayGreeting(for: evening)

        // THEN
        XCTAssertEqual(greeting, "Good morning!")
        XCTAssertEqual(afternoonGreeting, "Good afternoon!")
        XCTAssertEqual(eveningGreeting, "Good evening!")
    }

    // Test case for the totalBalanceDouble property
    func testTotalBalanceDouble() {
        // GIVEN
        let account1 = FinancialAccount(id: UUID(), name: "Checking", balance: 500.0)
        let account2 = FinancialAccount(id: UUID(), name: "Savings", balance: -300.0)
        self.modelContext.insert(account1, into: &self.modelContext)
        self.modelContext.insert(account2, into: &self.modelContext)

        // WHEN
        let totalBalanceDouble = dashboardView.totalBalanceDouble

        // THEN
        XCTAssertEqual(totalBalanceDouble, 200.0)
    }

    // Test case for the monthlyIncomeDouble property
    func testMonthlyIncomeDouble() {
        // GIVEN
        let income1 = Income(id: UUID(), amount: 500.0, date: Date())
        let income2 = Income(id: UUID(), amount: -300.0, date: Date())
        self.modelContext.insert(income1, into: &self.modelContext)
        self.modelContext.insert(income2, into: &self.modelContext)

        // WHEN
        let monthlyIncomeDouble = dashboardView.monthlyIncomeDouble

        // THEN
        XCTAssertEqual(monthlyIncomeDouble, 200.0)
    }

    // Test case for the monthlyExpensesDouble property
    func testMonthlyExpensesDouble() {
        // GIVEN
        let expense1 = Expense(id: UUID(), amount: 500.0, date: Date())
        let expense2 = Expense(id: UUID(), amount: -300.0, date: Date())
        self.modelContext.insert(expense1, into: &self.modelContext)
        self.modelContext.insert(expense2, into: &self.modelContext)

        // WHEN
        let monthlyExpensesDouble = dashboardView.monthlyExpensesDouble

        // THEN
        XCTAssertEqual(monthlyExpensesDouble, 200.0)
    }

    // Test case for the loadData method
    func testLoadData() {
        // GIVEN
        let account1 = FinancialAccount(id: UUID(), name: "Checking", balance: 500.0)
        let account2 = FinancialAccount(id: UUID(), name: "Savings", balance: -300.0)
        self.modelContext.insert(account1, into: &self.modelContext)
        self.modelContext.insert(account2, into: &self.modelContext)

        // WHEN
        dashboardView.loadData()

        // THEN
        XCTAssertEqual(self.accounts.count, 2)
        XCTAssertEqual(self.subscriptions.count, 0)
        XCTAssertEqual(self.budgets.count, 0)
    }

    // Test case for the accountDetail navigation action
    func testAccountDetailNavigationAction() {
        // GIVEN
        let accountId = UUID()
        let account = FinancialAccount(id: accountId, name: "Checking", balance: 500.0)
        self.modelContext.insert(account, into: &self.modelContext)

        // WHEN
        dashboardView.navigationPath.append(DashboardDestination.accountDetail(accountId))

        // THEN
        XCTAssertEqual(self.dashboardView.navigationPath.count, 2)
    }
}
