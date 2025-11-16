import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("CardWise Planner")
                .font(.largeTitle)
                .bold()
            Text("Tap the plus button to start adding your credit cards.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Image(systemName: "creditcard")
                .font(.system(size: 56))
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.15)))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
