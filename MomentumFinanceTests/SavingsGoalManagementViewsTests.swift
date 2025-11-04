import XCTest
@testable import MomentumFinance

class SavingsGoalManagementViewsTests: XCTestCase {
    // Test the AddSavingsGoalView
    func testAddSavingsGoalView() {
        // GIVEN
        let viewModel = AddSavingsGoalViewModel()
        let view = AddSavingsGoalView(viewModel: viewModel)

        // WHEN
        // Simulate user input and actions

        // THEN
        XCTAssertEqual(view.name, "")
        XCTAssertEqual(view.targetAmountString, "")
        XCTAssertNil(view.targetDate)
        XCTAssertTrue(view.hasTargetDate)
        XCTAssertEqual(view.notes, "")

        // Test saving a savings goal with valid data
        viewModel.name = "Monthly Rent"
        viewModel.targetAmountString = "1000.00"
        viewModel.hasTargetDate = true
        viewModel.targetDate = Date()
        viewModel.notes = "Rent for the month"

        // WHEN
        view.saveSavingsGoal()

        // THEN
        XCTAssertTrue(viewModel.isFormValid)
        XCTAssertEqual(viewModel.name, "Monthly Rent")
        XCTAssertEqual(viewModel.targetAmountString, "1000.00")
        XCTAssertNotNil(viewModel.targetDate)
        XCTAssertTrue(viewModel.hasTargetDate)
        XCTAssertEqual(viewModel.notes, "Rent for the month")

        // Test saving a savings goal with invalid data
        viewModel.name = ""
        viewModel.targetAmountString = ""

        // WHEN
        view.saveSavingsGoal()

        // THEN
        XCTAssertFalse(viewModel.isFormValid)
    }

    // Test the SavingsGoalDetailView
    func testSavingsGoalDetailView() {
        // GIVEN
        let goal = SavingsGoal(
            name: "Monthly Rent",
            targetAmount: 1000.00,
            targetDate: Date(),
            notes: "Rent for the month"
        )
        let viewModel = SavingsGoalViewModel(goal: goal)
        let view = SavingsGoalDetailView(viewModel: viewModel)

        // WHEN
        // Simulate user input and actions

        // THEN
        XCTAssertEqual(view.goal.name, "Monthly Rent")
        XCTAssertEqual(view.goal.targetAmount, 1000.00)
        XCTAssertNotNil(view.goal.targetDate)
        XCTAssertTrue(view.goal.hasTargetDate)
        XCTAssertEqual(view.goal.notes, "Rent for the month")

        // Test saving a savings goal with valid data
        viewModel.name = "Monthly Rent"
        viewModel.targetAmountString = "1000.00"
        viewModel.hasTargetDate = true
        viewModel.targetDate = Date()
        viewModel.notes = "Rent for the month"

        // WHEN
        view.saveSavingsGoal()

        // THEN
        XCTAssertTrue(viewModel.isFormValid)
        XCTAssertEqual(viewModel.name, "Monthly Rent")
        XCTAssertEqual(viewModel.targetAmountString, "1000.00")
        XCTAssertNotNil(viewModel.goal.targetDate)
        XCTAssertTrue(viewModel.goal.hasTargetDate)
        XCTAssertEqual(viewModel.goal.notes, "Rent for the month")

        // Test saving a savings goal with invalid data
        viewModel.name = ""
        viewModel.targetAmountString = ""

        // WHEN
        view.saveSavingsGoal()

        // THEN
        XCTAssertFalse(viewModel.isFormValid)
    }
}
