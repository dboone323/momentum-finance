import XCTest
@testable import MomentumFinance

class EnhancedContentViewMacOSTests: XCTestCase {
    var contentView: ContentView_macOS!

    /// Test sidebar item functionality
    func testSidebarItem() {
        let sidebarItems = [
            SidebarItem(title: "Dashboard", icon: "house", item: .dashboard),
            SidebarItem(title: "Transactions", icon: "creditcard", item: .transactions),
            SidebarItem(title: "Budgets", icon: "chart.pie", item: .budgets),
        ]

        for item in sidebarItems {
            contentView.sidebarItem(title: item.title, icon: item.icon, item: item.item)
            XCTAssertEqual(contentView.selectedSidebarItem, item.item)
        }
    }

    /// Test navigation coordinator functionality
    func testNavigationCoordinator() {
        let expectedState = NavigationSplitViewVisibility.all
        XCTAssertEqual(contentView.columnVisibility, expectedState)

        contentView.toggleSidebar()
        XCTAssertEqual(contentView.columnVisibility, !expectedState)
    }

    /// Test list view functionality
    func testListView() {
        let listItem = ListableItem(type: .account, id: "123")
        contentView.selectedListItem = listItem

        XCTAssertEqual(contentView.selectedSidebarItem, .transactions)

        if let listView = contentView.detail as? Features.Transactions.AccountDetailView {
            XCTAssertEqual(listView.accountId, "123")
        }
    }

    /// Test detail view functionality
    func testDetailView() {
        let listItem = ListableItem(type: .transaction, id: "456")
        contentView.selectedListItem = listItem

        if let listView = contentView.detail as? Features.Transactions.TransactionDetailView {
            XCTAssertEqual(listView.transactionId, "456")
        }
    }

    /// Test budget view functionality
    func testBudgetView() {
        let listItem = ListableItem(type: .budget, id: "789")
        contentView.selectedListItem = listItem

        if let listView = contentView.detail as? Features.Budgets.BudgetDetailView {
            XCTAssertEqual(listView.budgetId, "789")
        }
    }

    /// Test subscription view functionality
    func testSubscriptionView() {
        let listItem = ListableItem(type: .subscription, id: "101")
        contentView.selectedListItem = listItem

        if let listView = contentView.detail as? Features.Subscriptions.SubscriptionDetailView {
            XCTAssertEqual(listView.subscriptionId, "101")
        }
    }

    /// Test goal view functionality
    func testGoalView() {
        let listItem = ListableItem(type: .goal, id: "202")
        contentView.selectedListItem = listItem

        if let listView = contentView.detail as? Features.GoalsAndReports.SavingsGoalDetailView {
            XCTAssertEqual(listView.goalId, "202")
        }
    }

    /// Test report view functionality
    func testReportView() {
        let listItem = ListableItem(type: .report, id: "303")
        contentView.selectedListItem = listItem

        if let listView = contentView.detail as? Features.GoalsAndReports.ReportDetailView {
            XCTAssertEqual(listView.reportType, "spending")
        }
    }

    /// Test default view functionality
    func testDefaultView() {
        let expectedState = NavigationSplitViewVisibility.all
        XCTAssertEqual(contentView.columnVisibility, expectedState)

        if let listView = contentView.detail as? Features.Dashboard.DashboardView {
            XCTAssertEqual(listView.accountId, nil)
        }
    }
}
