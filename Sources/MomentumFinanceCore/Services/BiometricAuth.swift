//
// BiometricAuth.swift
// MomentumFinance
//
// Service for FaceID/TouchID authentication
//

import LocalAuthentication

@MainActor class BiometricAuth: ObservableObject {
    @MainActor static let shared = BiometricAuth()
    @Published var isUnlocked = false

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your financial data"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                }
            }
        } else {
            // No biometrics available
            self.isUnlocked = true // Fallback for simulator/testing
        }
    }

    func lock() {
        isUnlocked = false
    }
}
