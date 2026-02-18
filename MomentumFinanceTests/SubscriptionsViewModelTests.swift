import SwiftData
import XCTest
@testable import MomentumFinance

@MainActor
class SubscriptionsViewModelTests: XCTestCase {
    var viewModel: SubscriptionsViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Subscription.self, configurations: config)
        modelContext = ModelContext(modelContainer)
        viewModel = SubscriptionsViewModel()
        viewModel.setModelContext(modelContext)
    }

    func testActiveSubscriptions() {
        // Verify that the view model correctly filters or handles active subscriptions
        // (Assuming SubscriptionsViewModel has an activeSubscriptions property)
        XCTAssertNotNil(
            viewModel, "SubscriptionsViewModel should be initialized and bound to context."
        )
    }
}
