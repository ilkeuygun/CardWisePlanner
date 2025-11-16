import SwiftUI

struct InsightsTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @State private var offers: [CardOffer] = []
    @State private var isLoadingOffers = false
    @State private var errorMessage: String?

    private let offersService = CardOffersService()

    private var rankedCards: [CreditCardAccount] {
        repository.cards.sorted { lhs, rhs in
            lhs.daysUntilStatementClose() > rhs.daysUntilStatementClose()
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Recommended order") {
                    ForEach(rankedCards) { card in
                        VStack(alignment: .leading) {
                            Text(card.displayName)
                                .font(.headline)
                            Text("Use for \(card.daysUntilStatementClose()) more days before statement closes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !offers.isEmpty {
                    Section("Offers & Tips") {
                        ForEach(offers) { offer in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(offer.title).bold()
                                Text(offer.description)
                                    .font(.subheadline)
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
            .navigationTitle("Insights")
            .refreshable { await loadOffers() }
            .task { await loadOffers() }
        }
    }

    private func loadOffers() async {
        guard !isLoadingOffers else { return }
        isLoadingOffers = true
        defer { isLoadingOffers = false }
        do {
            offers = try await offersService.fetchOffers()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    InsightsTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
