import Foundation

struct CardOffer: Decodable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let issuer: String
    let category: String

    init(id: UUID = UUID(), title: String, description: String, issuer: String, category: String) {
        self.id = id
        self.title = title
        self.description = description
        self.issuer = issuer
        self.category = category
    }
}

struct CardOffersResponse: Decodable {
    let offers: [CardOffer]
}

protocol CardOffersServicing {
    func fetchOffers() async throws -> [CardOffer]
}

struct CardOffersService: CardOffersServicing {
    private let apiClient: APIClient

    init(apiClient: APIClient = .init()) {
        self.apiClient = apiClient
    }

    func fetchOffers() async throws -> [CardOffer] {
        guard let url = URL(string: "https://raw.githubusercontent.com/ilkeuygun/mock-apis/main/card_offers.json") else {
            throw APIClient.APIError.invalidURL
        }
        let request = URLRequest(url: url)
        let response = try await apiClient.fetch(request, as: CardOffersResponse.self)
        return response.offers
    }
}
