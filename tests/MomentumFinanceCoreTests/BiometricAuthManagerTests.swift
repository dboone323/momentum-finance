import XCTest
import LocalAuthentication
@testable import MomentumFinanceCore

@MainActor
class BiometricAuthManagerTests: XCTestCase {
    var biometricAuthManager: BiometricAuthManager!

    override func setUp() async throws {
        try await super.setUp()
        biometricAuthManager = BiometricAuthManager.shared
    }

    override func tearDown() async throws {
        biometricAuthManager = nil
        try await super.tearDown()
    }


    func testBiometricAvailability() {
        // We can't easily mock behavior without context injection, 
        // but we can at least verify the property exists and is accessible.
        _ = biometricAuthManager.isBiometricAvailable
    }
    
    func testBiometricType() {
        _ = biometricAuthManager.biometricType
    }
}


