import Foundation
import os.log
import SwiftData

@MainActor
final class CardRepository: ObservableObject {
    typealias SeedProvider = () -> [CreditCardAccount]

    @Published private(set) var cards: [CreditCardAccount] = []

    private let context: ModelContext
    private let defaults: UserDefaults
    private let seedProvider: SeedProvider
    private let logger = Logger(subsystem: "com.cardwiseplanner.app", category: "CardRepository")
    private static let seedKey = "com.cardwiseplanner.hasSeeded"

    init(
        context: ModelContext,
        defaults: UserDefaults = .standard,
        seedProvider: @escaping SeedProvider = { SampleData.makeCards() }
    ) {
        self.context = context
        self.defaults = defaults
        self.seedProvider = seedProvider
        seedIfNeeded()
        refreshCards()
    }

    func refreshCards() {
        let descriptor = FetchDescriptor<CreditCardAccount>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            cards = try context.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch cards: \(error.localizedDescription, privacy: .public)")
        }
    }

    @discardableResult
    func addCard(
        name: String,
        issuer: String,
        network: String,
        currencyCode: String,
        last4: String,
        statementCloseDay: Int,
        dueDay: Int,
        billingWindowLength: Int,
        notes: String = ""
    ) throws -> CreditCardAccount {
        let card = CreditCardAccount(
            name: name,
            issuer: issuer,
            network: network,
            currencyCode: currencyCode,
            cardNumberLast4: last4,
            statementCloseDay: statementCloseDay,
            dueDay: dueDay,
            billingWindowLength: billingWindowLength,
            notes: notes
        )
        context.insert(card)
        try saveChanges()
        return card
    }

    func delete(_ card: CreditCardAccount) throws {
        context.delete(card)
        try saveChanges()
    }

    func upsert(_ card: CreditCardAccount, apply changes: (CreditCardAccount) -> Void) throws {
        changes(card)
        card.updatedAt = .now
        try saveChanges()
    }

    @discardableResult
    func addEvent(
        to card: CreditCardAccount?,
        date: Date,
        type: BillingEventType,
        note: String = ""
    ) throws -> BillingEvent {
        let event = BillingEvent(date: date, type: type, note: note, card: card)
        if let card {
            card.events.append(event)
        } else {
            context.insert(event)
        }
        try saveChanges()
        return event
    }

    func update(event: BillingEvent, note: String) throws {
        event.note = note
        event.updatedAt = .now
        try saveChanges()
    }

    private func seedIfNeeded() {
        guard defaults.bool(forKey: Self.seedKey) == false else { return }
        seedProvider().forEach { context.insert($0) }
        do {
            try context.save()
            defaults.set(true, forKey: Self.seedKey)
        } catch {
            logger.error("Failed to seed sample data: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func saveChanges() throws {
        do {
            try context.save()
            refreshCards()
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription, privacy: .public)")
            throw CardRepositoryError.persistenceFailed(error)
        }
    }
}

enum CardRepositoryError: LocalizedError {
    case persistenceFailed(Error)

    var errorDescription: String? {
        switch self {
        case .persistenceFailed(let error):
            return "Unable to save changes: \(error.localizedDescription)"
        }
    }
}
