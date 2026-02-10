import SwiftData
import XCTest
@testable import MomentumFinance

class EnhancedAccountDetailViewTests: XCTestCase {
    var enhancedAccountDetailView: EnhancedAccountDetailView!

    /// Test the account detail view's top toolbar actions
    func testToolbarActions() {
        let account = FinancialAccount(id: "12345", name: "Test Account", type: .checking)
        let transactions = [FinancialTransaction(date: Date(), amount: 100, account: account)]

        enhancedAccountDetailView = EnhancedAccountDetailView(
            accountId: "12345",
            modelContext: ModelContext.shared,
            accounts: [account],
            transactions: transactions
        )

        // Test Edit button
        XCTAssertEqual(enhancedAccountDetailView.isEditing, false)
        enhancedAccountDetailView.isEditing.toggle()
        XCTAssertEqual(enhancedAccountDetailView.isEditing, true)

        // Test Delete confirmation
        enhancedAccountDetailView.showingDeleteConfirmation = true
        XCTAssertTrue(enhancedAccountDetailView.showingDeleteConfirmation)
        enhancedAccountDetailView.showingDeleteConfirmation = false
        XCTAssertFalse(enhancedAccountDetailView.showingDeleteConfirmation)

        // Test Export options
        enhancedAccountDetailView.showingExportOptions = true
        XCTAssertTrue(enhancedAccountDetailView.showingExportOptions)
        enhancedAccountDetailView.showingExportOptions = false
        XCTAssertFalse(enhancedAccountDetailView.showingExportOptions)
    }

    /// Test the account detail view's time frame picker
    func testTimeFramePicker() {
        let account = FinancialAccount(id: "12345", name: "Test Account", type: .checking)
        let transactions = [FinancialTransaction(date: Date(), amount: 100, account: account)]

        enhancedAccountDetailView = EnhancedAccountDetailView(
            accountId: "12345",
            modelContext: ModelContext.shared,
            accounts: [account],
            transactions: transactions
        )

        XCTAssertEqual(enhancedAccountDetailView.selectedTimeFrame, .last30Days)
        enhancedAccountDetailView.selectedTimeFrame = .last90Days
        XCTAssertEqual(enhancedAccountDetailView.selectedTimeFrame, .last90Days)
    }

    /// Test the account detail view's transaction list
    func testTransactionList() {
        let account = FinancialAccount(id: "12345", name: "Test Account", type: .checking)
        let transactions = [FinancialTransaction(date: Date(), amount: 100, account: account)]

        enhancedAccountDetailView = EnhancedAccountDetailView(
            accountId: "12345",
            modelContext: ModelContext.shared,
            accounts: [account],
            transactions: transactions
        )

        XCTAssertEqual(enhancedAccountDetailView.filteredTransactions.count, 1)
        XCTAssertEqual(enhancedAccountDetailView.filteredTransactions[0].amount, 100)
    }
}
