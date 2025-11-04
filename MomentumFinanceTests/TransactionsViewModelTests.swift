import XCTest
@testable import MomentumFinance

class TransactionsViewModelTests: XCTestCase {
    var viewModel: TransactionsViewModel!
    var mockModelContext: MockModelContext!

    override func setUp() {
        super.setUp()
        mockModelContext = MockModelContext()
        viewModel = TransactionsViewModel()
        viewModel.setModelContext(mockModelContext)
    }

    override func tearDown() {
        mockModelContext = nil
        viewModel = nil
        super.tearDown()
    }

    // Test setModelContext method
    func testSetModelContext() {
        let context = ModelContext()
        viewModel.setModelContext(context)

        XCTAssertEqual(viewModel.modelContext, context)
    }

    // Test filterTransactions method
    func testFilterTransactions() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date()),
            FinancialTransaction(transactionType: .transfer, amount: 20.0, date: Date())
        ]

        let filteredIncome = viewModel.filterTransactions(transactions, by: .income)
        XCTAssertEqual(filteredIncome.count, 1)

        let filteredExpense = viewModel.filterTransactions(transactions, by: .expense)
        XCTAssertEqual(filteredExpense.count, 1)

        let filteredTransfer = viewModel.filterTransactions(transactions, by: .transfer)
        XCTAssertEqual(filteredTransfer.count, 0)
    }

    // Test searchTransactions method
    func testSearchTransactions() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date()),
            FinancialTransaction(transactionType: .transfer, amount: 20.0, date: Date())
        ]

        let filteredByTitle = viewModel.searchTransactions(transactions, query: "Income")
        XCTAssertEqual(filteredByTitle.count, 1)

        let filteredByCategory = viewModel.searchTransactions(transactions, query: "Expenses")
        XCTAssertEqual(filteredByCategory.count, 1)

        let filteredByNotes = viewModel.searchTransactions(transactions, query: "Transfer")
        XCTAssertEqual(filteredByNotes.count, 0)
    }

    // Test groupTransactionsByMonth method
    func testGroupTransactionsByMonth() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date()),
            FinancialTransaction(transactionType: .transfer, amount: 20.0, date: Date())
        ]

        let grouped = viewModel.groupTransactionsByMonth(transactions)
        XCTAssertEqual(grouped.count, 1)

        let expectedGroup = [
            "January 2023": [transactions[0]]
        ]
        XCTAssertEqual(grouped, expectedGroup)
    }

    // Test totalIncome method
    func testTotalIncome() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date())
        ]

        XCTAssertEqual(viewModel.totalIncome(transactions), 50.0)
    }

    // Test totalExpenses method
    func testTotalExpenses() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date())
        ]

        XCTAssertEqual(viewModel.totalExpenses(transactions), -50.0)
    }

    // Test netIncome method
    func testNetIncome() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date())
        ]

        XCTAssertEqual(viewModel.netIncome(transactions), 50.0)
    }

    // Test currentMonthTransactions method
    func testCurrentMonthTransactions() {
        let transactions = [
            FinancialTransaction(transactionType: .income, amount: 100.0, date: Date()),
            FinancialTransaction(transactionType: .expense, amount: -50.0, date: Date())
        ]

        let currentMonth = viewModel.currentMonthTransactions(transactions)
        XCTAssertEqual(currentMonth.count, 2)
    }
