import XCTest
@testable import MomentumFinance

class SubscriptionSummaryViewsTests: XCTestCase {
    var viewModel: Features.Subscriptions.EnhancedSubscriptionSummaryViewModel!

    /// Test the header text
    func testHeaderText() {
        XCTAssertEqual(viewModel.headerText, "Subscription Overview")
    }

    /// Test the monthly total
    func testMonthlyTotal() {
        XCTAssertEqual(viewModel.monthlyTotal, 30 * 24 * 60 * 60) // 1 month in seconds
    }

    /// Test the yearly total
    func testYearlyTotal() {
        XCTAssertEqual(viewModel.yearlyTotal, 365 * 24 * 60 * 60) // 1 year in seconds
    }

    /// Test the active subscriptions count
    func testActiveSubscriptionsCount() {
        XCTAssertEqual(viewModel.activeSubscriptionsCount, 1)
    }

    /// Test the next payment information
    func testNextPaymentInformation() {
        if let nextPayment = viewModel.nextPayment {
            XCTAssertEqual(nextPayment.name, "Monthly Plan")
            XCTAssertEqual(nextPayment.nextDueDate, Date().addingTimeInterval(30 * 24 * 60 * 60)) // 1 month in seconds
        } else {
            XCTFail("Expected a next payment but found none.")
        }
    }

    /// Test the body layout
    func testBodyLayout() {
        let view = EnhancedSubscriptionSummaryView(subscriptions: viewModel.subscriptions)
        let snapshot = try? XCTSnapshot().capture(view)

        XCTAssertEqual(snapshot, nil) // This will fail if the snapshot does not match the expected layout
    }
}
