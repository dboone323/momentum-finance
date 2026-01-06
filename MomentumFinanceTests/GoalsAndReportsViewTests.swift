import XCTest
import SwiftData
@testable import MomentumFinance

class GoalsAndReportsViewTests: XCTestCase {
    var viewModel: GoalsAndReportsViewModel!
    var modelContext: ModelContext!

    // Test the initialization of the view model with a specific context
    func testInitializationWithModelContext() {
        let context = ModelContext()
        viewModel = GoalsAndReportsViewModel(modelContext: context)
        XCTAssertEqual(viewModel.modelContext, context)
    }

    // Test the selection of a tab
    func testSelectTab() {
        viewModel.selectTab(1)
        XCTAssertEqual(viewModel.selectedTab, 1)
    }

    // Test the showing of an add goal button
    func testShowingAddGoalButton() {
        XCTAssertTrue(viewModel.showingAddGoal)
    }

    // Test the showing of a search sheet
    func testShowingSearchSheet() {
        XCTAssertTrue(viewModel.showingSearch)
    }

    // Test the selection of a goal
    func testSelectGoal() {
        let goal = SavingsGoal(id: UUID(), name: "Test Goal", amount: 100.0, category: nil)
        viewModel.selectGoal(goal)
        XCTAssertEqual(viewModel.selectedGoal, goal)
    }

    // Test the appearance of the add savings goal view
    func testAddSavingsGoalView() {
        XCTAssertTrue(viewModel.showingAddGoal)
    }

    // Test the appearance of the global search view
    func testGlobalSearchView() {
        XCTAssertTrue(viewModel.showingSearch)
    }

    // Test the appearance of the savings goal detail view
    func testSavingsGoalDetailView() {
        let goal = SavingsGoal(id: UUID(), name: "Test Goal", amount: 100.0, category: nil)
        viewModel.selectGoal(goal)
        XCTAssertTrue(viewModel.showingDetail)
    }

    // Test the appearance of the tab view style
    func testTabViewStyle() {
        #if canImport(UIKit)
            let view = GoalsAndReportsView()
            XCTAssertEqual(view.tabViewStyle(), .pageTabViewStyle(indexDisplayMode: .never))
        #elseif canImport(AppKit)
            let view = GoalsAndReportsView()
            XCTAssertEqual(view.tabViewStyle(), .pageTabViewStyle(indexDisplayMode: .never))
        #else
            XCTFail("Test not applicable for this platform")
        #endif
    }
}
