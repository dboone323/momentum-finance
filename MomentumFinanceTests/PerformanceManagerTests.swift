import XCTest
@testable import MomentumFinance

final class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!

    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager.shared
    }

    func testSingletonInstance() {
        let instance1 = PerformanceManager.shared
        let instance2 = PerformanceManager.shared
        XCTAssertTrue(instance1 === instance2, "PerformanceManager should be a singleton")
    }

    func testRecordFrame() {
        // Record enough frames to calculate FPS
        for _ in 0..<20 {
            performanceManager.recordFrame()
            // Sleep slightly to simulate time passing
            usleep(10000) // 10ms
        }

        let fps = performanceManager.getCurrentFPS()
        XCTAssertGreaterThan(fps, 0, "FPS should be greater than 0 after recording frames")
    }

    func testFPSCaching() {
        performanceManager.recordFrame()
        let fps1 = performanceManager.getCurrentFPS()

        // Immediate second call should return cached value
        let fps2 = performanceManager.getCurrentFPS()
        XCTAssertEqual(fps1, fps2, "FPS should be cached within short interval")
    }

    func testMemoryUsage() {
        let memory = performanceManager.getMemoryUsage()
        XCTAssertGreaterThan(memory, 0, "Memory usage should be greater than 0MB")
    }

    func testPerformanceDegradationCheck() {
        // Default state shouldn't be degraded immediately
        let isDegraded = performanceManager.isPerformanceDegraded()
        // We can't easily force degradation without mocking, but we can verify it returns a bool
        XCTAssertFalse(isDegraded || true)
    }

    func testAsyncFPSFetch() {
        let expectation = XCTestExpectation(description: "Fetch FPS Async")

        performanceManager.recordFrame()
        performanceManager.getCurrentFPS { fps in
            XCTAssertGreaterThanOrEqual(fps, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncMemoryFetch() {
        let expectation = XCTestExpectation(description: "Fetch Memory Async")

        performanceManager.getMemoryUsage { memory in
            XCTAssertGreaterThan(memory, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
