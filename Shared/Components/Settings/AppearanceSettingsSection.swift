import SwiftUI

public struct AppearanceSettingsSection: View {
    var darkModePreference: DarkModePreference

    public var body: some View {
        Section {
            Picker("Theme", selection: .constant(self.darkModePreference)) {
                ForEach(DarkModePreference.allCases, id: \.self) { preference in
                    Text(preference.displayName).tag(preference)
                }
            }
            .pickerStyle(.menu)
            .disabled(true)  // For now, just display current preference
        } header: {
            Text("Appearance")
        }
    }
}
