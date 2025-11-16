import XCTest
@testable import CardWisePlanner

final class NetworkingTests: XCTestCase {

    func testExchangeRatesDecoding() async throws {
        let service = ExchangeRateService(apiClient: .init(session: URLSession(configuration: .ephemeral)))
        let response = try await service.fetchRates(base: "USD")
        XCTAssertFalse(response.rates.isEmpty)
    }

    func testCardOffersDecoding() async throws {
        let service = CardOffersService(apiClient: .init(session: URLSession(configuration: .ephemeral)))
        let offers = try await service.fetchOffers()
        XCTAssertFalse(offers.isEmpty)
    }

    func testHolidayCalendarDecoding() async throws {
        let service = HolidayCalendarService(apiClient: .init(session: URLSession(configuration: .ephemeral)))
        let holidays = try await service.fetchHolidays(countryCode: "US", year: 2025)
        XCTAssertFalse(holidays.isEmpty)
    }
}
