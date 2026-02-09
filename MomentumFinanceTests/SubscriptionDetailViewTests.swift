import SwiftData
import XCTest
@testable import MomentumFinance

class SubscriptionDetailViewTests: XCTestCase {
    var subscriptionViewModel: SubscriptionViewModel!

    // Test the initialization with direct subscription reference
    func testInitializationWithDirectSubscriptionReference() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        XCTAssertEqual(subscriptionViewModel.subscription?.persistentModelID, subscriptionId)
        XCTAssertNil(subscriptionViewModel.subscription?.category)
        XCTAssertNil(subscriptionViewModel.subscription?.account)
    }

    // Test the initialization with subscription ID (for cross-module navigation)
    func testInitializationWithSubscriptionId() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        XCTAssertEqual(subscriptionViewModel.subscription?.persistentModelID, subscriptionId)
        XCTAssertNil(subscriptionViewModel.subscription?.category)
        XCTAssertNil(subscriptionViewModel.subscription?.account)
    }

    // Test the resolvedSubscription property
    func testResolvedSubscription() {
        let mockSubscription = Subscription(
            id: UUID(),
            name: "Monthly Subscription",
            amount: 19.99,
            billingCycle: .monthly,
            isActive: true,
            nextDueDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
            category: nil,
            account: nil,
            notes: "This is a test subscription."
        )
        let mockModelContext = MockModelContext()
        subscriptionViewModel = SubscriptionViewModel(subscription: mockSubscription, modelContext: mockModelContext)

        XCTAssertEqual(
            subscriptionViewModel.resolvedSubscription?.persistentModelID,
            mockSubscription.persistentModelID
        )
    }

    // Test the body view
    func testBodyView() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        // Simulate a payment due soon and overdue status
        subscriptionViewModel.isPaymentDueSoon = true
        subscriptionViewModel.isPaymentOverdue = false

        // Assert the view structure
        XCTAssertEqual(subscriptionViewModel.bodyView().description, "VStack(spacing: 24) { ... }")
    }

    // Test the paymentStatusText method
    func testPaymentStatusText() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        XCTAssertEqual(subscriptionViewModel.paymentStatusText(.active), "Active")
        XCTAssertEqual(subscriptionViewModel.paymentStatusText(.dueSoon), "Due Soon")
        XCTAssertEqual(subscriptionViewModel.paymentStatusText(.overdue), "Overdue")
    }

    // Test the isPaymentDueSoon method
    func testIsPaymentDueSoon() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        XCTAssertEqual(subscriptionViewModel.isPaymentDueSoon(.active), false)
        XCTAssertEqual(subscriptionViewModel.isPaymentDueSoon(.dueSoon), true)
        XCTAssertEqual(subscriptionViewModel.isPaymentDueSoon(.overdue), false)
    }

    // Test the isPaymentOverdue method
    func testIsPaymentOverdue() {
        let subscriptionId = UUID()
        let subscriptionViewModel = SubscriptionViewModel(
            subscriptionId: subscriptionId,
            modelContext: MockModelContext()
        )

        XCTAssertEqual(subscriptionViewModel.isPaymentOverdue(.active), false)
        XCTAssertEqual(subscriptionViewModel.isPaymentOverdue(.dueSoon), false)
        XCTAssertEqual(subscriptionViewModel.isPaymentOverdue(.overdue), true)
    }
}
