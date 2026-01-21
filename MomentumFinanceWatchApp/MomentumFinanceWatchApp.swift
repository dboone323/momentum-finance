import SwiftUI
import WatchKit

// Enhancement #77: Apple Watch Companion App
@main
struct MomentumFinanceWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, World!")
        }
        .padding()
    }
}
