import XCTest
@testable import MomentumFinance

class SubscriptionsViewModelTests: XCTestCase {
    var viewModel: SubscriptionsViewModel!
    var mockModelContext: MockModelContext!

    override func setUp() {
        super.setUp()
        mockModelContext = MockModelContext()
        viewModel = SubscriptionsViewModel()
        viewModel.setModelContext(mockModelContext)
    }

    override func tearDown() {
        viewModel = nil
        mockModelContext = nil
        super.tearDown()
    }

    // Test setModelContext method
    func testSetModelContext() {
        let context = ModelContext()
        viewModel.setModelContext(context)

        XCTAssertEqual(viewModel.modelContext, context)
    }

    // Test subscriptionsDueThisWeek method
    func testSubscriptionsDueThisWeek() {
        let subscription1 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(7 * 24 * 60 * 60), billingCycle: .weekly, amount: 10.0)
        let subscription2 = Subscription(id: UUID(), isActive: false, nextDueDate: Date().addingTimeInterval(3 * 24 * 60 * 60), billingCycle: .monthly, amount: 5.0)
        let subscription3 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(10 * 24 * 60 * 60), billingCycle: .yearly, amount: 20.0)

        let subscriptions = [subscription1, subscription2, subscription3]
        let expectedSubscriptions = [subscription1, subscription3]

        XCTAssertEqual(viewModel.subscriptionsDueThisWeek(subscriptions), expectedSubscriptions)
    }

    // Test subscriptionsDueToday method
    func testSubscriptionsDueToday() {
        let subscription1 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(7 * 24 * 60 * 60), billingCycle: .weekly, amount: 10.0)
        let subscription2 = Subscription(id: UUID(), isActive: false, nextDueDate: Date().addingTimeInterval(3 * 24 * 60 * 60), billingCycle: .monthly, amount: 5.0)
        let subscription3 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(10 * 24 * 60 * 60), billingCycle: .yearly, amount: 20.0)

        let subscriptions = [subscription1, subscription2, subscription3]
        let expectedSubscriptions = [subscription1]

        XCTAssertEqual(viewModel.subscriptionsDueToday(subscriptions), expectedSubscriptions)
    }

    // Test overdueSubscriptions method
    func testOverdueSubscriptions() {
        let subscription1 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(7 * 24 * 60 * 60), billingCycle: .weekly, amount: 10.0)
        let subscription2 = Subscription(id: UUID(), isActive: false, nextDueDate: Date().addingTimeInterval(3 * 24 * 60 * 60), billingCycle: .monthly, amount: 5.0)
        let subscription3 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(-1 * 24 * 60 * 60), billingCycle: .yearly, amount: 20.0)

        let subscriptions = [subscription1, subscription2, subscription3]
        let expectedSubscriptions = [subscription3]

        XCTAssertEqual(viewModel.overdueSubscriptions(subscriptions), expectedSubscriptions)
    }

    // Test totalMonthlyAmount method
    func testTotalMonthlyAmount() {
        let subscription1 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(7 * 24 * 60 * 60), billingCycle: .weekly, amount: 10.0)
        let subscription2 = Subscription(id: UUID(), isActive: false, nextDueDate: Date().addingTimeInterval(3 * 24 * 60 * 60), billingCycle: .monthly, amount: 5.0)
        let subscription3 = Subscription(id: UUID(), isActive: true, nextDueDate: Date().addingTimeInterval(-1 * 24 * 60 * 60), billingCycle: .yearly, amount: 20.0)

        let subscriptions = [subscription1, subscription2, subscription3]
        let expectedTotal = 35.0 // (10 + 20) / 4.33

        XCTAssertEqual(viewModel.totalMonthlyAmount(subscriptions), expectedTotal)
    }
