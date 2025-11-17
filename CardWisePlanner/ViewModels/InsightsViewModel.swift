import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published private(set) var sortedCards: [CreditCardAccount] = []
    @Published private(set) var offers: [CardOffer] = []
    @Published private(set) var fxHighlights: [String] = []
    @Published private(set) var errorMessage: String?

    private let offersService: CardOffersServicing
    private let exchangeService: ExchangeRateServicing

    init(
        offersService: CardOffersServicing = CardOffersService(),
        exchangeService: ExchangeRateServicing = ExchangeRateService()
    ) {
        self.offersService = offersService
        self.exchangeService = exchangeService
    }

    func updateCards(_ cards: [CreditCardAccount]) {
        sortedCards = cards.sorted { lhs, rhs in
            lhs.daysUntilStatementClose() > rhs.daysUntilStatementClose()
        }
    }

    func refresh(baseCurrency: String) async {
        do {
            async let offersTask = offersService.fetchOffers()
            async let fxTask = exchangeService.fetchRates(base: baseCurrency)

            let offersResponse = try await offersTask
            let fxResponse = try? await fxTask

            offers = offersResponse
            fxHighlights = Self.makeHighlights(from: fxResponse)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func makeHighlights(from response: ExchangeRateResponse?) -> [String] {
        guard let response else { return [] }
        let topPairs = response.rates.sorted { $0.key < $1.key }.prefix(3)
        return topPairs.map { pair in
            let formatted = String(format: "%.2f", pair.value)
            return "1 \(response.base) = \(formatted) \(pair.key)"
        }
    }
}
