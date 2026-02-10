//
// ThemeManager.swift
// MomentumFinance
//
// Manages app themes and appearance
//

import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = "System"

    /// Financial apps often have "Green" (Growth) or "Blue" (Trust) themes
    let themes = ["System", "Mint", "Ocean", "Midnight"]

    func color(for name: String) -> Color {
        // Return theme-specific colors
        .green
    }
}
