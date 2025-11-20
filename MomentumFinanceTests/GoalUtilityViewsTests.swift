@testable import MomentumFinance
import XCTest

class GoalUtilityViewsTests: XCTestCase {
    // Test the GoalHeaderView
    func testGoalHeaderView() {
        // Given
        let title = "Savings Goals"
        let subtitle = "Track your savings progress"
        var selectedTab = 0
        var showingAddGoal = false

        // When
        let goalView = GoalHeaderView(title: title, subtitle: subtitle, selectedTab: $selectedTab, showingAddGoal: $showingAddGoal)

        // Then
        XCTAssertEqual(goalView.title, title)
        XCTAssertEqual(goalView.subtitle, subtitle)
        XCTAssertEqual(goalView.selectedTab, selectedTab)
        XCTAssertTrue(goalView.showingAddGoal == showingAddGoal)
    }

    // Test the EmptyGoalsView
    func testEmptyGoalsView() {
        // Given
        var showingAddGoal = false

        // When
        let emptyGoalsView = EmptyGoalsView(showingAddGoal: $showingAddGoal)

        // Then
        XCTAssertEqual(emptyGoalsView.showingAddGoal, showingAddGoal)
    }

    // Test the EmptyReportsView
    func testEmptyReportsView() {
        // Given

        // When
        let emptyReportsView = EmptyReportsView()

        // Then
        XCTAssertTrue(emptyReportsView.isEmpty)
    }

    // Test the TabSelectionView
    func testTabSelectionView() {
        // Given
        var selectedTab = 0

        // When
        let tabSelectionView = TabSelectionView(selectedTab: $selectedTab)

        // Then
        XCTAssertEqual(tabSelectionView.selectedTab, selectedTab)
    }
}
