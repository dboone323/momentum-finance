import XCTest
@testable import MomentumFinance

class DashboardWelcomeHeaderTests: XCTestCase {
    var viewModel: Features.Dashboard.DashboardWelcomeHeader!

    /// Test the greeting property
    func testGreetingProperty() {
        XCTAssertEqual(viewModel.greeting, "Morning")
    }

    /// Test the wellnessPercentage property
    func testWellnessPercentageProperty() {
        XCTAssertEqual(viewModel.wellnessPercentage, 85)
    }

    /// Test the totalBalance property
    func testTotalBalanceProperty() {
        XCTAssertEqual(viewModel.totalBalance, 10000.0)
    }

    /// Test the monthlyIncome property
    func testMonthlyIncomeProperty() {
        XCTAssertEqual(viewModel.monthlyIncome, 2000.0)
    }

    /// Test the monthlyExpenses property
    func testMonthlyExpensesProperty() {
        XCTAssertEqual(viewModel.monthlyExpenses, 1500.0)
    }

    /// Test the body view with real data
    func testBodyViewWithRealData() {
        let actualView = viewModel.body

        // GIVEN: Real data for testing
        let greeting = "Morning"
        let wellnessPercentage = 85
        let totalBalance = 10000.0
        let monthlyIncome = 2000.0
        let monthlyExpenses = 1500.0

        // WHEN: The body view is created with the real data
        let expectedView = VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Good \(greeting)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()

                Menu {
                    Button(action: {
                        // Refresh action
                    }, label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }

            Text("Here's a summary of your finances")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            // Financial Wellness Score
            HStack(spacing: 16) {
                Text("Financial Wellness")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 170, height: 8)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green)
                        .frame(width: 170 * Double(wellnessPercentage) / 100, height: 8)
                }

                Text("\(wellnessPercentage)%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 2)
        }

        // THEN: The actual view should match the expected view
        XCTAssertEqual(actualView, expectedView)
    }
}
