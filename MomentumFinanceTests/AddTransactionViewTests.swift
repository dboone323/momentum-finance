import SwiftData
import XCTest
@testable import MomentumFinance

class AddTransactionViewTests: XCTestCase {
    var addTransactionView: AddTransactionView!
    var modelContext: ModelContext!

    /// Test that the view displays the correct title and amount fields
    func testTitleAndAmountFieldsDisplay() {
        XCTAssertEqual(addTransactionView.title, "")
        XCTAssertEqual(addTransactionView.amount, "")
    }

    /// Test that the picker for transaction type is populated with all available types
    func testTransactionTypePickerPopulated() {
        let expectedTypes = [TransactionType.expense, TransactionType.income]

        XCTAssertEqual(addTransactionView.selectedTransactionType, .expense)
        XCTAssertEqual(addTransactionView.categories.count, 2)
        XCTAssertEqual(addTransactionView.accounts.count, 2)
    }

    /// Test that the picker for category is populated with all available categories
    func testCategoryPickerPopulated() {
        let expectedCategories = [
            ExpenseCategory(name: "Groceries", id: UUID()),
            ExpenseCategory(name: "Entertainment", id: UUID()),
        ]

        XCTAssertEqual(addTransactionView.selectedCategory, nil)
        XCTAssertEqual(addTransactionView.categories.count, 2)
        XCTAssertEqual(addTransactionView.accounts.count, 2)
    }

    /// Test that the picker for account is populated with all available accounts
    func testAccountPickerPopulated() {
        let expectedAccounts = [
            FinancialAccount(name: "Checking Account", id: UUID(), balance: 1000),
            FinancialAccount(name: "Savings Account", id: UUID(), balance: 500),
        ]

        XCTAssertEqual(addTransactionView.selectedAccount, nil)
        XCTAssertEqual(addTransactionView.categories.count, 2)
        XCTAssertEqual(addTransactionView.accounts.count, 2)
    }

    /// Test that the form is valid when all fields are filled
    func testFormIsValidWhenAllFieldsAreFilled() throws {
        addTransactionView.title = "Groceries"
        addTransactionView.amount = "10.50"
        addTransactionView.selectedTransactionType = .expense
        addTransactionView.selectedCategory = try XCTUnwrap(categories.first)
        addTransactionView.selectedAccount = try XCTUnwrap(accounts.first)

        XCTAssertTrue(addTransactionView.isFormValid)
    }

    /// Test that the form is not valid when any field is empty
    func testFormIsNotValidWhenAnyFieldIsEmpty() throws {
        addTransactionView.title = ""
        addTransactionView.amount = "10.50"
        addTransactionView.selectedTransactionType = .expense
        addTransactionView.selectedCategory = try XCTUnwrap(categories.first)
        addTransactionView.selectedAccount = try XCTUnwrap(accounts.first)

        XCTAssertFalse(addTransactionView.isFormValid)
    }

    /// Test that the form is not valid when the amount is not a number
    func testFormIsNotValidWhenAmountIsNotANumber() throws {
        addTransactionView.title = "Groceries"
        addTransactionView.amount = "abc"
        addTransactionView.selectedTransactionType = .expense
        addTransactionView.selectedCategory = try XCTUnwrap(categories.first)
        addTransactionView.selectedAccount = try XCTUnwrap(accounts.first)

        XCTAssertFalse(addTransactionView.isFormValid)
    }

    /// Test that the form is not valid when the selected account is nil
    func testFormIsNotValidWhenSelectedAccountIsNull() throws {
        addTransactionView.title = "Groceries"
        addTransactionView.amount = "10.50"
        addTransactionView.selectedTransactionType = .expense
        addTransactionView.selectedCategory = try XCTUnwrap(categories.first)

        XCTAssertFalse(addTransactionView.isFormValid)
    }

    /// Test that the form is not valid when the selected category is nil
    func testFormIsNotValidWhenSelectedCategoryIsNull() throws {
        addTransactionView.title = "Groceries"
        addTransactionView.amount = "10.50"
        addTransactionView.selectedTransactionType = .expense
        addTransactionView.selectedAccount = try XCTUnwrap(accounts.first)

        XCTAssertFalse(addTransactionView.isFormValid)
    }
}
