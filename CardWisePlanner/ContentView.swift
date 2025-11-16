import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CardsTabView()
                .tabItem {
                    Label("Cards", systemImage: "rectangle.stack")
                }
            InsightsTabView()
                .tabItem {
                    Label("Insights", systemImage: "lightbulb")
                }
            CalendarTabView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
