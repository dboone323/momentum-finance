@testable import MomentumFinance
import XCTest

class SimpleTransactionSectionHeaderTests: XCTestCase {

    func testSimpleTransactionSectionHeader() {
        // GIVEN: A group with a key and an array of financial transactions
        let group = (key: "2025-08", value: [
            FinancialTransaction(transactionType: .income, amount: 100.0),
            FinancialTransaction(transactionType: .expense, amount: -50.0),
            FinancialTransaction(transactionType: .income, amount: 75.0)
        ])

        // WHEN: Creating an instance of SimpleTransactionSectionHeader
        let header = SimpleTransactionSectionHeader(group: group)

        // THEN: The body of the view should display the correct key and month total
        XCTAssertEqual(header.body, HStack {
            Text("2025-08")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            Text("$137.00", format: .currency(code: "USD"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.green)
        })
    }

    func testMonthTotalWithPositiveIncome() {
        // GIVEN: A group with a key and an array of financial transactions
        let group = (key: "2025-08", value: [
            FinancialTransaction(transactionType: .income, amount: 100.0),
            FinancialTransaction(transactionType: .expense, amount: -50.0)
        ])

        // WHEN: Creating an instance of SimpleTransactionSectionHeader
        let header = SimpleTransactionSectionHeader(group: group)

        // THEN: The month total should be positive and green
        XCTAssertEqual(header.monthTotal, 137.00)
        XCTAssertEqual(header.body, HStack {
            Text("2025-08")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            Text("$137.00", format: .currency(code: "USD"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.green)
        })
    }

    func testMonthTotalWithNegativeIncome() {
        // GIVEN: A group with a key and an array of financial transactions
        let group = (key: "2025-08", value: [
            FinancialTransaction(transactionType: .income, amount: 100.0),
            FinancialTransaction(transactionType: .expense, amount: -30.0)
        ])

        // WHEN: Creating an instance of SimpleTransactionSectionHeader
        let header = SimpleTransactionSectionHeader(group: group)

        // THEN: The month total should be negative and red
        XCTAssertEqual(header.monthTotal, -70.00)
        XCTAssertEqual(header.body, HStack {
            Text("2025-08")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            Text("$-70.00", format: .currency(code: "USD"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
        })
    }
}
