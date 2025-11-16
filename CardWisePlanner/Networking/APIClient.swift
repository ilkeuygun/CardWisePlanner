import Foundation

struct APIClient {
    enum APIError: Error, LocalizedError {
        case invalidURL
        case requestFailed
        case decodingFailed
        case rateLimited

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API endpoint."
            case .requestFailed:
                return "Network request failed."
            case .decodingFailed:
                return "Failed to decode server response."
            case .rateLimited:
                return "Too many requests. Please try again later."
            }
        }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 { throw APIError.rateLimited }
            throw APIError.requestFailed
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
