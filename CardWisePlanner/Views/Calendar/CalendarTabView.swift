import SwiftUI

struct CalendarTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date? = nil

    private var monthStart: Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps) ?? Date()
    }

    private var eventsForSelectedDay: [BillingEvent] {
        guard let selectedDate else { return [] }
        return viewModel.events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CalendarMonthView(month: monthStart, events: viewModel.events, selectedDate: $selectedDate)
                }

                if !eventsForSelectedDay.isEmpty {
                    Section(header: Text("Events on \(selectedDate!, formatter: Self.dateFormatter)")) {
                        ForEach(eventsForSelectedDay) { event in
                            VStack(alignment: .leading) {
                                Text(event.type.displayName).bold()
                                if !event.note.isEmpty {
                                    Text(event.note)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                if !viewModel.events.isEmpty {
                    Section("Upcoming events") {
                        ForEach(viewModel.events.prefix(10)) { event in
                            VStack(alignment: .leading) {
                                Text(event.type.displayName).bold()
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

                if !viewModel.holidays.isEmpty {
                    Section("Upcoming holidays") {
                        ForEach(viewModel.holidays.prefix(5)) { holiday in
                            VStack(alignment: .leading) {
                                Text(holiday.localName).bold()
                                Text(holiday.date)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Calendar")
            .task { await refreshData() }
            .onChange(of: repository.cards) { cards in
                viewModel.updateCards(cards)
            }
        }
    }

    private func refreshData() async {
        viewModel.updateCards(repository.cards)
        let year = Calendar.current.component(.year, from: Date())
        await viewModel.refreshHolidays(countryCode: "US", year: year)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    CalendarTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
