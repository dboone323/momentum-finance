//
//  ExpenseCategory.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2026-02-09.
//

import Foundation
import SwiftData

@Model
public final class ExpenseCategory {
    public var id: UUID
    public var name: String
    public var categoryDescription: String?
    public var colorHex: String
    public var iconName: String
    public var isDefault: Bool
    public var parentCategory: ExpenseCategory?
    public var createdDate: Date
    public var lastModifiedDate: Date

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \ExpenseCategory.parentCategory)
    public var subcategories: [ExpenseCategory] = []

    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.expenseCategory)
    public var transactions: [FinancialTransaction] = []

    public init(
        id: UUID = UUID(),
        name: String,
        categoryDescription: String? = nil,
        colorHex: String = "#007AFF",
        iconName: String = "circle.fill",
        isDefault: Bool = false,
        parentCategory: ExpenseCategory? = nil,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.categoryDescription = categoryDescription
        self.colorHex = colorHex
        self.iconName = iconName
        self.isDefault = isDefault
        self.parentCategory = parentCategory
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    /// Check if this is a top-level category (no parent)
    public var isTopLevel: Bool {
        parentCategory == nil
    }

    /// Get all descendant categories (recursive)
    public var allDescendants: [ExpenseCategory] {
        var descendants = subcategories
        for subcategory in subcategories {
            descendants.append(contentsOf: subcategory.allDescendants)
        }
        return descendants
    }

    /// Calculate total spent in this category for a given date range
    public func totalSpent(in dateRange: ClosedRange<Date>? = nil) -> Double {
        let relevantTransactions = transactions.filter { transaction in
            if let dateRange {
                return dateRange.contains(transaction.date)
            }
            return true
        }
        return relevantTransactions.reduce(0) { $0 + $1.amount }
    }

    /// Calculate total spent in this category and all subcategories
    public func totalSpentWithSubcategories(in dateRange: ClosedRange<Date>? = nil) -> Double {
        let ownTotal = totalSpent(in: dateRange)
        let subcategoryTotal = allDescendants.reduce(0) { $0 + $1.totalSpent(in: dateRange) }
        return ownTotal + subcategoryTotal
    }

    /// Get transaction count for this category
    public var transactionCount: Int {
        transactions.count
    }

    /// Get the full category path (e.g., "Food > Groceries")
    public var fullPath: String {
        if let parent = parentCategory {
            return "\(parent.fullPath) > \(name)"
        }
        return name
    }

    /// Create a subcategory
    public func createSubcategory(
        name: String,
        description: String? = nil,
        colorHex: String? = nil,
        iconName: String? = nil
    ) -> ExpenseCategory {
        ExpenseCategory(
            name: name,
            categoryDescription: description,
            colorHex: colorHex ?? self.colorHex,
            iconName: iconName ?? self.iconName,
            parentCategory: self
        )
    }
}

/// Default expense categories
public extension ExpenseCategory {
    static var defaultCategories: [ExpenseCategory] {
        [
            ExpenseCategory(
                name: "Food & Dining",
                categoryDescription: "Restaurants, groceries, and food delivery",
                colorHex: "#FF9500",
                iconName: "fork.knife",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Transportation",
                categoryDescription: "Gas, public transit, rideshare, and vehicle maintenance",
                colorHex: "#007AFF",
                iconName: "car.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Shopping",
                categoryDescription: "Clothing, electronics, and general purchases",
                colorHex: "#AF52DE",
                iconName: "bag.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Entertainment",
                categoryDescription: "Movies, games, concerts, and hobbies",
                colorHex: "#FF3B30",
                iconName: "gamecontroller.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Bills & Utilities",
                categoryDescription: "Rent, electricity, water, internet, and phone",
                colorHex: "#34C759",
                iconName: "house.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Healthcare",
                categoryDescription: "Medical bills, insurance, and pharmacy",
                colorHex: "#FF2D55",
                iconName: "heart.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Education",
                categoryDescription: "Tuition, books, courses, and training",
                colorHex: "#5AC8FA",
                iconName: "book.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Travel",
                categoryDescription: "Flights, hotels, and vacation expenses",
                colorHex: "#FFCC00",
                iconName: "airplane",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Personal Care",
                categoryDescription: "Haircuts, cosmetics, and personal grooming",
                colorHex: "#FF6B9E",
                iconName: "person.fill",
                isDefault: true
            ),
            ExpenseCategory(
                name: "Other",
                categoryDescription: "Miscellaneous expenses",
                colorHex: "#8E8E93",
                iconName: "circle.fill",
                isDefault: true
            ),
        ]
    }

    /// Sample data for previews and testing
    static var sample: ExpenseCategory {
        ExpenseCategory(
            name: "Groceries",
            categoryDescription: "Weekly grocery shopping",
            colorHex: "#FF9500",
            iconName: "cart.fill",
            isDefault: false
        )
    }
}
