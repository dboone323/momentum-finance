import Foundation
import Intents

/// Siri Shortcuts integration for Momentum Finance

@MainActor
class FinanceIntentsHandler: NSObject {
    static let shared = FinanceIntentsHandler()

    // MARK: - Donate Shortcuts

    func donateAddTransactionIntent() {
        let intent = AddTransactionIntent()
        intent.suggestedInvocationPhrase = "Add a transaction"

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error {
                print("Failed to donate intent: \(error)")
            }
        }
    }

    func donateViewBalanceIntent() {
        let intent = ViewBalanceIntent()
        intent.suggestedInvocationPhrase = "Show my balance"

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error {
                print("Failed to donate intent: \(error)")
            }
        }
    }

    func donateCheckBudgetIntent(category: String) {
        let intent = CheckBudgetIntent()
        intent.category = category
        intent.suggestedInvocationPhrase = "Check " + category + " budget"

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error {
                print("Failed to donate intent: \(error)")
            }
        }
    }

    // MARK: - Handle Shortcuts

    func handle(
        intent: AddTransactionIntent, completion: @escaping (AddTransactionIntentResponse) -> Void
    ) {
        // Create transaction from Siri input
        let response = AddTransactionIntentResponse(code: .success, userActivity: nil)
        response.amount = intent.amount
        response.category = intent.category
        completion(response)
    }

    func handle(
        intent: ViewBalanceIntent, completion: @escaping (ViewBalanceIntentResponse) -> Void
    ) {
        // Fetch current balance
        let response = ViewBalanceIntentResponse(code: .success, userActivity: nil)
        response.balance = "$1,234.56" // Fetch from model
        completion(response)
    }

    func handle(
        intent: CheckBudgetIntent, completion: @escaping (CheckBudgetIntentResponse) -> Void
    ) {
        // Check budget status
        let response = CheckBudgetIntentResponse(code: .success, userActivity: nil)
        response.spent = "$450"
        response.remaining = "$550"
        response.percentage = "45%"
        completion(response)
    }
}

// Intent definitions (would be in Intents.intentdefinition file)
class AddTransactionIntent: INIntent {
    @NSManaged var amount: NSNumber?
    @NSManaged var category: String?
}

class ViewBalanceIntent: INIntent {}

class CheckBudgetIntent: INIntent {
    @NSManaged var category: String?
}

@objc
public enum AddTransactionIntentResponseCode: Int {
    case success = 1
    case failure = 2
}

public class AddTransactionIntentResponse: INIntentResponse {
    @objc
    public init(code: AddTransactionIntentResponseCode, userActivity: NSUserActivity?) {
        super.init()
        self.userActivity = userActivity
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var amount: NSNumber?
    var category: String?
}

@objc
public enum ViewBalanceIntentResponseCode: Int {
    case success = 1
    case failure = 2
}

public class ViewBalanceIntentResponse: INIntentResponse {
    @objc
    public init(code: ViewBalanceIntentResponseCode, userActivity: NSUserActivity?) {
        super.init()
        self.userActivity = userActivity
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var balance: String?
}

@objc
public enum CheckBudgetIntentResponseCode: Int {
    case success = 1
    case failure = 2
}

public class CheckBudgetIntentResponse: INIntentResponse {
    @objc
    public init(code: CheckBudgetIntentResponseCode, userActivity: NSUserActivity?) {
        super.init()
        self.userActivity = userActivity
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var spent: String?
    var remaining: String?
    var percentage: String?
}
