import Foundation
import SwiftData

@Model
public final class FinancialTransaction: Encodable {
    enum CodingKeys: String, CodingKey {
        case title, amount, date, transactionType, notes, isReconciled, isRecurring, location,
             subcategory, category, account, currencyCode
    }

    public var title: String
    public var amount: Decimal
    public var date: Date
    public var transactionType: TransactionType
    public var notes: String?
    public var isReconciled: Bool = false
    public var isRecurring: Bool = false
    public var location: String?
    public var subcategory: String?

    public var category: ExpenseCategory?
    public var account: FinancialAccount?
    public var currencyCode: String = "USD"

    public init(
        title: String,
        amount: Decimal,
        date: Date,
        transactionType: TransactionType,
        notes: String? = nil,
        isReconciled: Bool = false,
        isRecurring: Bool = false,
        location: String? = nil,
        subcategory: String? = nil,
        category: ExpenseCategory? = nil,
        account: FinancialAccount? = nil,
        currencyCode: String? = nil
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
        self.isReconciled = isReconciled
        self.isRecurring = isRecurring
        self.location = location
        self.subcategory = subcategory
        self.category = category
        self.account = account
        self.currencyCode = currencyCode ?? account?.currencyCode ?? "USD"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(transactionType, forKey: .transactionType)
        try container.encode(notes, forKey: .notes)
        try container.encode(isReconciled, forKey: .isReconciled)
        try container.encode(isRecurring, forKey: .isRecurring)
        try container.encode(location, forKey: .location)
        try container.encode(subcategory, forKey: .subcategory)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(account, forKey: .account)
        try container.encode(currencyCode, forKey: .currencyCode)
    }

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        let sign = transactionType == .income ? "+" : "-"
        let formattedValue = formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
        return "\(sign)\(formattedValue)"
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
