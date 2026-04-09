import Foundation
import MomentumFinanceCore

enum AICategorizationService {
    /// Predicts a category based on the transaction title
    static func predictCategory(for title: String, categories: [ExpenseCategory])
        -> ExpenseCategory?
    {
        let normalizedTitle = title.lowercased()

        // Comprehensive keyword mapping for categorization
        let keywords: [String: [String]] = [
            // Food & Dining
            "food": [
                "grocer", "market", "food", "restaurant", "cafe", "coffee",
                "starbucks", "pizza", "burger", "sushi", "pub", "bar",
                "taco", "chipotle", "eats", "dash", "dinner", "lunch", "breakfast",
            ],

            // Transport
            "transportation": [
                "uber",
                "lyft",
                "taxi",
                "bus",
                "train",
                "gas",
                "fuel",
                "shell",
                "bp",
                "chevron",
                "wawa",
                "parking",
                "auto",
                "car",
                "toyota",
                "ford",
                "tesla",
                "subway",
                "metro",
            ],

            // Utilities & Bills
            "utilities": [
                "electric",
                "water",
                "utility",
                "power",
                "internet",
                "wifi",
                "phone",
                "mobile",
                "att",
                "verizon",
                "t-mobile",
                "comcast",
                "xfinity",
                "bill",
                "insurance",
            ],

            // Entertainment
            "entertainment": [
                "netflix",
                "spotify",
                "hulu",
                "disney",
                "prime video",
                "steam",
                "game",
                "movie",
                "cinema",
                "theatre",
                "ticket",
                "event",
                "concert",
                "nintendo",
                "xbox",
                "playstation",
            ],

            // Shopping
            "shopping": [
                "amazon",
                "walmart",
                "target",
                "costco",
                "best buy",
                "apple",
                "store",
                "shop",
                "mall",
                "cloth",
                "shoe",
                "nike",
                "adidas",
            ],

            // Health
            "health": [
                "doctor",
                "pharmacy",
                "cvs",
                "walgreens",
                "rite aid",
                "gym",
                "fitness",
                "yoga",
                "hospital",
                "med",
                "clinic",
                "dentist",
            ],

            // Housing
            "housing": [
                "rent", "mortgage", "home", "apartment", "depot", "lowe's", "ikea", "repair",
                "maintenance",
            ],

            // Travel
            "travel": [
                "hotel",
                "airbnb",
                "flight",
                "airline",
                "delta",
                "united",
                "american",
                "expedia",
                "booking",
                "resort",
                "vacation",
            ],
        ]

        let categoryMap: [String: String] = [
            "food": "food", "grocer": "food", "dining": "food",
            "transport": "transportation", "car": "transportation", "auto": "transportation",
            "util": "utilities", "bill": "utilities",
            "entertain": "entertainment", "fun": "entertainment",
            "shop": "shopping",
            "health": "health", "med": "health", "well": "health",
            "home": "housing", "hous": "housing",
            "travel": "travel", "trip": "travel",
        ]

        // 1. Check heuristics against available categories
        for category in categories {
            let catName = category.name.lowercased()

            // Map category name to rule key using the dictionary
            let matchedKey = categoryMap.first { catName.contains($0.key) }?.value

            // Check if ANY keywords for this category type are present in title
            if let key = matchedKey, let words = keywords[key] {
                if words.contains(where: { normalizedTitle.contains($0) }) {
                    return category
                }
            }

            // 2. Direct name match fallback (if title contains "Groceries", map to Groceries category)
            if normalizedTitle.contains(catName) {
                return category
            }
        }

        return nil
    }
}
