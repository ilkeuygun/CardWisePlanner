import Foundation

struct Holiday: Decodable, Identifiable {
    let id = UUID()
    let date: String
    let localName: String
    let name: String
}

protocol HolidayCalendarServicing {
    func fetchHolidays(countryCode: String, year: Int) async throws -> [Holiday]
}

struct HolidayCalendarService: HolidayCalendarServicing {
    private let apiClient: APIClient

    init(apiClient: APIClient = .init()) {
        self.apiClient = apiClient
    }

    func fetchHolidays(countryCode: String, year: Int) async throws -> [Holiday] {
        guard let url = URL(string: "https://date.nager.at/api/v3/PublicHolidays/\(year)/\(countryCode)") else {
            throw APIClient.APIError.invalidURL
        }
        let request = URLRequest(url: url)
        return try await apiClient.fetch(request, as: [Holiday].self)
    }
}
