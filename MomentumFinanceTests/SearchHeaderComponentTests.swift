import XCTest
@testable import MomentumFinance

class SearchHeaderComponentTests: XCTestCase {
    var sut: SearchHeaderComponent!
    var searchTextBinding: Binding<String>!
    var selectedFilterBinding: Binding<SearchFilter>!

    override func setUp() {
        super.setUp()
        searchTextBinding = .init(wrappedValue: "")
        selectedFilterBinding = .init(wrappedValue: .all)
        sut = SearchHeaderComponent(searchText: searchTextBinding, selectedFilter: selectedFilterBinding)
    }

    override func tearDown() {
        super.tearDown()
        searchTextBinding = nil
        selectedFilterBinding = nil
        sut = nil
    }

    // Test Case 1: Initial State
    func testInitialState() {
        XCTAssertEqual(searchTextBinding.wrappedValue, "")
        XCTAssertEqual(selectedFilterBinding.wrappedValue, .all)
    }

    // Test Case 2: Search Text Field
    func testSearchTextField() {
        let textField = sut.body.findFirst(ofType: TextField.self)!
        
        XCTAssertEqual(textField.text, searchTextBinding.wrappedValue)
        XCTAssertEqual(textField.accessibilityLabel, "Text Field")
        XCTAssertEqual(textField.textFieldStyle, .plain)
        XCTAssertEqual(textField.onChange(of: searchTextBinding)!.count, 1)
    }

    // Test Case 3: Filter Picker
    func testFilterPicker() {
        let filterPicker = sut.body.findFirst(ofType: Picker.self)!
        
        XCTAssertEqual(filterPicker.selection, selectedFilterBinding.wrappedValue)
        XCTAssertEqual(filterPicker.pickerStyle, .segmented)
    }

    // Test Case 4: Search Text Field Change
    func testSearchTextFieldChange() {
        searchTextBinding.wrappedValue = "Test"
        XCTAssertEqual(searchTextBinding.wrappedValue, "Test")
        
        let textField = sut.body.findFirst(ofType: TextField.self)!
        XCTAssertEqual(textField.text, searchTextBinding.wrappedValue)
    }

    // Test Case 5: Filter Picker Change
    func testFilterPickerChange() {
        selectedFilterBinding.wrappedValue = .crypto
        XCTAssertEqual(selectedFilterBinding.wrappedValue, .crypto)
        
        let filterPicker = sut.body.findFirst(ofType: Picker.self)!
        XCTAssertEqual(filterPicker.selection, selectedFilterBinding.wrappedValue)
    }

    // Test Case 6: Clear Search Text Field
    func testClearSearchTextField() {
        searchTextBinding.wrappedValue = "Test"
        sut.searchText = ""
        
        let textField = sut.body.findFirst(ofType: TextField.self)!
        XCTAssertEqual(textField.text, "")
    }
}
