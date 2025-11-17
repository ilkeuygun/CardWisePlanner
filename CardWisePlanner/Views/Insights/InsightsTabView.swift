import SwiftUI

struct InsightsTabView: View {
    @EnvironmentObject private var repository: CardRepository
    @StateObject private var viewModel = InsightsViewModel()

    private var baseCurrency: String {
        repository.cards.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.fxHighlights.isEmpty {
                    Section("FX Snapshot") {
                        ForEach(viewModel.fxHighlights, id: \.self) { highlight in
                            Text(highlight)
                                .font(.subheadline)
                        }
                    }
                }

                Section("Recommended order") {
                    ForEach(viewModel.sortedCards) { card in
                        VStack(alignment: .leading) {
                            Text(card.displayName)
                                .font(.headline)
                            Text("Use for \(card.daysUntilStatementClose()) more days")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !viewModel.offers.isEmpty {
                    Section("Offers & Tips") {
                        ForEach(viewModel.offers) { offer in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(offer.title).bold()
                                Text(offer.description)
                                    .font(.subheadline)
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
            .navigationTitle("Insights")
            .refreshable { await viewModel.refresh(baseCurrency: baseCurrency) }
            .task { await refreshViewModel() }
            .onChange(of: repository.cards) { cards in
                viewModel.updateCards(cards)
            }
        }
    }

    private func refreshViewModel() async {
        viewModel.updateCards(repository.cards)
        await viewModel.refresh(baseCurrency: baseCurrency)
    }
}

#Preview {
    InsightsTabView()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
