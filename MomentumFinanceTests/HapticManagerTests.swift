import XCTest
@testable import MomentumFinance

class HapticManagerTests: XCTestCase {
    var hapticManager: HapticManager!

    override func setUp() {
        super.setUp()
        hapticManager = HapticManager.shared
    }

    override func tearDown() {
        super.tearDown()
        hapticManager.isEnabled = true // Reset to default state after tests
    }

    // MARK: - Impact Feedback

    func testImpactLight() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.light

        // WHEN
        hapticManager.impact(style)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.impactFeedbackGenerator.state, .ready)
    }

    func testImpactMedium() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.medium

        // WHEN
        hapticManager.impact(style)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.impactFeedbackGenerator.state, .ready)
    }

    func testImpactHeavy() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.heavy

        // WHEN
        hapticManager.impact(style)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.impactFeedbackGenerator.state, .ready)
    }

    // MARK: - Notification Feedback

    func testSuccess() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.success

        // WHEN
        hapticManager.success()

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.notificationFeedbackGenerator.state, .ready)
    }

    func testWarning() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.warning

        // WHEN
        hapticManager.warning()

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.notificationFeedbackGenerator.state, .ready)
    }

    func testError() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.error

        // WHEN
        hapticManager.error()

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.notificationFeedbackGenerator.state, .ready)
    }

    // MARK: - Selection Feedback

    func testSelection() {
        // GIVEN
        let style = UIImpactFeedbackGenerator.FeedbackStyle.selection

        // WHEN
        hapticManager.selection()

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.selectionFeedbackGenerator.state, .ready)
    }

    // MARK: - Context-Specific Feedback

    func testTransactionFeedbackIncome() {
        // GIVEN
        let transactionType = TransactionType.income

        // WHEN
        hapticManager.transactionFeedback(for: transactionType)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.notificationFeedbackGenerator.state, .ready)
    }

    func testTransactionFeedbackExpense() {
        // GIVEN
        let transactionType = TransactionType.expense

        // WHEN
        hapticManager.transactionFeedback(for: transactionType)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.impactFeedbackGenerator.state, .ready)
    }

    func testTransactionFeedbackTransfer() {
        // GIVEN
        let transactionType = TransactionType.transfer

        // WHEN
        hapticManager.transactionFeedback(for: transactionType)

        // THEN
        XCTAssertTrue(hapticManager.isEnabled)
        XCTAssertEqual(hapticManager.impactFeedbackGenerator.state, .ready)
    }
}
