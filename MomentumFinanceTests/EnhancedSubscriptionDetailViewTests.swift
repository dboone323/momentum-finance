import XCTest
@testable import MomentumFinance

class EnhancedSubscriptionDetailViewTests: XCTestCase {
    var subscriptionId: String = "12345"
    var subscription: Subscription?
    var relatedTransactions: [FinancialTransaction] = []

    func testSubscriptionName() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertEqual(view.title, "Test Subscription")
    }

    func testTimeSpanPicker() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertEqual(view.selectedTimespan.rawValue, "6 Months")
    }

    func testEditButton() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertTrue(view.isEditing)
    }

    func testMarkAsPaid() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        // Simulate payment action
        view.markAsPaid()
        XCTAssertEqual(view.subscription?.status, .paid)
    }

    func testSkipNextPayment() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        // Simulate skip next payment action
        view.skipNextPayment()
        XCTAssertEqual(view.subscription?.status, .active)
    }

    func testPauseSubscription() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        // Simulate pause subscription action
        view.pauseSubscription()
        XCTAssertEqual(view.subscription?.status, .paused)
    }

    func testCancelSubscriptionFlow() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertTrue(view.showingCancelFlow)
    }

    func testShoppingAlternativesFlow() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertTrue(view.showingShoppingAlternatives)
    }

    func testExportAsPDF() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        // Simulate export as PDF action
        view.exportAsPDF()
        XCTAssertEqual(view.isEditing, false)
    }

    func testPrintSubscription() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        // Simulate print subscription action
        view.printSubscription()
        XCTAssertEqual(view.isEditing, false)
    }

    func testDeleteConfirmation() {
        let view = EnhancedSubscriptionDetailView(subscriptionId: subscriptionId)
        XCTAssertTrue(view.showingDeleteConfirmation)
    }
}
