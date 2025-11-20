@testable import MomentumFinance
import XCTest

final class CoreFinancialModelsTests: XCTestCase {

    // MARK: - FinancialAccount Tests

    func testFinancialAccountInitialization() {
        let account = FinancialAccount(
            name: "Test Checking",
            type: .checking,
            balance: 1000.0
        )

        XCTAssertNotNil(account.id)
        XCTAssertEqual(account.name, "Test Checking")
        XCTAssertEqual(account.type, .checking)
        XCTAssertEqual(account.balance, 1000.0)
        XCTAssertEqual(account.currency, "USD")
    }

    func testFinancialAccountDefaultValues() {
        let account = FinancialAccount(name: "Test", type: .savings)

        XCTAssertEqual(account.balance, 0.0)
        XCTAssertEqual(account.currency, "USD")
    }

    func testFinancialAccountTypes() {
        let checking = FinancialAccount(name: "Checking", type: .checking, balance: 100)
        let savings = FinancialAccount(name: "Savings", type: .savings, balance: 200)
        let credit = FinancialAccount(name: "Credit", type: .credit, balance: -50)
        let investment = FinancialAccount(name: "Investment", type: .investment, balance: 5000)
        let loan = FinancialAccount(name: "Loan", type: .loan, balance: -10000)
        let other = FinancialAccount(name: "Other", type: .other, balance: 0)

        XCTAssertEqual(checking.type, .checking)
        XCTAssertEqual(savings.type, .savings)
        XCTAssertEqual(credit.type, .credit)
        XCTAssertEqual(investment.type, .investment)
        XCTAssertEqual(loan.type, .loan)
        XCTAssertEqual(other.type, .other)
    }

    func testFinancialAccountCodable() throws {
        let account = FinancialAccount(
            id: UUID(),
            name: "Test Account",
            type: .checking,
            balance: 1234.56,
            currency: "EUR"
        )

        let encoded = try JSONEncoder().encode(account)
        let decoded = try JSONDecoder().decode(FinancialAccount.self, from: encoded)

        XCTAssertEqual(account.id, decoded.id)
        XCTAssertEqual(account.name, decoded.name)
        XCTAssertEqual(account.type, decoded.type)
        XCTAssertEqual(account.balance, decoded.balance)
        XCTAssertEqual(account.currency, decoded.currency)
    }

    func testFinancialAccountNegativeBalance() {
        let account = FinancialAccount(name: "Credit Card", type: .credit, balance: -500.0)

        XCTAssertEqual(account.balance, -500.0)
        XCTAssertLessThan(account.balance, 0)
    }

    // MARK: - ExpenseCategory Tests

    func testExpenseCategoryInitialization() {
        let category = ExpenseCategory(
            name: "Groceries",
            color: "#FF0000",
            icon: "cart"
        )

        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, "Groceries")
        XCTAssertEqual(category.color, "#FF0000")
        XCTAssertEqual(category.icon, "cart")
    }

    func testExpenseCategoryDefaultValues() {
        let category = ExpenseCategory(name: "Test")

        XCTAssertEqual(category.color, "#007AFF")
        XCTAssertEqual(category.icon, "circle")
    }

    func testExpenseCategoryCodable() throws {
        let category = ExpenseCategory(
            id: UUID(),
            name: "Food",
            color: "#00FF00",
            icon: "fork.knife"
        )

        let encoded = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(ExpenseCategory.self, from: encoded)

        XCTAssertEqual(category.id, decoded.id)
        XCTAssertEqual(category.name, decoded.name)
        XCTAssertEqual(category.color, decoded.color)
        XCTAssertEqual(category.icon, decoded.icon)
    }

    // MARK: - FinancialTransaction Tests

    func testFinancialTransactionInitialization() {
        let category = ExpenseCategory(name: "Food")
        let account = FinancialAccount(name: "Checking", type: .checking, balance: 1000)

        let transaction = FinancialTransaction(
            title: "Lunch",
            amount: 15.50,
            category: category,
            account: account,
            type: .expense,
            notes: "Quick lunch"
        )

        XCTAssertNotNil(transaction.id)
        XCTAssertEqual(transaction.title, "Lunch")
        XCTAssertEqual(transaction.amount, 15.50)
        XCTAssertEqual(transaction.category?.name, "Food")
        XCTAssertEqual(transaction.account?.name, "Checking")
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertEqual(transaction.notes, "Quick lunch")
    }

    func testFinancialTransactionDefaultValues() {
        let transaction = FinancialTransaction(title: "Test", amount: 100)

        XCTAssertNotNil(transaction.date)
        XCTAssertNil(transaction.category)
        XCTAssertNil(transaction.account)
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertNil(transaction.notes)
    }

    func testFinancialTransactionTypes() {
        let income = FinancialTransaction(title: "Salary", amount: 5000, type: .income)
        let expense = FinancialTransaction(title: "Rent", amount: 1500, type: .expense)
        let transfer = FinancialTransaction(title: "Savings Transfer", amount: 500, type: .transfer)

        XCTAssertEqual(income.type, .income)
        XCTAssertEqual(expense.type, .expense)
        XCTAssertEqual(transfer.type, .transfer)
    }

    func testFinancialTransactionCodable() throws {
        let category = ExpenseCategory(name: "Transport")
        let transaction = FinancialTransaction(
            id: UUID(),
            title: "Gas",
            amount: 50.0,
            date: Date(),
            category: category,
            type: .expense
        )

        let encoded = try JSONEncoder().encode(transaction)
        let decoded = try JSONDecoder().decode(FinancialTransaction.self, from: encoded)

        XCTAssertEqual(transaction.id, decoded.id)
        XCTAssertEqual(transaction.title, decoded.title)
        XCTAssertEqual(transaction.amount, decoded.amount)
        XCTAssertEqual(transaction.type, decoded.type)
    }

    func testFinancialTransactionWithoutOptionalFields() {
        let transaction = FinancialTransaction(
            title: "Cash Payment",
            amount: 25.0
        )

        XCTAssertNil(transaction.category)
        XCTAssertNil(transaction.account)
        XCTAssertNil(transaction.notes)
    }

    func testFinancialTransactionNegativeAmount() {
        // Negative amounts should be allowed (refunds, corrections)
        let transaction = FinancialTransaction(
            title: "Refund",
            amount: -50.0,
            type: .income
        )

        XCTAssertEqual(transaction.amount, -50.0)
        XCTAssertLessThan(transaction.amount, 0)
    }

    func testFinancialTransactionZeroAmount() {
        let transaction = FinancialTransaction(
            title: "Zero Transaction",
            amount: 0.0
        )

        XCTAssertEqual(transaction.amount, 0.0)
    }

    func testFinancialTransactionLargeAmount() {
        let transaction = FinancialTransaction(
            title: "Property Purchase",
            amount: 500_000.0,
            type: .expense
        )

        XCTAssertEqual(transaction.amount, 500_000.0)
        XCTAssertGreaterThan(transaction.amount, 100_000)
    }

    // MARK: - Integration Tests

    func testTransactionWithAllComponents() {
        let category = ExpenseCategory(name: "Utilities", color: "#FF6B00", icon: "bolt")
        let account = FinancialAccount(name: "Main Checking", type: .checking, balance: 2000)

        let transaction = FinancialTransaction(
            title: "Electric Bill",
            amount: 120.50,
            date: Date(),
            category: category,
            account: account,
            type: .expense,
            notes: "Monthly electric bill payment"
        )

        XCTAssertEqual(transaction.category?.name, "Utilities")
        XCTAssertEqual(transaction.category?.color, "#FF6B00")
        XCTAssertEqual(transaction.account?.name, "Main Checking")
        XCTAssertEqual(transaction.account?.type, .checking)
    }

    func testMultipleAccountTypes() {
        let accounts = [
            FinancialAccount(name: "Checking", type: .checking, balance: 1000),
            FinancialAccount(name: "Savings", type: .savings, balance: 5000),
            FinancialAccount(name: "Credit Card", type: .credit, balance: -200),
            FinancialAccount(name: "401k", type: .investment, balance: 50000),
            FinancialAccount(name: "Mortgage", type: .loan, balance: -250_000)
        ]

        XCTAssertEqual(accounts.count, 5)
        XCTAssertTrue(accounts.allSatisfy { !$0.name.isEmpty })
    }

    func testSendableConformance() {
        // Test that types conform to Sendable protocol
        let account = FinancialAccount(name: "Test", type: .checking, balance: 100)
        let category = ExpenseCategory(name: "Test")
        let transaction = FinancialTransaction(title: "Test", amount: 50)

        Task {
            // If these compile and run, Sendable conformance is working
            _ = account
            _ = category
            _ = transaction
        }

        XCTAssertTrue(true) // Compilation is the test
    }
}
