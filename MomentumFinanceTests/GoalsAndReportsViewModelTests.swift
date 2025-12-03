import XCTest
@testable import MomentumFinance

class GoalsAndReportsViewModelTests: XCTestCase {
    var viewModel: GoalsAndReportsViewModel!

    // Test setModelContext method
    func testSetModelContext() {
        let context = ModelContext()
        viewModel.setModelContext(context)
        XCTAssertNotNil(viewModel.modelContext, "Model context should not be nil")
    }

    // Test completedGoals method
    func testCompletedGoals() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0, isCompleted: true),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0, isCompleted: false),
        ]
        let completed = viewModel.completedGoals(goals)
        XCTAssertEqual(completed.count, 1, "Should have one completed goal")
    }

    // Test activeGoals method
    func testActiveGoals() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0, isCompleted: true),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0, isCompleted: false),
        ]
        let active = viewModel.activeGoals(goals)
        XCTAssertEqual(active.count, 1, "Should have one active goal")
    }

    // Test goalsByProgress method
    func testGoalsByProgress() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0, progressPercentage: 75.0),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0, progressPercentage: 25.0),
        ]
        let sorted = viewModel.goalsByProgress(goals)
        XCTAssertEqual(sorted.count, 2, "Should have two goals sorted by progress")
    }

    // Test totalSavings method
    func testTotalSavings() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0, currentAmount: 375.0),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0, currentAmount: 225.0),
        ]
        let total = viewModel.totalSavings(goals)
        XCTAssertEqual(total, 600.0, "Total savings should be 600.0")
    }

    // Test totalTargetAmount method
    func testTotalTargetAmount() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0),
        ]
        let total = viewModel.totalTargetAmount(goals)
        XCTAssertEqual(total, 800.0, "Total target amount should be 800.0")
    }

    // Test overallSavingsProgress method
    func testOverallSavingsProgress() {
        let goals = [
            SavingsGoal(name: "Goal 1", targetAmount: 500.0, currentAmount: 375.0),
            SavingsGoal(name: "Goal 2", targetAmount: 300.0, currentAmount: 225.0),
        ]
        let progress = viewModel.overallSavingsProgress(goals)
        XCTAssertEqual(progress, 0.46875, "Overall savings progress should be approximately 0.46875")
    }

    // Test createSavingsGoal method
    func testCreateSavingsGoal() {
        let context = ModelContext()
        viewModel.setModelContext(context)

        let name = "Test Goal"
        let targetAmount = 1000.0
        let goal = viewModel.createSavingsGoal(name: name, targetAmount: targetAmount)
        XCTAssertNotNil(goal, "Goal should not be nil")
    }

    // Test addFundsToGoal method
    func testAddFundsToGoal() {
        let context = ModelContext()
        viewModel.setModelContext(context)

        let goal = SavingsGoal(name: "Test Goal", targetAmount: 1000.0)
        viewModel.createSavingsGoal(goal.name, targetAmount: goal.targetAmount)
        viewModel.addFundsToGoal(goal, amount: 500.0)
        XCTAssertEqual(goal.currentAmount, 1500.0, "Current amount should be 1500.0")
    }

}
