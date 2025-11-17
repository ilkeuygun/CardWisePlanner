import SwiftUI

struct CalendarMonthView: View {
    @State private var currentMonth: Date
    let events: [BillingEvent]
    @Binding var selectedDate: Date?

    private let calendar = Calendar.autoupdatingCurrent

    init(month: Date, events: [BillingEvent], selectedDate: Binding<Date?>) {
        _currentMonth = State(initialValue: month)
        self.events = events
        _selectedDate = selectedDate
    }

    private var title: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth)
    }

    private var days: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        var buffer: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                buffer.append(date)
            }
        }
        return buffer
    }

    private var eventsByDay: [Date: [BillingEvent]] {
        Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.date)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: { shiftMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }
                .buttonStyle(.borderless)

                Spacer()

                Text(title)
                    .font(.title2.bold())

                Spacer()

                Button(action: { shiftMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }
                .buttonStyle(.borderless)
            }

            HStack {
                let symbols = calendar.veryShortWeekdaySymbols
                ForEach(symbols.indices, id: \.self) { idx in
                    Text(symbols[(idx + calendar.firstWeekday - 1) % symbols.count])
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        dayCell(for: date)
                    } else {
                        Rectangle().foregroundStyle(.clear).frame(height: 40)
                    }
                }
            }
        }
        .padding(.vertical)
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let startOfDay = calendar.startOfDay(for: date)
        let dayEvents = eventsByDay[startOfDay] ?? []
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(6)
                    .background(isSelected ? Color.accentColor.opacity(0.2) : .clear)
                    .clipShape(Circle())

                if !dayEvents.isEmpty {
                    Text(dayEvents.map { $0.type.displayName }.joined(separator: ", "))
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

#Preview {
    CalendarMonthView(
        month: Date(),
        events: SampleData.makeCards().flatMap { $0.events },
        selectedDate: .constant(Date())
    )
}
