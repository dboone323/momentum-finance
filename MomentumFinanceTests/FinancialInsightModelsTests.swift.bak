@testable import MomentumFinance
import XCTest

class FinancialInsightModelsTests: XCTestCase {
    // Test setup

    // Test teardown

    // Test FinancialInsightType enumeration
    func testFinancialInsightTypeEnumeration() {
        // GIVEN: A set of predefined FinancialInsightType values
        let expectedTypes = [
            .spendingPattern,
            .anomaly,
            .budget,
            .forecast,
            .optimization,
            .cashManagement,
            .creditUtilization,
            .duplicatePayment,
        ]

        // WHEN: Enumerating over the FinancialInsightType enumeration
        for type in FinancialInsightType.allCases {
            // THEN: The type should be one of the expected values
            XCTAssertEqual(type, expectedTypes.first(where: { $0.rawValue == type.rawValue }))
        }
    }

    // Test FinancialInsight struct properties
    func testFinancialInsightProperties() {
        // GIVEN: A predefined FinancialInsight object with specific data
        let financialInsight = FinancialInsight(
            type: .spendingPattern,
            title: "High Spending",
            description: "Identifies spending patterns that are higher than expected.",
            priority: 3,
            createdAt: Date()
        )

        // WHEN: Accessing the properties of the FinancialInsight object
        XCTAssertEqual(financialInsight.type, .spendingPattern)
        XCTAssertEqual(financialInsight.title, "High Spending")
        XCTAssertEqual(financialInsight.description, "Identifies spending patterns that are higher than expected.")
        XCTAssertEqual(financialInsight.priority, 3)
        XCTAssertEqual(financialInsight.createdAt, Date())
    }

    // Test FinancialInsight struct initializer
    func testFinancialInsightInitializer() {
        // GIVEN: A set of predefined values for the FinancialInsight initializer
        let type = .spendingPattern
        let title = "High Spending"
        let description = "Identifies spending patterns that are higher than expected."
        let priority = 3
        let createdAt = Date()

        // WHEN: Creating a new FinancialInsight object using the initializer
        let financialInsight = FinancialInsight(
            type: type,
            title: title,
            description: description,
            priority: priority,
            createdAt: createdAt
        )

        // THEN: The properties of the FinancialInsight object should match the provided values
        XCTAssertEqual(financialInsight.type, type)
        XCTAssertEqual(financialInsight.title, title)
        XCTAssertEqual(financialInsight.description, description)
        XCTAssertEqual(financialInsight.priority, priority)
        XCTAssertEqual(financialInsight.createdAt, createdAt)
    }
}
