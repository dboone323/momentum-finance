import XCTest
@testable import MomentumFinance

class FinancialIntelligenceServiceTests: XCTestCase {
    var service: FinancialIntelligenceService!
    var mockModelContext: MockModelContext!

    override func setUp() {
        super.setUp()
        service = FinancialIntelligenceService.shared
        mockModelContext = MockModelContext()
        service.mlModels = FinancialMLModels(mockModelContext)
        service.patternAnalyzer = TransactionPatternAnalyzer(mockModelContext)
    }

    override func tearDown() {
        mockModelContext.reset()
        super.tearDown()
    }

    // MARK: - Test Cases

    func testAnalyzeFinancialData() throws {
        // GIVEN
        let transactions = [
            FinancialTransaction(amount: 100, category: .food, date: Date()),
            FinancialTransaction(amount: 200, category: .entertainment, date: Date())
        ]
        let categories = [
            ExpenseCategory(name: "Food", priority: 1),
            ExpenseCategory(name: "Entertainment", priority: 2)
        ]

        // WHEN
        service.analyzeFinancialData(modelContext: mockModelContext)

        // THEN
        XCTAssertEqual(service.insights.count, 0) // No insights should be present initially

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for analysis to complete
            XCTAssertEqual(service.isAnalyzing, false)
            XCTAssertEqual(service.lastAnalysisDate, Date())
            XCTAssertEqual(service.insights.count, 2) // Two insights should be present after analysis
        }
    }

    func testSuggestCategoryForTransaction() throws {
        // GIVEN
        let transaction = FinancialTransaction(amount: 100, category: .food, date: Date())

        // WHEN
        let category = service.suggestCategoryForTransaction(transaction)

        // THEN
        XCTAssertEqual(category?.name, "Food") // Correct category should be suggested
    }

    func testAnalyzeSpendingPatterns() throws {
        // GIVEN
        let transactions = [
            FinancialTransaction(amount: 100, category: .food, date: Date()),
            FinancialTransaction(amount: 200, category: .entertainment, date: Date())
        ]
        let categories = [
            ExpenseCategory(name: "Food", priority: 1),
            ExpenseCategory(name: "Entertainment", priority: 2)
        ]

        // WHEN
        service.analyzeFinancialData(modelContext: mockModelContext)

        // THEN
        XCTAssertEqual(service.insights.count, 0) // No insights should be present initially

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for analysis to complete
            XCTAssertEqual(service.isAnalyzing, false)
            XCTAssertEqual(service.lastAnalysisDate, Date())
            XCTAssertEqual(service.insights.count, 2) // Two insights should be present after analysis
        }
    }

    func testDetectAnomalies() throws {
        // GIVEN
        let transactions = [
            FinancialTransaction(amount: 100, category: .food, date: Date()),
            FinancialTransaction(amount: 200, category: .entertainment, date: Date())
        ]

        // WHEN
        service.analyzeFinancialData(modelContext: mockModelContext)

        // THEN
        XCTAssertEqual(service.insights.count, 0) // No insights should be present initially

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for analysis to complete
            XCTAssertEqual(service.isAnalyzing, false)
            XCTAssertEqual(service.lastAnalysisDate, Date())
            XCTAssertEqual(service.insights.count, 2) // Two insights should be present after analysis
        }
    }

    func testAnalyzeBudgets() throws {
        // GIVEN
        let transactions = [
            FinancialTransaction(amount: 100, category: .food, date: Date()),
            FinancialTransaction(amount: 200, category: .entertainment, date: Date())
        ]
        let budgets = [
            Budget(name: "Food", priority: 1),
            Budget(name: "Entertainment", priority: 2)
        ]

        // WHEN
        service.analyzeFinancialData(modelContext: mockModelContext)

        // THEN
        XCTAssertEqual(service.insights.count, 0) // No insights should be present initially

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for analysis to complete
            XCTAssertEqual(service.isAnalyzing, false)
            XCTAssertEqual(service.lastAnalysisDate, Date())
            XCTAssertEqual(service.insights.count, 2) // Two insights should be present after analysis
        }
    }
