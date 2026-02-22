import AppIntents

/// Enhancement #78: Siri Shortcuts
struct OpenMomentumFinanceIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open MomentumFinance"
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct MomentumFinanceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenMomentumFinanceIntent(),
            phrases: ["Open \(.applicationName)"]
        )
    }
}
