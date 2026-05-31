import Foundation
import Testing
@testable import Data

struct RefreshTokenInterceptorTests {
    @Test func refreshesTokenAndRetriesUnauthorizedRequest() async throws {
        // Given
        let attempts = RefreshAttemptCounter()
        let interceptor = RefreshTokenInterceptor(refresh: {
            "new-access-token"
        })
        let request = URLRequest(url: URL(string: "https://api.example.com/protected")!)

        let next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            let attempt = await attempts.increment()
            if attempt == 1 {
                throw APIError.serverError(
                    APIResponse.refreshMock(request: request, statusCode: 401)
                )
            }

            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer new-access-token")
            #expect(request.value(forHTTPHeaderField: "X-Bypass-Refresh") == "1")
            return APIResponse.refreshMock(request: request, statusCode: 200)
        }

        // When
        let response = try await interceptor.intercept(
            request: request,
            session: .shared,
            next: next
        )

        // Then
        #expect(response.statusCode == 200)
        #expect(await attempts.value == 2)
    }
}

private actor RefreshAttemptCounter {
    private(set) var value = 0

    @discardableResult
    func increment() -> Int {
        value += 1
        return value
    }
}

private extension APIResponse {
    static func refreshMock(
        request: URLRequest,
        statusCode: Int
    ) -> APIResponse {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return APIResponse(request: request, response: response, data: Data())
    }
}
