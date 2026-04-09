import OSLog
import XCTest
@testable import MomentumFinance

@MainActor
final class AppLoggerTests: XCTestCase {
    var logger: AppLogger!

    override func setUp() async throws {
        try await super.setUp()
        logger = AppLogger.shared
    }

    override func tearDown() async throws {
        logger = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSharedInstanceExists() {
        XCTAssertNotNil(AppLogger.shared)
    }

    func testSingletonPattern() {
        let instance1 = AppLogger.shared
        let instance2 = AppLogger.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Log Level Tests

    func testLogDebugMessage() {
        // Should not crash
        logger.log("Debug message", level: .debug, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogInfoMessage() {
        logger.log("Info message", level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogWarningMessage() {
        logger.log("Warning message", level: .warning, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogErrorMessage() {
        logger.log("Error message", level: .error, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogCriticalMessage() {
        logger.log("Critical message", level: .critical, category: .general)
        XCTAssertNotNil(logger)
    }

    // MARK: - Log Category Tests

    func testLogToGeneralCategory() {
        logger.log("General log", level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogToUICategory() {
        logger.log("UI log", level: .info, category: .ui)
        XCTAssertNotNil(logger)
    }

    func testLogToDataCategory() {
        logger.log("Data log", level: .info, category: .data)
        XCTAssertNotNil(logger)
    }

    func testLogToBusinessCategory() {
        logger.log("Business log", level: .info, category: .business)
        XCTAssertNotNil(logger)
    }

    func testLogToNetworkCategory() {
        logger.log("Network log", level: .info, category: .network)
        XCTAssertNotNil(logger)
    }

    func testLogToPerformanceCategory() {
        logger.log("Performance log", level: .info, category: .performance)
        XCTAssertNotNil(logger)
    }

    func testLogToAnalysisCategory() {
        logger.log("Analysis log", level: .info, category: .analysis)
        XCTAssertNotNil(logger)
    }

    func testLogToSecurityCategory() {
        logger.log("Security log", level: .info, category: .security)
        XCTAssertNotNil(logger)
    }

    func testLogToAICategory() {
        logger.log("AI log", level: .info, category: .ai)
        XCTAssertNotNil(logger)
    }

    // MARK: - Convenience Method Tests

    func testDebugMethod() {
        logger.debug("Debug convenience method")
        XCTAssertNotNil(logger)
    }

    func testLogWarningMethod() {
        logger.logWarning("Warning convenience method")
        XCTAssertNotNil(logger)
    }

    func testLogErrorMethod() {
        let error = NSError(
            domain: "TestDomain",
            code: 100,
            userInfo: [NSLocalizedDescriptionKey: "Test error"]
        )

        logger.logError(error, context: "Test context")
        XCTAssertNotNil(logger)
    }

    func testLogErrorWithoutContext() {
        let error = NSError(domain: "TestDomain", code: 200)
        logger.logError(error)
        XCTAssertNotNil(logger)
    }

    // MARK: - Default Parameter Tests

    func testLogWithDefaultLevel() {
        logger.log("Message with default level")
        XCTAssertNotNil(logger)
    }

    func testLogWithDefaultCategory() {
        logger.log("Message with default category", level: .info)
        XCTAssertNotNil(logger)
    }

    func testLogWithAllDefaults() {
        logger.log("Message with all defaults")
        XCTAssertNotNil(logger)
    }

    // MARK: - Edge Case Tests

    func testLogEmptyString() {
        logger.log("", level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogVeryLongString() {
        let longString = String(repeating: "A", count: 10000)
        logger.log(longString, level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogSpecialCharacters() {
        logger.log("Special chars: \n\t\r\\\"'", level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    func testLogUnicode() {
        logger.log("Unicode: 🚀 💰 ✅ 🎉", level: .info, category: .general)
        XCTAssertNotNil(logger)
    }

    // MARK: - Concurrent Logging Tests

    func testConcurrentLogging() async {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { @MainActor in
                    self.logger.log("Concurrent log \(i)", level: .info, category: .general)
                }
            }
        }

        XCTAssertNotNil(logger)
    }

    func testMultipleCategoriesConcurrently() async {
        let categories: [AppLogger.LogCategory] = [
            .general, .ui, .data, .business, .network, .performance,
        ]

        await withTaskGroup(of: Void.self) { group in
            for category in categories {
                group.addTask { @MainActor in
                    self.logger.log("Test", level: .info, category: category)
                }
            }
        }

        XCTAssertNotNil(logger)
    }

    // MARK: - Integration Tests

    func testCompleteLoggingWorkflow() {
        // Debug
        logger.debug("Starting workflow")

        // Info
        logger.log("Processing data", level: .info, category: .data)

        // Warning
        logger.logWarning("Potential issue detected")

        // Error
        let error = NSError(domain: "WorkflowDomain", code: 1)
        logger.logError(error, context: "During processing")

        // Critical
        logger.log("Critical failure", level: .critical, category: .business)

        XCTAssertNotNil(logger)
    }

    func testAllLogLevelsInAllCategories() {
        let levels: [AppLogger.LogLevel] = [.debug, .info, .warning, .error, .critical]
        let categories: [AppLogger.LogCategory] = [
            .general, .analysis, .performance, .security,
            .ui, .ai, .network, .data, .business,
        ]

        for level in levels {
            for category in categories {
                logger.log("Test message", level: level, category: category)
            }
        }

        XCTAssertNotNil(logger)
    }

    // MARK: - MainActor Isolation Tests

    func testMainActorIsolation() {
        Task { @MainActor in
            let logger = AppLogger.shared
            logger.debug("Main actor test")
            XCTAssertNotNil(logger)
        }
    }

    // MARK: - Performance Tests

    func testLoggingPerformance() {
        measure {
            for i in 0..<1000 {
                logger.log("Performance test \(i)", level: .info, category: .performance)
            }
        }
    }

    func testDebugMethodPerformance() {
        measure {
            for i in 0..<1000 {
                logger.debug("Debug performance \(i)")
            }
        }
    }
}
