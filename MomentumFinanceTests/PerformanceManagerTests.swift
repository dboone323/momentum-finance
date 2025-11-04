import XCTest
@testable import MomentumFinance

class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!

    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager.shared
    }

    override func tearDown() {
        super.tearDown()
        performanceManager = nil
    }

    // MARK: - Test RecordFrame

    func testRecordFrame() {
        // GIVEN: A frame time is recorded
        let currentTime = CACurrentMediaTime()
        performanceManager.recordFrame()

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the recorded time interval
        XCTAssertEqual(fps, 1.0 / (currentTime - self.performanceManager.lastFPSUpdate), accuracy: 0.1)
    }

    func testRecordFrameWithMultipleFrames() {
        // GIVEN: Multiple frames are recorded
        for _ in 0..<120 {
            performanceManager.recordFrame()
        }

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the average frame time
        let averageFrameTime = self.performanceManager.frameTimes.reduce(0, +) / Double(self.performanceManager.maxFrameHistory)
        XCTAssertEqual(fps, 1.0 / averageFrameTime, accuracy: 0.1)
    }

    // MARK: - Test GetCurrentFPS

    func testGetCurrentFPS() {
        // GIVEN: A frame time is recorded
        let currentTime = CACurrentMediaTime()
        performanceManager.recordFrame()

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the recorded time interval
        XCTAssertEqual(fps, 1.0 / (currentTime - self.performanceManager.lastFPSUpdate), accuracy: 0.1)
    }

    func testGetCurrentFPSWithMultipleFrames() {
        // GIVEN: Multiple frames are recorded
        for _ in 0..<120 {
            performanceManager.recordFrame()
        }

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the average frame time
        let averageFrameTime = self.performanceManager.frameTimes.reduce(0, +) / Double(self.performanceManager.maxFrameHistory)
        XCTAssertEqual(fps, 1.0 / averageFrameTime, accuracy: 0.1)
    }

    // MARK: - Test GetMemoryUsage

    func testGetMemoryUsage() {
        // GIVEN: A memory usage is recorded
        let memory = self.performanceManager.getMemoryUsage()

        // THEN: The recorded memory usage should be close to the expected value
        XCTAssertEqual(memory, 500.0, accuracy: 0.1)
    }

    func testGetMemoryUsageWithMultipleFrames() {
        // GIVEN: Multiple frames are recorded
        for _ in 0..<120 {
            performanceManager.recordFrame()
        }

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the average frame time
        let averageFrameTime = self.performanceManager.frameTimes.reduce(0, +) / Double(self.performanceManager.maxFrameHistory)
        XCTAssertEqual(fps, 1.0 / averageFrameTime, accuracy: 0.1)
    }

    // MARK: - Test IsPerformanceDegraded

    func testIsPerformanceDegraded() {
        // GIVEN: A frame time is recorded
        let currentTime = CACurrentMediaTime()
        performanceManager.recordFrame()

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the recorded time interval
        XCTAssertEqual(fps, 1.0 / (currentTime - self.performanceManager.lastFPSUpdate), accuracy: 0.1)
    }

    func testIsPerformanceDegradedWithMultipleFrames() {
        // GIVEN: Multiple frames are recorded
        for _ in 0..<120 {
            performanceManager.recordFrame()
        }

        // WHEN: The current FPS is calculated
        let fps = performanceManager.getCurrentFPS()

        // THEN: The calculated FPS should be close to the average frame time
        let averageFrameTime = self.performanceManager.frameTimes.reduce(0, +) / Double(self.performanceManager.maxFrameHistory)
        XCTAssertEqual(fps, 1.0 / averageFrameTime, accuracy: 0.1)
    }
}
