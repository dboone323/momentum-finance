import LocalAuthentication
import SwiftUI

// Enhancement #80: Biometric Auth

@MainActor
protocol LAContextProtocol {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping @Sendable (Bool, Error?) -> Void)
}

extension LAContext: LAContextProtocol {}

@MainActor
class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    private let context: LAContextProtocol

    init(context: LAContextProtocol = LAContext()) {
        self.context = context
    }

    func authenticate() {
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context
                .evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                ) { [weak self] success, _ in
                    DispatchQueue.main.async {
                        if success {
                            self?.isAuthenticated = true
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
