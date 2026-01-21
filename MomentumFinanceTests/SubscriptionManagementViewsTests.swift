@testable import MomentumFinance
import XCTest

class SubscriptionManagementViewsTests: XCTestCase {
    var subscriptionViewModel: SubscriptionViewModel!

    // Test the AddSubscriptionView's name field
    func testAddSubscriptionViewNameField() {
        // GIVEN
        let expectedName = "Groceries"
        subscriptionViewModel.name = expectedName

        // WHEN
        let actualName = subscriptionViewModel.name

        // THEN
        XCTAssertEqual(actualName, expectedName)
    }

    // Test the AddSubscriptionView's amount field
    func testAddSubscriptionViewAmountField() {
        // GIVEN
        let expectedAmount = "100.00"
        subscriptionViewModel.amount = expectedAmount

        // WHEN
        let actualAmount = subscriptionViewModel.amount

        // THEN
        XCTAssertEqual(actualAmount, expectedAmount)
    }

    // Test the AddSubscriptionView's frequency field
    func testAddSubscriptionViewFrequencyField() {
        // GIVEN
        let expectedFrequency = BillingCycle.monthly
        subscriptionViewModel.frequency = expectedFrequency

        // WHEN
        let actualFrequency = subscriptionViewModel.frequency

        // THEN
        XCTAssertEqual(actualFrequency, expectedFrequency)
    }

    // Test the AddSubscriptionView's nextDueDate field
    func testAddSubscriptionViewNextDueDateField() {
        // GIVEN
        let expectedNextDueDate = Date()
        subscriptionViewModel.nextDueDate = expectedNextDueDate

        // WHEN
        let actualNextDueDate = subscriptionViewModel.nextDueDate

        // THEN
        XCTAssertEqual(actualNextDueDate, expectedNextDueDate)
    }

    // Test the AddSubscriptionView's selectedCategory field
    func testAddSubscriptionViewSelectedCategoryField() {
        // GIVEN
        let expectedCategory = ExpenseCategory(name: "Groceries", isActive: true)
        subscriptionViewModel.selectedCategory = expectedCategory

        // WHEN
        let actualCategory = subscriptionViewModel.selectedCategory

        // THEN
        XCTAssertEqual(actualCategory, expectedCategory)
    }

    // Test the AddSubscriptionView's selectedAccount field
    func testAddSubscriptionViewSelectedAccountField() {
        // GIVEN
        let expectedAccount = FinancialAccount(name: "Checking Account", isActive: true)
        subscriptionViewModel.selectedAccount = expectedAccount

        // WHEN
        let actualAccount = subscriptionViewModel.selectedAccount

        // THEN
        XCTAssertEqual(actualAccount, expectedAccount)
    }

    // Test the AddSubscriptionView's notes field
    func testAddSubscriptionViewNotesField() {
        // GIVEN
        let expectedNotes = "Monthly groceries"
        subscriptionViewModel.notes = expectedNotes

        // WHEN
        let actualNotes = subscriptionViewModel.notes

        // THEN
        XCTAssertEqual(actualNotes, expectedNotes)
    }

    // Test the AddSubscriptionView's isActive field
    func testAddSubscriptionViewIsActiveField() {
        // GIVEN
        let expectedActive = true
        subscriptionViewModel.isActive = expectedActive

        // WHEN
        let actualActive = subscriptionViewModel.isActive

        // THEN
        XCTAssertEqual(actualActive, expectedActive)
    }

    // Test the AddSubscriptionView's isValidForm property
    func testAddSubscriptionViewIsValidFormProperty() {
        // GIVEN
        let expectedName = "Groceries"
        let expectedAmount = "100.00"
        let expectedFrequency = BillingCycle.monthly
        let expectedNextDueDate = Date()
        let expectedCategory = ExpenseCategory(name: "Groceries", isActive: true)
        let expectedAccount = FinancialAccount(name: "Checking Account", isActive: true)
        subscriptionViewModel.name = expectedName
        subscriptionViewModel.amount = expectedAmount
        subscriptionViewModel.frequency = expectedFrequency
        subscriptionViewModel.nextDueDate = expectedNextDueDate
        subscriptionViewModel.selectedCategory = expectedCategory
        subscriptionViewModel.selectedAccount = expectedAccount

        // WHEN
        let actualIsValidForm = subscriptionViewModel.isValidForm

        // THEN
        XCTAssertTrue(actualIsValidForm)
    }
}
