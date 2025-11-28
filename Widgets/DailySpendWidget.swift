import WidgetKit
import SwiftUI
import SwiftData

struct DailySpendWidget: Widget {
    let kind: String = "DailySpendWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailySpendWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Spending")
        .description("Track today's spending at a glance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todaySpending: 0, budget: 0, remainingBudget: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), todaySpending: 45.50, budget: 100, remainingBudget: 54.50)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let entry = await fetchTodaySpending()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
    
    private func fetchTodaySpending() async -> SimpleEntry {
        // Fetch from shared container
        let container = try? ModelContainer(for: FinancialTransaction.self)
        guard let context = container?.mainContext else {
            return SimpleEntry(date: Date(), todaySpending: 0, budget: 0, remainingBudget: 0)
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let transactions = try? context.fetch(
            FetchDescriptor<FinancialTransaction>(
                predicate: #Predicate { $0.date >= today && $0.transactionType == .expense }
            )
        )
        
        let todaySpending = transactions?.reduce(0) { $0 + abs($1.amount) } ?? 0
        let budget = 100.0 // Fetch from user preferences
        
        return SimpleEntry(
            date: Date(),
            todaySpending: todaySpending,
            budget: budget,
            remainingBudget: budget - todaySpending
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todaySpending: Double
    let budget: Double
    let remainingBudget: Double
}

struct DailySpendWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, end Point: .bottomTrailing))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.white)
                    Text("Today's Spending")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text("$\(entry.todaySpending, specifier: "%.2f")")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Budget")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text("$\(entry.budget, specifier: "%.0f")")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text("$\(entry.remainingBudget, specifier: "%.2f")")
                            .font(.caption.bold())
                            .foregroundColor(entry.remainingBudget > 0 ? .green : .red)
                    }
                }
            }
            .padding()
        }
    }
}
