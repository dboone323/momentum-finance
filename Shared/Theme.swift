import Foundation
import MomentumFinanceCore
import SwiftUI

/// Platform color helpers (now internal for cross-file use)
func platformBackgroundColor() -> Color {
    #if os(iOS)
        return Color(.systemBackground)
    #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
    #else
        return Color.white
    #endif
}

func platformGrayColor() -> Color {
    #if os(iOS)
        return Color(.systemGray6)
    #elseif os(macOS)
        return Color.gray.opacity(0.2)
    #else
        return Color.gray.opacity(0.2)
    #endif
}

func platformSecondaryGrayColor() -> Color {
    #if os(iOS)
        return Color(.systemGray5)
    #elseif os(macOS)
        return Color.gray.opacity(0.15)
    #else
        return Color.gray.opacity(0.15)
    #endif
}

public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {
    case light, dark, system
    public var id: String { rawValue }
    var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }

    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        case .system: "gearshape.fill"
        }
    }
}

public enum DarkModePreference: String, CaseIterable {
    case system, light, dark
    var displayName: String { rawValue.capitalized }
}
