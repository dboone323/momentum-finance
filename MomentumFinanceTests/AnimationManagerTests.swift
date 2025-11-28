import XCTest
@testable import MomentumFinance
import SwiftUI

@MainActor
final class AnimationManagerTests: XCTestCase {
    
    var manager: AnimationManager!
    
    override func setUp() async throws {
        try await super.setUp()
        manager = AnimationManager.shared
    }
    
    func testSingleton() {
        let instance1 = AnimationManager.shared
        let instance2 = AnimationManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testAnimationRetrieval() {
        // Test that animations can be retrieved without crashing
        let springAnimation = manager.spring
        let easeInOutAnimation = manager.easeInOut
        
        XCTAssertNotNil(springAnimation)
        XCTAssertNotNil(easeInOutAnimation)
    }
    
    func testCustomAnimationCreation() {
        let customAnimation = manager.custom(duration: 0.5, curve: .easeIn)
        XCTAssertNotNil(customAnimation)
    }
    
    func testAnimationToggle() {
        manager.isReducedMotion = false
        XCTAssertFalse(manager.isReducedMotion)
        
        manager.isReducedMotion = true
        XCTAssertTrue(manager.isReducedMotion)
    }
}
