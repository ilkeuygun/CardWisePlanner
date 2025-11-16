import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardRepository: CardRepository

    var body: some View {
        NavigationStack {
            Group {
                if cardRepository.cards.isEmpty {
                    EmptyStateView()
                        .padding(.horizontal)
                } else {
                    List {
                        Section("Credit Cards") {
                            ForEach(cardRepository.cards) { card in
                                CardSummaryRow(card: card)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("CardWise Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Label("Add Card", systemImage: "plus")
                    }
                    .disabled(true)
                    .help("Card creation flow arrives in the next milestone")
                }
            }
            .task {
                cardRepository.refreshCards()
            }
        }
    }
}

private struct CardSummaryRow: View {
    let card: CreditCardAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(card.displayName)
                    .font(.headline)
                Spacer()
                Text(card.maskedNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(card.issuer) · \(card.network)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(card.daysUntilStatementClose())d to close", systemImage: "calendar")
                Label("Due in \(card.daysUntilDueDate())d", systemImage: "calendar.badge.clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 56))
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.15)))
            Text("Add your first credit card")
                .font(.title3)
                .bold()
            Text("Save statement windows, due dates, and notes so we can recommend the best card to use and keep you ahead of payments.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 60)
    }
}

#Preview("Sample data") {
    ContentView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
