import SwiftData
import XCTest
@testable import MomentumFinance

class DataExporterTests: XCTestCase {
    var dataExporter: DataExporter!

    /// Test that the configure method initializes the engine asynchronously when a ModelContext is available
    func testConfigureWithModelContext() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        XCTAssertNotNil(dataExporter.engine, "Engine should be initialized")
        XCTAssertEqual(modelContext, dataExporter.engine!.modelContext, "ModelContext should be set on the engine")
    }

    /// Test that the export method throws an error when the engine is nil
    func testExportWithInvalidSettings() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        do {
            await dataExporter.export(with: ExportSettings())
            XCTFail("Expected to throw an error")
        } catch ExportError.invalidSettings {
            // Expected error
        }
    }

    /// Test that the export method returns a URL when successful
    func testExportWithSuccess() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        let settings = ExportSettings()
        let expectedURL = URL(string: "https://example.com/exported-file")!
        do {
            let url = try await dataExporter.export(with: settings)
            XCTAssertEqual(url, expectedURL, "Expected to return the correct URL")
        } catch {
            XCTFail("Unexpected error exporting file")
        }
    }

    /// Test that the engine is properly deallocated after use
    func testEngineDeallocated() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        do {
            try await dataExporter.export(with: ExportSettings())
        } catch {
            XCTFail("Unexpected error exporting file")
        }

        XCTAssertNil(dataExporter.engine, "Engine should be deallocated after use")
    }

    /// Test that the engine is properly initialized when a ModelContext is available
    func testConfigureWithModelContextAsync() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        XCTAssertNotNil(dataExporter.engine, "Engine should be initialized")
        XCTAssertEqual(modelContext, dataExporter.engine!.modelContext, "ModelContext should be set on the engine")
    }

    /// Test that the export method throws an error when the engine is nil
    func testExportWithInvalidSettingsAsync() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        do {
            try await dataExporter.export(with: ExportSettings())
            XCTFail("Expected to throw an error")
        } catch ExportError.invalidSettings {
            // Expected error
        }
    }

    /// Test that the export method returns a URL when successful
    func testExportWithSuccessAsync() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        let settings = ExportSettings()
        let expectedURL = URL(string: "https://example.com/exported-file")!
        do {
            let url = try await dataExporter.export(with: settings)
            XCTAssertEqual(url, expectedURL, "Expected to return the correct URL")
        } catch {
            XCTFail("Unexpected error exporting file")
        }
    }

    /// Test that the engine is properly deallocated after use
    func testEngineDeallocatedAsync() async throws {
        let modelContext = MockModelContext()
        await dataExporter.configure(with: modelContext)

        do {
            try await dataExporter.export(with: ExportSettings())
        } catch {
            XCTFail("Unexpected error exporting file")
        }

        XCTAssertNil(dataExporter.engine, "Engine should be deallocated after use")
    }
}

class MockModelContext: ModelContext {
    var isAvailable = true
}
