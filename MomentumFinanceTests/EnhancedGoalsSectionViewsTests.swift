@testable import MomentumFinance
import XCTest

class EnhancedGoalsSectionViewsTests: XCTestCase {
    var viewModel: Features.GoalsAndReports.EnhancedSavingsGoalsSection!
    var goals: [Features.GoalsAndReports.SavingsGoal] = []
    var showingAddGoal: Bool = false
    var selectedGoal: Features.GoalsAndReports.SavingsGoal?

    // Test emptyGoalsView
    func testEmptyGoalsView() {
        let view = viewModel.emptyGoalsView

        XCTAssertEqual(view.description, """
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text("No Savings Goals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Create your first savings goal to start building your financial future")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(
                    action: { self.showingAddGoal = true },
                    label: {
                        Label("Create Your First Goal", systemImage: "target")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                )

                Spacer()
            }
        """)
    }

    // Test goalsContentView
    func testGoalsContentView() {
        let view = viewModel.goalsContentView

        XCTAssertEqual(view.description, """
            ScrollView {
                LazyVStack(spacing: 16) {
                    self.summarySection
                    self.activeGoalsSection
                    self.completedGoalsSection
                }
                .padding()
            }
        """)
    }

    // Test summarySection
    func testSummarySection() {
        let view = viewModel.summarySection

        XCTAssertEqual(view.description, """
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(
                        "\(self.activeGoals.count) active • \(self.completedGoals.count) completed"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
        """)
    }

    // Test activeGoalsSection
    func testActiveGoalsSection() {
        let view = viewModel.activeGoalsSection

        XCTAssertEqual(view.description, """
            VStack(spacing: 16) {
                HStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalSaved.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Target")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalTarget.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        """)
    }

    // Test completedGoalsSection
    func testCompletedGoalsSection() {
        let view = viewModel.completedGoalsSection

        XCTAssertEqual(view.description, """
            VStack(spacing: 16) {
                HStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalSaved.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Target")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalTarget.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        """)
    }

}
