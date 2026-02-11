import XCTest
@testable import MomentumFinance

class DependenciesTests: XCTestCase {

    var dependencies: Dependencies!

    override func setUp() {
        super.setUp()
        // Initialize dependencies with mocks if needed
        let mockPerformanceManager = MockPerformanceManager()
        let mockLogger = MockLogger()
        dependencies = Dependencies(performanceManager: mockPerformanceManager, logger: mockLogger)
    }

    override func tearDown() {
        super.tearDown()
        // Clean up any resources or reset any state
        dependencies = nil
    }

    func testPerformanceManagerInitialization() {
        XCTAssertEqual(dependencies.performanceManager, PerformanceManager.shared)
    }

    func testLoggerInitialization() {
        XCTAssertEqual(dependencies.logger, Logger.shared)
    }

    func testLoggingMethods() {
        // Mock the output handler for testing
        dependencies.logger.setOutputHandler { message in
            XCTAssertEqual(message, "[2023-10-05T12:34:56.789Z] [INFO] Test log message")
        }

        dependencies.logger.info("Test log message")
    }

    func testLogLevelConversion() {
        let mockLogger = MockLogger()
        XCTAssertEqual(
            mockLogger.formattedMessage("Test message", level: .info),
            "[2023-10-05T12:34:56.789Z] [INFO] Test message"
        )
        XCTAssertEqual(
            mockLogger.formattedMessage("Test warning", level: .warning),
            "[2023-10-05T12:34:56.789Z] [WARNING] Test warning"
        )
        XCTAssertEqual(
            mockLogger.formattedMessage("Test error", level: .error),
            "[2023-10-05T12:34:56.789Z] [ERROR] Test error"
        )
    }

    func testOutputHandlerReset() {
        // Mock the output handler for testing
        dependencies.logger.setOutputHandler { message in
            XCTAssertEqual(message, "Test log message")
        }

        dependencies.logger.resetOutputHandler()

        // This should not cause any assertion failure
        dependencies.logger.log("This is a reset test")
    }
}

/// Mock classes to be used during testing
class MockPerformanceManager: PerformanceManager {
    override func recordFrame() {}
    override func getCurrentFPS() -> Double { 0.0 }
    override func getCurrentFPS(completion: @escaping (Double) -> Void) {}
    override func getMemoryUsage() -> Double { 0.0 }
    override func getMemoryUsage(completion: @escaping (Double) -> Void) {}
    override func isPerformanceDegraded() -> Bool { false }
    override func isPerformanceDegraded(completion: @escaping (Bool) -> Void) {}
}

class MockLogger: Logger {
    override func logSync(_ message: String, level: LogLevel = .info) {
        super.logSync(message, level: level)
    }

    override var formattedMessage: ((String, LogLevel) -> String)? { nil }
}
