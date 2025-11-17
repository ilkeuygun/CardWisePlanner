import SwiftUI

struct CalendarTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.events.isEmpty {
                    Section("Billing events") {
                        ForEach(viewModel.events) { event in
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
}

#Preview {
    CalendarTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
