import Testing
import Foundation
@testable import Domain
@testable import Data

struct APIEndpointTests {

    @Test func apiEndpointMakesURLRequestWithQueryItems() throws {
        // Given
        let queryItems = [
            URLQueryItem(name: "search", value: "coffee"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let endpoint = APIEndpoint(path: "/shops", method: .GET, queryItems: queryItems)
        let baseURL = "https://api.example.com"

        // When
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then
        #expect(request.url?.absoluteString == "https://api.example.com/shops?search=coffee&limit=10")
    }

    @Test func apiEndpointMakesURLRequestWithBody() throws {
        // Given
        struct TestBody: Codable {
            let firstName: String
            let lastName: String
        }
        let body = TestBody(firstName: "login", lastName: "au")
        let endpoint = APIEndpoint(path: "/auth", method: .POST, body: body)
        let baseURL = "https://api.example.com"

        // When
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then
        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let bodyString = String(data: request.httpBody!, encoding: .utf8)!
        #expect(bodyString.contains("first_name"))
        #expect(bodyString.contains("last_name"))
    }
}
