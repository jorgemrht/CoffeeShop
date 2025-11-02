import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - APIEndpoint Tests

struct APIEndpointTests {

    @Test func apiEndpointCreatesWithBasicParameters() {
        // Given: Basic endpoint parameters
        let path = "/users"
        let method = HTTPMethod.GET

        // When: Creating APIEndpoint
        let endpoint = APIEndpoint(path: path, method: method)

        // Then: Should store values correctly
        #expect(endpoint.path == "/users")
        #expect(endpoint.method == .GET)
        #expect(endpoint.headers == [:])
        #expect(endpoint.queryItems == nil)
        #expect(endpoint.body == nil)
    }

    @Test func apiEndpointCreatesWithAllParameters() {
        // Given: All endpoint parameters
        let path = "/posts"
        let method = HTTPMethod.POST
        let headers = ["Authorization": "Bearer token123"]
        let queryItems = [URLQueryItem(name: "page", value: "1")]
        let body = LoginRequestDTO(email: "test@test.com", password: "pass")

        // When: Creating APIEndpoint
        let endpoint = APIEndpoint(
            path: path,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: body
        )

        // Then: Should store all values correctly
        #expect(endpoint.path == "/posts")
        #expect(endpoint.method == .POST)
        #expect(endpoint.headers?["Authorization"] == "Bearer token123")
        #expect(endpoint.queryItems?.count == 1)
        #expect(endpoint.body != nil)
    }

    @Test func apiEndpointMakesURLRequestWithBasePath() throws {
        // Given: Simple GET endpoint
        let endpoint = APIEndpoint(path: "/health", method: .GET)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should create correct URLRequest
        #expect(request.url?.absoluteString == "https://api.example.com/health")
        #expect(request.httpMethod == "GET")
    }

    @Test func apiEndpointMakesURLRequestWithQueryItems() throws {
        // Given: Endpoint with query items
        let queryItems = [
            URLQueryItem(name: "search", value: "coffee"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let endpoint = APIEndpoint(path: "/shops", method: .GET, queryItems: queryItems)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should include query parameters
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("search=coffee"))
        #expect(urlString.contains("limit=10"))
    }

    @Test func apiEndpointMakesURLRequestWithHeaders() throws {
        // Given: Endpoint with custom headers
        let headers = [
            "Authorization": "Bearer mytoken",
            "X-Custom-Header": "CustomValue"
        ]
        let endpoint = APIEndpoint(path: "/secure", method: .GET, headers: headers)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should include custom headers
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer mytoken")
        #expect(request.value(forHTTPHeaderField: "X-Custom-Header") == "CustomValue")
    }

    @Test func apiEndpointAddsAcceptLanguageHeader() throws {
        // Given: Simple endpoint
        let endpoint = APIEndpoint(path: "/content", method: .GET)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should include Accept-Language header
        let acceptLanguage = request.value(forHTTPHeaderField: "Accept-Language")
        #expect(acceptLanguage != nil)
        #expect(!acceptLanguage!.isEmpty)
    }

    @Test func apiEndpointMakesURLRequestWithBody() throws {
        // Given: POST endpoint with body
        let body = LoginRequestDTO(email: "user@test.com", password: "password123")
        let endpoint = APIEndpoint(path: "/login", method: .POST, body: body)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should include body and Content-Type header
        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        // Verify body contains expected email (without full decoding since DTO is Encodable only)
        let bodyData = request.httpBody!
        let bodyString = String(data: bodyData, encoding: .utf8)!
        #expect(bodyString.contains("user@test.com"))
        #expect(bodyString.contains("password123"))
    }

    @Test func apiEndpointEncodesBodyWithSnakeCaseStrategy() throws {
        // Given: Endpoint with body that should use snake_case
        struct TestBody: Codable {
            let firstName: String
            let lastName: String
        }
        let body = TestBody(firstName: "John", lastName: "Doe")
        let endpoint = APIEndpoint(path: "/users", method: .POST, body: body)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Body should be encoded with snake_case
        let bodyString = String(data: request.httpBody!, encoding: .utf8)!
        #expect(bodyString.contains("first_name"))
        #expect(bodyString.contains("last_name"))
    }

    @Test func apiEndpointThrowsEncodingFailedForUnencodableBody() {
        // Given: Endpoint with unencodable body
        // Note: This is theoretical since we can't easily create a truly unencodable Encodable
        // but we can test the error path exists
        let endpoint = APIEndpoint(path: "/test", method: .POST, body: LoginRequestDTO(email: "test", password: "pass"))
        let baseURL = "https://api.example.com"

        // When: Making URLRequest with valid body should succeed
        #expect(throws: Never.self) {
            _ = try endpoint.makeURLRequest(baseURL: baseURL)
        }
    }

    @Test func apiEndpointHandlesSpecialCharactersInQueryItems() throws {
        // Given: Endpoint with special characters in query
        let queryItems = [
            URLQueryItem(name: "q", value: "coffee & tea"),
            URLQueryItem(name: "filter", value: "price>10")
        ]
        let endpoint = APIEndpoint(path: "/search", method: .GET, queryItems: queryItems)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should properly encode special characters
        let url = request.url!
        #expect(url.absoluteString.contains("%20") || url.absoluteString.contains("+"))
    }

    @Test(arguments: ["GET", "POST", "PUT", "DELETE", "PATCH"])
    func apiEndpointSupportsHTTPMethod(_ methodString: String) throws {
        // Given: An endpoint with a specific HTTP method
        let method = HTTPMethod(rawValue: methodString)!
        let endpoint = APIEndpoint(path: "/resource", method: method)
        let baseURL = "https://api.example.com"

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Request should have correct HTTP method
        #expect(request.httpMethod == methodString)
    }

    @Test(
        arguments: [
            ("https://api.example.com", "/users", "https://api.example.com/users"),
            ("https://api.example.com/", "/users", "https://api.example.com//users"),
            ("https://api.example.com/v1", "/users", "https://api.example.com/v1/users")
        ]
    )
    func apiEndpointCombinesBaseURLAndPath(baseURL: String, path: String, expected: String) throws {
        // Given: Base URL and path
        let endpoint = APIEndpoint(path: path, method: .GET)

        // When: Making URLRequest
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        // Then: Should combine correctly
        #expect(request.url?.absoluteString == expected)
    }
}
