import Foundation
import SwiftData

@Model
final class CreditCardAccount {
    @Attribute(.unique) var id: UUID
    var name: String
    var issuer: String
    var network: String
    var currencyCode: String
    var cardNumberLast4: String
    var statementCloseDay: Int
    var dueDay: Int
    var billingWindowLength: Int
    var createdAt: Date
    var updatedAt: Date
    var notes: String

    var events: [BillingEvent] = []

    init(
        name: String,
        issuer: String,
        network: String,
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        cardNumberLast4: String,
        statementCloseDay: Int,
        dueDay: Int,
        billingWindowLength: Int = 30,
        notes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.issuer = issuer
        self.network = network
        self.currencyCode = currencyCode
        self.cardNumberLast4 = cardNumberLast4
        self.statementCloseDay = statementCloseDay
        self.dueDay = dueDay
        self.billingWindowLength = billingWindowLength
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
    }
}

extension CreditCardAccount {
    var displayName: String {
        name.isEmpty ? issuer : name
    }

    var maskedNumber: String {
        "•••• \(cardNumberLast4)"
    }

    func nextStatementCloseDate(from referenceDate: Date = .now,
                                calendar: Calendar = .autoupdatingCurrent) -> Date {
        Self.nextDate(for: statementCloseDay, from: referenceDate, calendar: calendar)
    }

    func nextDueDate(from referenceDate: Date = .now,
                     calendar: Calendar = .autoupdatingCurrent) -> Date {
        Self.nextDate(for: dueDay, from: referenceDate, calendar: calendar)
    }

    func daysUntilStatementClose(from referenceDate: Date = .now,
                                 calendar: Calendar = .autoupdatingCurrent) -> Int {
        let nextClose = nextStatementCloseDate(from: referenceDate, calendar: calendar)
        let start = calendar.startOfDay(for: referenceDate)
        let target = calendar.startOfDay(for: nextClose)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    func daysUntilDueDate(from referenceDate: Date = .now,
                          calendar: Calendar = .autoupdatingCurrent) -> Int {
        let nextDue = nextDueDate(from: referenceDate, calendar: calendar)
        let start = calendar.startOfDay(for: referenceDate)
        let target = calendar.startOfDay(for: nextDue)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    private static func nextDate(for day: Int,
                                 from referenceDate: Date,
                                 calendar: Calendar) -> Date {
        let safeDay = max(1, min(day, 31))
        var components = calendar.dateComponents([.year, .month], from: referenceDate)
        let range = calendar.range(of: .day, in: .month, for: referenceDate) ?? 1..<32
        components.day = min(safeDay, range.count)
        var candidate = calendar.date(from: components) ?? referenceDate

        if candidate < calendar.startOfDay(for: referenceDate) {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: referenceDate) else {
                return candidate
            }
            var nextComponents = calendar.dateComponents([.year, .month], from: nextMonth)
            let nextRange = calendar.range(of: .day, in: .month, for: nextMonth) ?? 1..<32
            nextComponents.day = min(safeDay, nextRange.count)
            candidate = calendar.date(from: nextComponents) ?? candidate
        }

        return candidate
    }
}

