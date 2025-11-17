import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published private(set) var events: [BillingEvent] = []
    @Published private(set) var holidays: [Holiday] = []
    @Published private(set) var errorMessage: String?

    private let holidayService: HolidayCalendarServicing
    private var repository: CardRepository?

    init(holidayService: HolidayCalendarServicing = HolidayCalendarService()) {
        self.holidayService = holidayService
    }

    func bind(repository: CardRepository) {
        self.repository = repository
        updateCards(repository.cards)
    }

    func updateCards(_ cards: [CreditCardAccount]) {
        events = cards
            .flatMap { $0.events }
            .sorted { $0.date < $1.date }
    }

    func refreshHolidays(countryCode: String, year: Int) async {
        do {
            holidays = try await holidayService.fetchHolidays(countryCode: countryCode, year: year)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveNote(for date: Date,
                  existingEvent: BillingEvent?,
                  type: BillingEventType,
                  note: String) async {
        guard let repository else { return }
        do {
            if let existingEvent {
                try repository.update(event: existingEvent, note: note)
            } else {
                guard let targetCard = repository.cards.first else {
                    throw CardRepositoryError.persistenceFailed(NSError(domain: "CardWise", code: -1, userInfo: [NSLocalizedDescriptionKey: "Add a card first. "]))
                }
                _ = try repository.addEvent(to: targetCard, date: date, type: type, note: note)
            }
            updateCards(repository.cards)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
