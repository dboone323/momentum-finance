import XCTest
import LocalAuthentication
@testable import MomentumFinance

@MainActor
final class MockLAContext: LAContextProtocol {
    var shouldSucceed: Bool = true
    var shouldAllowEvaluation: Bool = true
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return shouldAllowEvaluation
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping @Sendable (Bool, Error?) -> Void) {
        reply(shouldSucceed, nil)
    }
}

@MainActor
final class BiometricAuthManagerTests: XCTestCase {
    var manager: BiometricAuthManager!
    var mockContext: MockLAContext!
    
    override func setUp() {
        super.setUp()
        mockContext = MockLAContext()
        manager = BiometricAuthManager(context: mockContext)
    }
    
    func testAuthenticate_Success() {
        let expectation = XCTestExpectation(description: "Auth success")
        mockContext.shouldSucceed = true
        
        // Observe internal state change
        let cancellable = manager.$isAuthenticated.sink { isAuthenticated in
            if isAuthenticated {
                expectation.fulfill()
            }
        }
        
        manager.authenticate()
        
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    func testAuthenticate_Failure() {
        mockContext.shouldSucceed = false
        manager.authenticate()
        
        // Wait briefly to ensure no state change happens logic
        let expectation = XCTestExpectation(description: "No change")
        expectation.isInverted = true
        
        let cancellable = manager.$isAuthenticated.sink { isAuthenticated in
            if isAuthenticated {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.2)
        XCTAssertFalse(manager.isAuthenticated)
        cancellable.cancel()
    }
}
