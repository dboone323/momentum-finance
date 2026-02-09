//
//  Category.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation

/// General category type for transactions and other financial items
public struct Category: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var colorHex: String
    public var iconName: String
    public var type: CategoryType
    public var isDefault: Bool
    public var parentId: UUID?
    public var createdDate: Date
    public var lastModifiedDate: Date

    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        colorHex: String = "#007AFF",
        iconName: String = "circle.fill",
        type: CategoryType,
        isDefault: Bool = false,
        parentId: UUID? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.iconName = iconName
        self.type = type
        self.isDefault = isDefault
        self.parentId = parentId
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Check if this is a top-level category
    public var isTopLevel: Bool {
        parentId == nil
    }

    /// Create a copy with modified properties
    public func copy(
        name: String? = nil,
        description: String? = nil,
        colorHex: String? = nil,
        iconName: String? = nil,
        type: CategoryType? = nil
    ) -> Category {
        Category(
            id: id,
            name: name ?? self.name,
            description: description ?? self.description,
            colorHex: colorHex ?? self.colorHex,
            iconName: iconName ?? self.iconName,
            type: type ?? self.type,
            isDefault: isDefault,
            parentId: parentId,
            createdDate: createdDate,
            lastModifiedDate: Date()
        )
    }
}

/// Category types for different financial contexts
public enum CategoryType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    case transfer = "Transfer"
    case savings = "Savings"
    case investment = "Investment"

    public var displayName: String {
        rawValue
    }

    public var defaultColorHex: String {
        switch self {
        case .expense: return "#FF3B30" // Red
        case .income: return "#34C759" // Green
        case .transfer: return "#007AFF" // Blue
        case .savings: return "#FF9500" // Orange
        case .investment: return "#AF52DE" // Purple
        }
    }

    public var defaultIconName: String {
        switch self {
        case .expense: return "arrow.up.circle.fill"
        case .income: return "arrow.down.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        case .savings: return "banknote.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }
}

extension Category {
    /// Default expense categories
    public static var defaultExpenseCategories: [Category] {
        [
            Category(name: "Food & Dining", type: .expense, colorHex: "#FF9500", iconName: "fork.knife", isDefault: true),
            Category(name: "Transportation", type: .expense, colorHex: "#007AFF", iconName: "car.fill", isDefault: true),
            Category(name: "Shopping", type: .expense, colorHex: "#AF52DE", iconName: "bag.fill", isDefault: true),
            Category(name: "Entertainment", type: .expense, colorHex: "#FF3B30", iconName: "gamecontroller.fill", isDefault: true),
            Category(name: "Bills & Utilities", type: .expense, colorHex: "#34C759", iconName: "house.fill", isDefault: true),
            Category(name: "Healthcare", type: .expense, colorHex: "#FF2D55", iconName: "heart.fill", isDefault: true),
            Category(name: "Education", type: .expense, colorHex: "#5AC8FA", iconName: "book.fill", isDefault: true),
            Category(name: "Travel", type: .expense, colorHex: "#FFCC00", iconName: "airplane", isDefault: true),
            Category(name: "Personal Care", type: .expense, colorHex: "#FF6B9E", iconName: "person.fill", isDefault: true),
            Category(name: "Other", type: .expense, colorHex: "#8E8E93", iconName: "circle.fill", isDefault: true)
        ]
    }

    /// Default income categories
    public static var defaultIncomeCategories: [Category] {
        [
            Category(name: "Salary", type: .income, colorHex: "#34C759", iconName: "briefcase.fill", isDefault: true),
            Category(name: "Freelance", type: .income, colorHex: "#5AC8FA", iconName: "person.2.fill", isDefault: true),
            Category(name: "Business", type: .income, colorHex: "#AF52DE", iconName: "building.2.fill", isDefault: true),
            Category(name: "Investments", type: .income, colorHex: "#FF9500", iconName: "chart.line.uptrend.xyaxis", isDefault: true),
            Category(name: "Gifts", type: .income, colorHex: "#FF3B30", iconName: "gift.fill", isDefault: true),
            Category(name: "Other", type: .income, colorHex: "#8E8E93", iconName: "circle.fill", isDefault: true)
        ]
    }

    /// Sample data for previews and testing
    public static var sampleExpense: Category {
        Category(
            name: "Groceries",
            description: "Weekly grocery shopping",
            colorHex: "#FF9500",
            iconName: "cart.fill",
            type: .expense,
            isDefault: false
        )
    }

    public static var sampleIncome: Category {
        Category(
            name: "Salary",
            description: "Monthly salary payment",
            colorHex: "#34C759",
            iconName: "briefcase.fill",
            type: .income,
            isDefault: true
        )
    }
}