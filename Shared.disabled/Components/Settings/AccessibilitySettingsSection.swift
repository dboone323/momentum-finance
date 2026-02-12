import SwiftUI

public struct AccessibilitySettingsSection: View {
    @Binding var hapticFeedbackEnabled: Bool
    @Binding var reducedMotion: Bool

    public var body: some View {
        Section {
            Toggle("Haptic Feedback", isOn: self.$hapticFeedbackEnabled)
            Toggle("Reduce Motion", isOn: self.$reducedMotion)
        } header: {
            Text("Accessibility")
        }
    }
}
