import SwiftUI

struct CalendarTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @State private var holidays: [Holiday] = []
    @State private var errorMessage: String?

    private let holidayService = HolidayCalendarService()

    private var events: [BillingEvent] {
        repository.cards.flatMap { $0.events }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                if !events.isEmpty {
                    Section("Billing events") {
                        ForEach(events) { event in
                            VStack(alignment: .leading) {
                                Text(event.type.displayName)
                                    .bold()
                                Text(event.date, style: .date)
                                    .foregroundStyle(.secondary)
                                if !event.note.isEmpty {
                                    Text(event.note)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                if !holidays.isEmpty {
                    Section("Upcoming holidays") {
                        ForEach(holidays.prefix(5)) { holiday in
                            VStack(alignment: .leading) {
                                Text(holiday.localName).bold()
                                Text(holiday.date)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Calendar")
            .task { await loadHolidaysIfNeeded() }
        }
    }

    private func loadHolidaysIfNeeded() async {
        guard holidays.isEmpty else { return }
        do {
            holidays = try await holidayService.fetchHolidays(countryCode: "US", year: Calendar.current.component(.year, from: Date()))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    CalendarTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
