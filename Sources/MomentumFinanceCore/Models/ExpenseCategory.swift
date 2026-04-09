import Foundation
#if canImport(SwiftData)
    import SwiftData
#endif

/// Category types for different financial contexts
public enum CategoryType: String, Codable, CaseIterable, Sendable {
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
        case .expense: "#FF3B30"
        case .income: "#34C759"
        case .transfer: "#007AFF"
        case .savings: "#FF9500"
        case .investment: "#AF52DE"
        }
    }

    public var defaultIconName: String {
        switch self {
        case .expense: "arrow.up.circle.fill"
        case .income: "arrow.down.circle.fill"
        case .transfer: "arrow.left.arrow.right.circle.fill"
        case .savings: "banknote.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        }
    }
}

#if canImport(SwiftData)
    @Model
#endif
public final class ExpenseCategory: Hashable, Encodable {
    enum CodingKeys: String, CodingKey {
        case id, name, categoryDescription, colorHex, iconName, type, isDefault, createdDate, lastModifiedDate
    }

    public var id: UUID
    public var name: String
    public var categoryDescription: String?
    public var colorHex: String
    public var iconName: String
    public var type: CategoryType
    public var isDefault: Bool
    public var createdDate: Date
    public var lastModifiedDate: Date

    #if canImport(SwiftData)
        @Relationship(deleteRule: .nullify, inverse: \ExpenseCategory.subcategories)
        public var parentCategory: ExpenseCategory?
        
        public var subcategories: [ExpenseCategory] = []

        @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.category)
        public var transactions: [FinancialTransaction] = []
    #else
        public var parentCategory: ExpenseCategory?
        public var subcategories: [ExpenseCategory] = []
        public var transactions: [FinancialTransaction] = []
    #endif

    public init(
        id: UUID = UUID(),
        name: String,
        categoryDescription: String? = nil,
        colorHex: String = "#007AFF",
        iconName: String = "tag",
        type: CategoryType = .expense,
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
        self.type = type
        self.isDefault = isDefault
        #if canImport(SwiftData)
            self.parentCategory = parentCategory
        #endif
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(categoryDescription, forKey: .categoryDescription)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(type, forKey: .type)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }

    /// Hierarchy Helpers
    public var isTopLevel: Bool {
        #if canImport(SwiftData)
            return parentCategory == nil
        #else
            return true
        #endif
    }

    public var allDescendants: [ExpenseCategory] {
        #if canImport(SwiftData)
            var descendants = subcategories
            for subcategory in subcategories {
                descendants.append(contentsOf: subcategory.allDescendants)
            }
            return descendants
        #else
            return []
        #endif
    }

    public var fullPath: String {
        #if canImport(SwiftData)
            if let parent = parentCategory {
                return "\(parent.fullPath) > \(name)"
            }
        #endif
        return name
    }

    /// Spending Calculations
    public func totalSpent(for month: Date) -> Decimal {
        let calendar = Calendar.current
        let monthComponents = calendar.dateInterval(of: .month, for: month)
        guard let startOfMonth = monthComponents?.start, let endOfMonth = monthComponents?.end
        else { return 0 }
        
        return transactions
            .filter { $0.transactionType == .expense }
            .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    public func totalSpentWithSubcategories(for month: Date) -> Decimal {
        let ownTotal = totalSpent(for: month)
        let subcategoryTotal = allDescendants.reduce(0) { $0 + $1.totalSpent(for: month) }
        return ownTotal + subcategoryTotal
    }
}

public extension ExpenseCategory {
    static var defaultCategories: [ExpenseCategory] {
        defaultExpenseCategories
    }

    static var defaultExpenseCategories: [ExpenseCategory] {
        [
            ExpenseCategory(name: "Food & Dining", colorHex: "#FF9500", iconName: "fork.knife", type: .expense, isDefault: true),
            ExpenseCategory(name: "Transportation", colorHex: "#007AFF", iconName: "car.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Shopping", colorHex: "#AF52DE", iconName: "bag.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Entertainment", colorHex: "#FF3B30", iconName: "gamecontroller.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Bills & Utilities", colorHex: "#34C759", iconName: "house.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Healthcare", colorHex: "#FF2D55", iconName: "heart.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Education", colorHex: "#5AC8FA", iconName: "book.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Travel", colorHex: "#FFCC00", iconName: "airplane", type: .expense, isDefault: true),
            ExpenseCategory(name: "Personal Care", colorHex: "#FF6B9E", iconName: "person.fill", type: .expense, isDefault: true),
            ExpenseCategory(name: "Other", colorHex: "#8E8E93", iconName: "tag", type: .expense, isDefault: true)
        ]
    }

    static var defaultIncomeCategories: [ExpenseCategory] {
        [
            ExpenseCategory(name: "Salary", colorHex: "#34C759", iconName: "briefcase.fill", type: .income, isDefault: true),
            ExpenseCategory(name: "Freelance", colorHex: "#5AC8FA", iconName: "person.2.fill", type: .income, isDefault: true),
            ExpenseCategory(name: "Business", colorHex: "#AF52DE", iconName: "building.2.fill", type: .income, isDefault: true),
            ExpenseCategory(name: "Investments", colorHex: "#FF9500", iconName: "chart.line.uptrend.xyaxis", type: .income, isDefault: true),
            ExpenseCategory(name: "Gifts", colorHex: "#FF3B30", iconName: "gift.fill", type: .income, isDefault: true),
            ExpenseCategory(name: "Other", colorHex: "#8E8E93", iconName: "tag", type: .income, isDefault: true)
        ]
    }

    static var sample: ExpenseCategory {
        ExpenseCategory(name: "Groceries", colorHex: "#FF9500", iconName: "cart.fill", type: .expense)
    }

    static var sampleIncome: ExpenseCategory {
        ExpenseCategory(name: "Salary", colorHex: "#34C759", iconName: "briefcase.fill", type: .income, isDefault: true)
    }
}

