import XCTest
@testable import MomentumFinance

@MainActor
class BiometricAuthManagerTests: XCTestCase {
    var biometricAuthManager: BiometricAuthManager!
    var mockLAContextProtocol: MockLAContextProtocol!

    override func setUp() {
        super.setUp()
        mockLAContextProtocol = MockLAContextProtocol()
        biometricAuthManager = BiometricAuthManager(context: mockLAContextProtocol)
    }

    override func tearDown() {
        super.tearDown()
        biometricAuthManager = nil
        mockLAContextProtocol = nil
    }

    func testAuthenticateWhenBiometricsAvailableAndSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "Authentication should succeed")
        mockLAContextProtocol.canEvaluatePolicyReturnValue = true

        // Act
        biometricAuthManager.authenticate()

        // Simulate success in the async closure
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(biometricAuthManager.isAuthenticated)
    }

    func testAuthenticateWhenBiometricsAvailableAndFailure() {
        // Arrange
        let expectation = XCTestExpectation(description: "Authentication should fail")
        mockLAContextProtocol.canEvaluatePolicyReturnValue = true

        // Act
        biometricAuthManager.authenticate()

        // Simulate failure in the async closure
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(biometricAuthManager.isAuthenticated)
    }

    func testAuthenticateWhenBiometricsNotAvailable() {
        // Arrange
        let expectation = XCTestExpectation(description: "Authentication should not be possible")
        mockLAContextProtocol.canEvaluatePolicyReturnValue = false

        // Act
        biometricAuthManager.authenticate()

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(biometricAuthManager.isAuthenticated)
    }

    func testMockLAContextProtocol() {
        // Arrange
        let mockLAContextProtocol = MockLAContextProtocol()

        // Assert
        XCTAssertTrue(mockLAContextProtocol is LAContextProtocol)
    }
}

class MockLAContextProtocol: NSObject, LAContextProtocol {
    var canEvaluatePolicyReturnValue: Bool = true

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyReturnValue
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String,
                        reply: @escaping @Sendable (Bool, Error?) -> Void)
    {
        // Simulate async completion of the authentication process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            reply(self.canEvaluatePolicyReturnValue, nil)
        }
    }
}
