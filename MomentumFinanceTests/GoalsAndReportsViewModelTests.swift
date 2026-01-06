import XCTest
import SwiftData
@testable import MomentumFinance

@MainActor
class GoalsAndReportsViewModelTests: XCTestCase {
    var viewModel: GoalsAndReportsViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: SavingsGoal.self, configurations: config)
        modelContext = ModelContext(modelContainer)
        viewModel = GoalsAndReportsViewModel()
        viewModel.setModelContext(modelContext)
    }

    func testActiveAndCompletedGoals() {
        let g1 = SavingsGoal(name: "Active", targetAmount: 100.0)
        let g2 = SavingsGoal(name: "Completed", targetAmount: 100.0)
        g2.currentAmount = 100.0 
        // g2.isCompleted is get-only, inferred from current >= target

        let goals = [g1, g2]

        // If SavingsGoal model logic works, g2 should be complete.
        // Assuming Logic: isCompleted { currentAmount >= targetAmount }
        XCTAssertEqual(viewModel.activeGoals(goals).count, 1) // g1
        XCTAssertEqual(viewModel.completedGoals(goals).count, 1) // g2
    }
    
    func testTotalSavings() {
        let g1 = SavingsGoal(name: "G1", targetAmount: 100.0)
        g1.currentAmount = 50.0
        let g2 = SavingsGoal(name: "G2", targetAmount: 100.0)
        g2.currentAmount = 25.0
        
        XCTAssertEqual(viewModel.totalSavings([g1, g2]), 75.0)
    }
}
