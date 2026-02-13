//
//  ColorDefinitions.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import MomentumFinanceCore
import SwiftUI

/// Static color definitions for the Momentum Finance theme
public enum ColorDefinitions {
    // MARK: - Background Colors

    public static func background(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            Color(hex: "#FFFFFF")
        case .dark:
            Color(hex: "#1C1C1E")
        }
    }

    public static func secondaryBackground(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            Color(hex: "#F2F2F7")
        case .dark:
            Color(hex: "#2C2C2E")
        }
    }

    public static func groupedBackground(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            Color(hex: "#FFFFFF")
        case .dark:
            Color(hex: "#1C1C1E")
        }
    }

    public static func cardBackground(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            Color(hex: "#FFFFFF")
        case .dark:
            Color(hex: "#2C2C2E")
        }
    }

    // MARK: - Text Colors

    public static func text(_ style: TextStyle, _ scheme: ColorScheme) -> Color {
        switch (style, scheme) {
        case (.primary, .light):
            Color(hex: "#000000")
        case (.primary, .dark):
            Color(hex: "#FFFFFF")
        case (.secondary, .light):
            Color(hex: "#6B6B6B")
        case (.secondary, .dark):
            Color(hex: "#A1A1A1")
        case (.tertiary, .light):
            Color(hex: "#8E8E93")
        case (.tertiary, .dark):
            Color(hex: "#636366")
        }
    }

    // MARK: - Accent Colors

    public static func accent(_ type: AccentType, _ scheme: ColorScheme) -> Color {
        switch (type, scheme) {
        case (.primary, .light):
            Color(hex: "#007AFF")
        case (.primary, .dark):
            Color(hex: "#0A84FF")
        case (.secondary, .light):
            Color(hex: "#5AC8FA")
        case (.secondary, .dark):
            Color(hex: "#64D2FF")
        }
    }

    // MARK: - Financial Colors

    public static func financial(_ type: FinancialType, _ scheme: ColorScheme) -> Color {
        switch (type, scheme) {
        case (.income, .light):
            Color(hex: "#34C759")
        case (.income, .dark):
            Color(hex: "#30D158")
        case (.expense, .light):
            Color(hex: "#FF3B30")
        case (.expense, .dark):
            Color(hex: "#FF453A")
        case (.savings, .light):
            Color(hex: "#007AFF")
        case (.savings, .dark):
            Color(hex: "#0A84FF")
        case (.warning, .light):
            Color(hex: "#FF9500")
        case (.warning, .dark):
            Color(hex: "#FF9F0A")
        case (.critical, .light):
            Color(hex: "#FF3B30")
        case (.critical, .dark):
            Color(hex: "#FF453A")
        }
    }

    // MARK: - Budget Colors

    public static func budget(_ type: BudgetType, _ scheme: ColorScheme) -> Color {
        switch (type, scheme) {
        case (.under, .light):
            Color(hex: "#34C759")
        case (.under, .dark):
            Color(hex: "#30D158")
        case (.near, .light):
            Color(hex: "#FF9500")
        case (.near, .dark):
            Color(hex: "#FF9F0A")
        case (.over, .light):
            Color(hex: "#FF3B30")
        case (.over, .dark):
            Color(hex: "#FF453A")
        }
    }

    // MARK: - Category Colors

    public static let categoryColors: [Color] = [
        Color(hex: "#FF6B6B"), // Red
        Color(hex: "#4ECDC4"), // Teal
        Color(hex: "#45B7D1"), // Blue
        Color(hex: "#96CEB4"), // Green
        Color(hex: "#FFEAA7"), // Yellow
        Color(hex: "#DDA0DD"), // Plum
        Color(hex: "#98D8C8"), // Mint
        Color(hex: "#F7DC6F"), // Gold
        Color(hex: "#BB8FCE"), // Purple
        Color(hex: "#85C1E9"), // Sky Blue
        Color(hex: "#F8C471"), // Orange
        Color(hex: "#82E0AA"),
    ]
}
