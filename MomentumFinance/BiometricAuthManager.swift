
import LocalAuthentication
import SwiftUI

// Enhancement #80: Biometric Auth
class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        // authentication did not happen
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
}
