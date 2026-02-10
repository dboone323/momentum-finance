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
            Category(name: "Food & Dining", colorHex: "#FF9500", iconName: "fork.knife", type: .expense, isDefault: true),
            Category(name: "Transportation", colorHex: "#007AFF", iconName: "car.fill", type: .expense, isDefault: true),
            Category(name: "Shopping", colorHex: "#AF52DE", iconName: "bag.fill", type: .expense, isDefault: true),
            Category(name: "Entertainment", colorHex: "#FF3B30", iconName: "gamecontroller.fill", type: .expense, isDefault: true),
            Category(name: "Bills & Utilities", colorHex: "#34C759", iconName: "house.fill", type: .expense, isDefault: true),
            Category(name: "Healthcare", colorHex: "#FF2D55", iconName: "heart.fill", type: .expense, isDefault: true),
            Category(name: "Education", colorHex: "#5AC8FA", iconName: "book.fill", type: .expense, isDefault: true),
            Category(name: "Travel", colorHex: "#FFCC00", iconName: "airplane", type: .expense, isDefault: true),
            Category(name: "Personal Care", colorHex: "#FF6B9E", iconName: "person.fill", type: .expense, isDefault: true),
            Category(name: "Other", colorHex: "#8E8E93", iconName: "circle.fill", type: .expense, isDefault: true)
        ]
    }

    /// Default income categories
    public static var defaultIncomeCategories: [Category] {
        [
            Category(name: "Salary", colorHex: "#34C759", iconName: "briefcase.fill", type: .income, isDefault: true),
            Category(name: "Freelance", colorHex: "#5AC8FA", iconName: "person.2.fill", type: .income, isDefault: true),
            Category(name: "Business", colorHex: "#AF52DE", iconName: "building.2.fill", type: .income, isDefault: true),
            Category(name: "Investments", colorHex: "#FF9500", iconName: "chart.line.uptrend.xyaxis", type: .income, isDefault: true),
            Category(name: "Gifts", colorHex: "#FF3B30", iconName: "gift.fill", type: .income, isDefault: true),
            Category(name: "Other", colorHex: "#8E8E93", iconName: "circle.fill", type: .income, isDefault: true)
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