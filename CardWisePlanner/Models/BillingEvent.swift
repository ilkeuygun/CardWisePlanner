import Foundation
import SwiftData

enum BillingEventType: String, Codable, CaseIterable, Sendable {
    case statementClose
    case paymentDue
    case customNote

    var displayName: String {
        switch self {
        case .statementClose:
            return "Statement Close"
        case .paymentDue:
            return "Payment Due"
        case .customNote:
            return "Note"
        }
    }

    var systemImageName: String {
        switch self {
        case .statementClose:
            return "creditcard"
        case .paymentDue:
            return "calendar.badge.clock"
        case .customNote:
            return "note.text"
        }
    }
}

@Model
final class BillingEvent {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: BillingEventType
    var note: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \CreditCardAccount.events)
    var card: CreditCardAccount?

    init(date: Date,
         type: BillingEventType,
         note: String = "",
         card: CreditCardAccount? = nil,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.note = note
        self.card = card
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension BillingEvent {
    var isSystemGenerated: Bool {
        type != .customNote
    }

    var dayComponent: Int {
        Calendar.autoupdatingCurrent.component(.day, from: date)
    }
}
