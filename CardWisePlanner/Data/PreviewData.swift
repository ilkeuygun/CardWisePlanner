import Foundation
import SwiftData

enum PreviewData {
    static let container: ModelContainer = {
        let schema = Schema([CreditCardAccount.self, BillingEvent.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)
            SampleData.makeCards().forEach { context.insert($0) }
            try context.save()
            return container
        } catch {
            fatalError("Failed to bootstrap preview container: \(error.localizedDescription)")
        }
    }()

    @MainActor
    static func repository() -> CardRepository {
        CardRepository(
            context: container.mainContext,
            defaults: UserDefaults(suiteName: "CardWisePlanner.previewDefaults") ?? .standard,
            seedProvider: { [] }
        )
    }
}

enum SampleData {
    static func makeCards(referenceDate: Date = .now) -> [CreditCardAccount] {
        let calendar = Calendar.autoupdatingCurrent
        let startOfDay = calendar.startOfDay(for: referenceDate)

        let travelCard = CreditCardAccount(
            name: "Flagship Travel",
            issuer: "Voyage Bank",
            network: "Visa Infinite",
            currencyCode: "USD",
            cardNumberLast4: "4831",
            statementCloseDay: 18,
            dueDay: 13,
            billingWindowLength: 30,
            notes: "Best for flights + hotels"
        )

        let cashbackCard = CreditCardAccount(
            name: "Metro Rewards",
            issuer: "Metro Credit Union",
            network: "Mastercard World",
            currencyCode: "CAD",
            cardNumberLast4: "9024",
            statementCloseDay: 7,
            dueDay: 2,
            billingWindowLength: 31,
            notes: "Groceries & subscriptions"
        )

        travelCard.events.append(contentsOf: [
            BillingEvent(
                date: startOfDay,
                type: .statementClose,
                note: "Cycle closes for October",
                card: travelCard
            ),
            BillingEvent(
                date: calendar.date(byAdding: .day, value: 25, to: startOfDay)!,
                type: .paymentDue,
                note: "Payment due",
                card: travelCard
            )
        ])

        cashbackCard.events.append(contentsOf: [
            BillingEvent(
                date: calendar.date(byAdding: .day, value: 5, to: startOfDay)!,
                type: .statementClose,
                note: "Statement cycle ends",
                card: cashbackCard
            ),
            BillingEvent(
                date: calendar.date(byAdding: .day, value: 28, to: startOfDay)!,
                type: .paymentDue,
                note: "Due date reminder",
                card: cashbackCard
            )
        ])

        return [travelCard, cashbackCard]
    }
}
