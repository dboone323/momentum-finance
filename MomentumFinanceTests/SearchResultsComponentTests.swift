import XCTest
@testable import MomentumFinance

class SearchResultsComponentTests: XCTestCase {
    var component: SearchResultsComponent!
    var viewModel: MockSearchViewModel!

    // Test case for the initializer
    func testInitialization() {
        let results = [SearchResult(title: "Test Result 1", subtitle: "Subtitle 1", iconName: "star")]
        let isLoading = false
        let onResultTapped = nil

        component = SearchResultsComponent(results: results, isLoading: isLoading, onResultTapped: onResultTapped)

        XCTAssertEqual(component.results, results)
        XCTAssertEqual(component.isLoading, isLoading)
        XCTAssertNil(component.onResultTapped)
    }

    // Test case for the body view
    func testBodyView() {
        let results = [SearchResult(title: "Test Result 1", subtitle: "Subtitle 1", iconName: "star")]
        let isLoading = false
        let onResultTapped = nil

        component = SearchResultsComponent(results: results, isLoading: isLoading, onResultTapped: onResultTapped)

        // Test case for the loading state
        XCTAssertEqual(component.body, VStack(spacing: 16) {
            ProgressView("Searching...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })

        // Test case for the empty results state
        let emptyResults = []
        component = SearchResultsComponent(results: emptyResults, isLoading: false, onResultTapped: nil)

        XCTAssertEqual(component.body, VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try adjusting your search terms")
                .font(.subheadline)
                .foregroundColor(.secondary)
        })

        // Test case for the populated results state
        let populatedResults = [SearchResult(title: "Test Result 1", subtitle: "Subtitle 1", iconName: "star")]
        component = SearchResultsComponent(results: populatedResults, isLoading: false, onResultTapped: nil)

        XCTAssertEqual(component.body, List(populatedResults) { result in
            SearchResultRow(result: result, onResultTapped: self.onResultTapped)
        })
    }

    // Test case for the SearchResultRow view
    func testSearchResultRowView() {
        let result = SearchResult(title: "Test Result 1", subtitle: "Subtitle 1", iconName: "star")
        let onResultTapped = nil

        component = SearchResultsComponent(results: [], isLoading: false, onResultTapped: onResultTapped)

        // Test case for the icon
        XCTAssertEqual(component.body, VStack(spacing: 12) {
            Image(systemName: result.iconName)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
        })

        // Test case for the title and subtitle
        XCTAssertEqual(component.body, VStack(alignment: .leading, spacing: 4) {
            Text(result.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            if let subtitle = result.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        })

        // Test case for the type indicator
        XCTAssertEqual(component.body, VStack(spacing: 12) {
            Text(result.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(8)
        })
    }
}

class MockSearchViewModel: SearchViewModel {
    var results = [SearchResult]()
    var isLoading = false
    var onResultTapped: ((SearchResult) -> Void)?

    func search(query: String, completion: @escaping (Bool) -> Void) {
        // Simulate a search operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.results = [SearchResult(title: "Test Result 1", subtitle: "Subtitle 1", iconName: "star")]
            self.isLoading = false
            completion(true)
        }
    }

    func clearResults() {
        self.results.removeAll()
        self.isLoading = false
    }
}
