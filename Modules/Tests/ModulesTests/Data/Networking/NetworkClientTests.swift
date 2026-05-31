import Foundation
import Synchronization
import Testing
@testable import Data

private typealias URLProtocolHandler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
private let urlProtocolHandler = Mutex<URLProtocolHandler?>(nil)

struct NetworkClientTests {
    enum TestError: Error {
        case expectedAPIError
    }

    @Test func networkClientValidatesHTTPResponsesInsideTerminalRequest() async throws {
        // Given
        let url = URL(string: "https://api.example.com/server-error")!
        urlProtocolHandler.withLock {
            $0 = { request in
                let response = HTTPURLResponse(
                    url: request.url ?? url,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            }
        }

        let session = URLSession(configuration: .mock)
        let client = NetworkClient(
            baseURL: "https://api.example.com",
            session: session,
            interceptors: []
        )

        defer {
            urlProtocolHandler.withLock { $0 = nil }
        }

        // When / Then
        do {
            _ = try await client.request(APIEndpoint(path: "/server-error", method: .GET))
            throw TestError.expectedAPIError
        } catch let apiError as APIError {
            guard case .serverError(let response) = apiError else {
                throw TestError.expectedAPIError
            }

            #expect(response.statusCode == 500)
        }
    }
}

private final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let handler = urlProtocolHandler.withLock({ $0 }) else {
                throw URLError(.badServerResponse)
            }

            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

private extension URLSessionConfiguration {
    static var mock: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return configuration
    }
}
