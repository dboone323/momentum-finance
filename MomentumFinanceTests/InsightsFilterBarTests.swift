import XCTest
@testable import MomentumFinance

class InsightsFilterBarTests: XCTestCase {
    var filterPriority: InsightPriority?
    var filterType: InsightType?

    // Test the priority picker
    func testPriorityPicker() {
        // GIVEN: A default value for filterPriority is nil
        filterPriority = nil

        // WHEN: The priority picker is presented
        // THEN: The default text "All" should be selected and the tag should be nil
        XCTAssertEqual(filterPriority, nil)
        XCTAssertEqual(Picker("Priority", selection: self.$filterPriority).selected, nil)

        // GIVEN: A specific value for filterPriority is set to InsightPriority.High
        filterPriority = .High

        // WHEN: The priority picker is presented
        // THEN: The selected text should be "High" and the tag should be .High
        XCTAssertEqual(filterPriority, .High)
        XCTAssertEqual(Picker("Priority", selection: self.$filterPriority).selected, .High)

        // GIVEN: A specific value for filterPriority is set to InsightPriority.Low
        filterPriority = .Low

        // WHEN: The priority picker is presented
        // THEN: The selected text should be "Low" and the tag should be .Low
        XCTAssertEqual(filterPriority, .Low)
        XCTAssertEqual(Picker("Priority", selection: self.$filterPriority).selected, .Low)
    }

    // Test the type picker
    func testTypePicker() {
        // GIVEN: A default value for filterType is nil
        filterType = nil

        // WHEN: The type picker is presented
        // THEN: The default text "All" should be selected and the tag should be nil
        XCTAssertEqual(filterType, nil)
        XCTAssertEqual(Picker("Type", selection: self.$filterType).selected, nil)

        // GIVEN: A specific value for filterType is set to InsightType.Investment
        filterType = .Investment

        // WHEN: The type picker is presented
        // THEN: The selected text should be "Investment" and the tag should be .Investment
        XCTAssertEqual(filterType, .Investment)
        XCTAssertEqual(Picker("Type", selection: self.$filterType).selected, .Investment)

        // GIVEN: A specific value for filterType is set to InsightType.Earnings
        filterType = .Earnings

        // WHEN: The type picker is presented
        // THEN: The selected text should be "Earnings" and the tag should be .Earnings
        XCTAssertEqual(filterType, .Earnings)
        XCTAssertEqual(Picker("Type", selection: self.$filterType).selected, .Earnings)
    }
}
