import Foundation

struct ExchangeRateResponse: Decodable {
    let base: String
    let rates: [String: Double]
}

protocol ExchangeRateServicing {
    func fetchRates(base: String) async throws -> ExchangeRateResponse
}

struct ExchangeRateService: ExchangeRateServicing {
    private let apiClient: APIClient

    init(apiClient: APIClient = .init()) {
        self.apiClient = apiClient
    }

    func fetchRates(base: String) async throws -> ExchangeRateResponse {
        var components = URLComponents(string: "https://api.exchangerate.host/latest")
        components?.queryItems = [
            URLQueryItem(name: "base", value: base)
        ]
        guard let url = components?.url else { throw APIClient.APIError.invalidURL }
        let request = URLRequest(url: url)
        return try await apiClient.fetch(request, as: ExchangeRateResponse.self)
    }
}
