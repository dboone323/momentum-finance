import SnapshotTesting
import XCTest
@testable import MomentumFinance

final class SnapshotSmokeTests: XCTestCase {
    func testLineSnapshotIntegration() {
        let baseline = "momentum|dashboard|baseline-v1"
        assertSnapshot(of: baseline, as: .lines, record: false)
    }
}
