import SwiftUI

struct CardsTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @State private var showingAddSheet = false
    @State private var selectedCard: CreditCardAccount?

    private var cards: [CreditCardAccount] { repository.cards }
    private var recommendedCardID: UUID? {
        cards.max { $0.daysUntilStatementClose() < $1.daysUntilStatementClose() }?.id
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your cards")
                    .font(.title.bold())

                if cards.isEmpty {
                    EmptyStateView(
                        icon: "creditcard", caption: "Tap + to add your first card"
                    )
                } else {
                    GeometryReader { proxy in
                        TabView {
                            ForEach(cards) { card in
                                CardSummaryView(card: card, isRecommended: card.id == recommendedCardID)
                                    .frame(width: proxy.size.width * 0.85)
                                    .padding(.trailing, 16)
                                    .onTapGesture { selectedCard = card }
                            }
                            AddCardPlaceholder()
                                .frame(width: proxy.size.width * 0.85)
                                .padding(.trailing, 16)
                                .onTapGesture { showingAddSheet = true }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                    }
                    .frame(height: 240)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCardSheet()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct CardSummaryView: View {
    let card: CreditCardAccount
    let isRecommended: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isRecommended {
                    Label("Use first", systemImage: "star.fill")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.yellow.opacity(0.2))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(card.displayName)
                        .font(.title2.bold())
                    Text(card.maskedNumber)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(card.issuer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider().opacity(0.2)

            HStack {
                Label("Cycle closes in \(card.daysUntilStatementClose())d", systemImage: "calendar")
                Spacer()
                Label("Due in \(card.daysUntilDueDate())d", systemImage: "calendar.badge.clock")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
        .padding(.vertical)
    }
}

private struct AddCardPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
            Text("Add card")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(.secondary)
        )
        .padding(.vertical)
    }
}

private struct EmptyStateView: View {
    let icon: String
    let caption: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 54))
                .foregroundStyle(.secondary)
            Text(caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

#Preview {
    CardsTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
