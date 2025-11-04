import XCTest
@testable import MomentumFinance

class ModelsTests: XCTestCase {
    // Test compilation of models
    func testModels() {
        // GIVEN: A FinancialAccount with specific values
        let account = FinancialAccount(name: "Test", accountType: .checking, balance: 100.0)
        
        // WHEN: Accessing properties
        XCTAssertEqual(account.name, "Test")
        XCTAssertEqual(account.accountType, .checking)
        XCTAssertEqual(account.balance, 100.0)
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(account.id)
        XCTAssertGreaterThan(account.balance, 0.0)
    }
    
    func testFinancialTransaction() {
        // GIVEN: A FinancialTransaction with specific values
        let transaction = FinancialTransaction(
            title: "Test Transaction",
            amount: 50.0,
            date: Date(),
            transactionType: .expense,
        )
        
        // WHEN: Accessing properties
        XCTAssertEqual(transaction.title, "Test Transaction")
        XCTAssertEqual(transaction.amount, 50.0)
        XCTAssertEqual(transaction.date, Date())
        XCTAssertEqual(transaction.transactionType, .expense)
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(transaction.id)
    }
    
    func testCategory() {
        // GIVEN: A Category with specific values
        let category = Category(name: "Test Category", color: "blue", icon: "star")
        
        // WHEN: Accessing properties
        XCTAssertEqual(category.name, "Test Category")
        XCTAssertEqual(category.color, "blue")
        XCTAssertEqual(category.icon, "star")
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(category.id)
    }
    
    func testSubscription() {
        // GIVEN: A Subscription with specific values
        let subscription = Subscription(
            name: "Test Sub",
            amount: 10.0,
            frequency: .monthly,
            nextDueDate: Date(),
        )
        
        // WHEN: Accessing properties
        XCTAssertEqual(subscription.name, "Test Sub")
        XCTAssertEqual(subscription.amount, 10.0)
        XCTAssertEqual(subscription.frequency, .monthly)
        XCTAssertEqual(subscription.nextDueDate, Date())
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(subscription.id)
    }
    
    func testBudget() {
        // GIVEN: A Budget with specific values
        let budget = Budget(
            category: Category(name: "Test Category", color: "blue", icon: "star"),
            monthlyLimit: 200.0,
            month: Date(),
        )
        
        // WHEN: Accessing properties
        XCTAssertEqual(budget.category.name, "Test Category")
        XCTAssertEqual(budget.monthlyLimit, 200.0)
        XCTAssertEqual(budget.month, Date())
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(budget.id)
    }
    
    func testGoal() {
        // GIVEN: A SavingsGoal with specific values
        let goal = SavingsGoal(
            name: "Test Goal",
            targetAmount: 1000.0,
            currentAmount: 0.0,
            targetDate: Date(),
        )
        
        // WHEN: Accessing properties
        XCTAssertEqual(goal.name, "Test Goal")
        XCTAssertEqual(goal.targetAmount, 1000.0)
        XCTAssertEqual(goal.currentAmount, 0.0)
        XCTAssertEqual(goal.targetDate, Date())
        
        // THEN: Verify the properties are correctly set
        XCTAssertNotNil(goal.id)
    }
}
