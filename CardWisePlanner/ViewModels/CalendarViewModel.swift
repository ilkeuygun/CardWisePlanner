import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published private(set) var events: [BillingEvent] = []
    @Published private(set) var holidays: [Holiday] = []
    @Published private(set) var errorMessage: String?

    private let holidayService: HolidayCalendarServicing

    init(holidayService: HolidayCalendarServicing = HolidayCalendarService()) {
        self.holidayService = holidayService
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
}
