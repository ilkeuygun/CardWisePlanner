import SwiftData
import SwiftUI

@main
struct CardWisePlannerApp: App {
    private let container: ModelContainer
    @StateObject private var repository: CardRepository

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: CreditCardAccount.self, BillingEvent.self)
        } catch {
            fatalError("Unable to bootstrap SwiftData container: \(error.localizedDescription)")
        }

        self.container = container
        let repository = CardRepository(context: container.mainContext)
        _repository = StateObject(wrappedValue: repository)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repository)
        }
        .modelContainer(container)
    }
}
