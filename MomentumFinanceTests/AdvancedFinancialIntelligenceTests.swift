import XCTest
@testable import MomentumFinance

class AdvancedFinancialIntelligenceTests: XCTestCase {
    var advancedFinancialIntelligence: AdvancedFinancialIntelligence!

    // Test generateInsights method with real data
    func testGenerateInsightsWithRealData() async throws {
        let transactions = [
            Transaction(date: Date(), amount: 1000, category: "Groceries"),
            Transaction(date: Date(), amount: 2000, category: "Entertainment"),
            Transaction(date: Date(), amount: 3000, category: "Food"),
        ]
        let accounts = [
            Account(name: "Checking", balance: 5000),
            Account(name: "Savings", balance: 1000),
        ]
        let budgets = [
            AIBudget(category: "Groceries", budgetAmount: 2000, threshold: 3000),
            AIBudget(category: "Entertainment", budgetAmount: 500, threshold: 750),
        ]

        // Simulate a delay for the analysis process
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            advancedFinancialIntelligence.generateInsights(from: transactions, accounts: accounts, budgets: budgets)
        }

        // Assert that insights are generated correctly
        XCTAssertEqual(advancedFinancialIntelligence.insights.count, 5)

        let spendingInsight = advancedFinancialIntelligence.insights
            .first(where: { $0.title == "Accelerating Spending Detected" })
        XCTAssertNotNil(spendingInsight)
        XCTAssertTrue(spendingInsight.priority == .high)
        XCTAssertTrue(spendingInsight.type == .spendingAlert)
        XCTAssertTrue(spendingInsight.confidence == 0.9)
        XCTAssertEqual(spendingInsight.actionRecommendations.count, 3)
        XCTAssertEqual(spendingInsight.impactScore, 8.5)

        let categoryInsights = advancedFinancialIntelligence.insights.filter { $0.type == .categoryInsight }
        XCTAssertTrue(!categoryInsights.isEmpty)
    }

    // Test getInvestmentRecommendations method with real data
    func testGetInvestmentRecommendationsWithRealData() throws {
        let riskTolerance = RiskTolerance.moderate
        let timeHorizon = TimeHorizon.longTerm
        let currentPortfolio = [
            Investment(name: "Stock A", value: 1000),
            Investment(name: "Bond B", value: 500),
        ]

        // Simulate a delay for the recommendation generation process
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            advancedFinancialIntelligence.getInvestmentRecommendations(
                riskTolerance: riskTolerance,
                timeHorizon: timeHorizon,
                currentPortfolio: currentPortfolio
            )
        }

        // Assert that recommendations are generated correctly
        XCTAssertEqual(advancedFinancialIntelligence.insights.count, 3)

        let recommendation = advancedFinancialIntelligence.insights.first(where: { $0.title == "High Risk Investment" })
        XCTAssertNotNil(recommendation)
        XCTAssertTrue(recommendation.priority == .high)
        XCTAssertTrue(recommendation.type == .investmentRecommendation)
        XCTAssertTrue(recommendation.confidence == 0.85)
        XCTAssertEqual(recommendation.actionRecommendations.count, 2)
        XCTAssertEqual(recommendation.impactScore, 7.5)
    }

    // Test predictCashFlow method with real data
    func testPredictCashFlowWithRealData() throws {
        let transactions = [
            Transaction(date: Date(), amount: 1000, category: "Groceries"),
            Transaction(date: Date(), amount: 2000, category: "Entertainment"),
            Transaction(date: Date(), amount: 3000, category: "Food"),
        ]
        let months = 6

        // Simulate a delay for the prediction generation process
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            advancedFinancialIntelligence.predictCashFlow(transactions: transactions, months: months)
        }
    }
}
