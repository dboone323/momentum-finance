import XCTest

@testable import MomentumFinance

final class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!

    override func setUp() async throws {
        performanceManager = PerformanceManager()
    }

    override func tearDown() async throws {
        performanceManager = nil
    }

    func testRecordFrame() {
        for _ in 0..<150 {
            performanceManager.recordFrame()
        }
        XCTAssertEqual(performanceManager.frameTimes.count, 120)
    }

    func testGetCurrentFPS() {
        performanceManager.recordFrame()
        let fps = performanceManager.getCurrentFPS()
        XCTAssertGreaterThanOrEqual(fps, 0)
    }

    func testGetCurrentFPSClosure() async throws {
        let expectation = XCTestExpectation(description: "FPS should be calculated")
        performanceManager.getCurrentFPS { fps in
            XCTAssertGreaterThanOrEqual(fps, 0)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testGetMemoryUsage() {
        let memoryUsage = performanceManager.getMemoryUsage()
        XCTAssertGreaterThan(memoryUsage, 0)
    }

    func testGetMemoryUsageClosure() async throws {
        let expectation = XCTestExpectation(description: "Memory usage should be calculated")
        performanceManager.getMemoryUsage { usage in
            XCTAssertGreaterThan(usage, 0)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testIsPerformanceDegraded() {
        for _ in 0..<35 {
            performanceManager.recordFrame()
        }
        let isDegraded = performanceManager.isPerformanceDegraded()
        XCTAssertFalse(isDegraded, "Should not be degraded with FPS above threshold")
    }

    func testIsPerformanceDegradedWithLowFPS() {
        for _ in 0..<5 {
            performanceManager.recordFrame()
        }
        let isDegraded = performanceManager.isPerformanceDegraded()
        XCTAssertTrue(isDegraded, "Should be degraded with FPS below threshold")
    }

    func testIsPerformanceDegradedClosure() async throws {
        for _ in 0..<35 {
            performanceManager.recordFrame()
        }
        let expectation = XCTestExpectation(description: "Performance degradation check should complete")
        performanceManager.isPerformanceDegraded { isDegraded in
            XCTAssertFalse(isDegraded, "Should not be degraded with FPS above threshold")
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testIsPerformanceDegradedWithLowFPSClosure() async throws {
        for _ in 0..<5 {
            performanceManager.recordFrame()
        }
        let expectation = XCTestExpectation(description: "Performance degradation check should complete")
        performanceManager.isPerformanceDegraded { isDegraded in
            XCTAssertTrue(isDegraded, "Should be degraded with FPS below threshold")
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
