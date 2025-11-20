@testable import MomentumFinance
import XCTest

class DashboardComponentsTests: XCTestCase {
    var subscriptions: [Subscription]!
    var accounts: [FinancialAccount]!
    var budgets: [Budget]!

    // Test DashboardSubscriptionsSection
    func testDashboardSubscriptionsSection() {
        let view = DashboardSubscriptionsSection(
            subscriptions: subscriptions,
            onSubscriptionTapped: { _ in },
            onViewAllTapped: {},
            onAddTapped: {}
        )

        // GIVEN
        let expectedTexts = ["Subscriptions", "View All", "Monthly Subscription", "Yearly Subscription", "Biannual Subscription"]
        var actualTexts = [String]()

        // WHEN
        for subview in view.subviews {
            if let label = subview as? UILabel {
                actualTexts.append(label.text ?? "")
            }
        }

        // THEN
        XCTAssertEqual(actualTexts, expectedTexts)
    }

    // Test DashboardAccountsSummary
    func testDashboardAccountsSummary() {
        let view = DashboardAccountsSummary(
            accounts: accounts,
            onAccountTap: { _ in },
            onViewAllTap: {}
        )

        // GIVEN
        let expectedTexts = ["Accounts", "View All", "Checking Account", "Savings Account"]
        var actualTexts = [String]()

        // WHEN
        for subview in view.subviews {
            if let label = subview as? UILabel {
                actualTexts.append(label.text ?? "")
            }
        }

        // THEN
        XCTAssertEqual(actualTexts, expectedTexts)
    }

    // Test DashboardBudgetProgress
    func testDashboardBudgetProgress() {
        let view = DashboardBudgetProgress(
            budgets: budgets,
            onBudgetTap: { _ in },
            onViewAllTap: {}
        )

        // GIVEN
        let expectedTexts = ["Budgets", "View All", "Monthly Budget", "Annual Budget"]
        var actualTexts = [String]()

        // WHEN
        for subview in view.subviews {
            if let label = subview as? UILabel {
                actualTexts.append(label.text ?? "")
            }
        }

        // THEN
        XCTAssertEqual(actualTexts, expectedTexts)
    }
}
