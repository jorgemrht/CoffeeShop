import Foundation
import Testing
@testable import Data

struct RetryInterceptorTests {
    @Test func retriesRetryableServerError() async throws {
        // Given
        let attempts = AttemptCounter()
        let interceptor = RetryInterceptor(maxAttempts: 2, baseDelay: 0, maxDelay: 0)
        var request = URLRequest(url: URL(string: "https://api.example.com/retry")!)
        request.httpMethod = "GET"

        let next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            let attempt = await attempts.increment()
            if attempt == 1 {
                throw APIError.serverError(
                    APIResponse.mock(request: request, statusCode: 500)
                )
            }

            return APIResponse.mock(request: request, statusCode: 200)
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

    @Test func doesNotRetryNonRetryableServerError() async throws {
        // Given
        let attempts = AttemptCounter()
        let interceptor = RetryInterceptor(maxAttempts: 2, baseDelay: 0, maxDelay: 0)
        var request = URLRequest(url: URL(string: "https://api.example.com/no-retry")!)
        request.httpMethod = "GET"

        let next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await attempts.increment()
            throw APIError.serverError(
                APIResponse.mock(request: request, statusCode: 400)
            )
        }

        // When / Then
        do {
            _ = try await interceptor.intercept(
                request: request,
                session: .shared,
                next: next
            )
            Issue.record("Expected APIError.serverError")
        } catch let apiError as APIError {
            guard case .serverError(let response) = apiError else {
                Issue.record("Expected APIError.serverError")
                return
            }

            #expect(response.statusCode == 400)
        }

        #expect(await attempts.value == 1)
    }

    @Test func doesNotRetryPostByDefault() async throws {
        let attempts = AttemptCounter()
        let interceptor = RetryInterceptor(maxAttempts: 2, baseDelay: 0, maxDelay: 0)
        var request = URLRequest(url: URL(string: "https://api.example.com/login")!)
        request.httpMethod = "POST"

        let next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await attempts.increment()
            return APIResponse.mock(request: request, statusCode: 500)
        }

        let response = try await interceptor.intercept(
            request: request,
            session: .shared,
            next: next
        )

        #expect(response.statusCode == 500)
        #expect(await attempts.value == 1)
    }
}

private actor AttemptCounter {
    private(set) var value = 0

    @discardableResult
    func increment() -> Int {
        value += 1
        return value
    }
}

private extension APIResponse {
    static func mock(
        request: URLRequest,
        statusCode: Int,
        data: Data = Data()
    ) -> APIResponse {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return APIResponse(request: request, response: response, data: data)
    }
}
