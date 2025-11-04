import Testing
import Foundation
@testable import Data

// MARK: - BearerAuthInterceptor Tests

struct BearerAuthInterceptorTests {

    @Test func interceptorAddsAuthorizationHeaderWhenTokenIsValid() async throws {
        // Given
        let validToken = Token(value: "valid-token-123", expiry: Date().addingTimeInterval(3600))
        let tokenProvider: @Sendable () async -> Token? = { validToken }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        // Mock next closure that captures the request
        actor RequestCapture {
            var capturedRequest: URLRequest?
            func capture(_ request: URLRequest) {
                capturedRequest = request
            }
            func getCaptured() -> URLRequest? {
                capturedRequest
            }
        }
        let capture = RequestCapture()

        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await capture.capture(request)
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When
        let originalRequest = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        _ = try await interceptor.intercept(request: originalRequest, session: .shared, next: mockNext)

        // Then
        let capturedRequest = await capture.getCaptured()
        #expect(capturedRequest != nil)
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == "Bearer valid-token-123")
    }

    @Test func interceptorDoesNotAddHeaderWhenTokenIsNil() async throws {
        // Given
        let tokenProvider: @Sendable () async -> Token? = { nil }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        // Mock next closure that captures the request
        actor RequestCapture {
            var capturedRequest: URLRequest?
            func capture(_ request: URLRequest) {
                capturedRequest = request
            }
            func getCaptured() -> URLRequest? {
                capturedRequest
            }
        }
        let capture = RequestCapture()

        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await capture.capture(request)
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When
        let originalRequest = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        _ = try await interceptor.intercept(request: originalRequest, session: .shared, next: mockNext)

        // Then
        let capturedRequest = await capture.getCaptured()
        #expect(capturedRequest != nil)
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == nil)
    }

    @Test func interceptorThrowsUnauthorizedWhenTokenIsExpired() async throws {
        // Given
        let expiredToken = Token(value: "expired-token", expiry: Date().addingTimeInterval(-3600))
        let tokenProvider: @Sendable () async -> Token? = { expiredToken }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        // Mock next closure
        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When/Then
        let request = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)

        await #expect(throws: APIError.self) {
            _ = try await interceptor.intercept(request: request, session: .shared, next: mockNext)
        }
    }

    @Test func interceptorCallsNextWithModifiedRequest() async throws {
        // Given
        let token = Token(value: "test-token", expiry: Date().addingTimeInterval(3600))
        let tokenProvider: @Sendable () async -> Token? = { token }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        actor CallTracker {
            var nextWasCalled = false
            func markCalled() {
                nextWasCalled = true
            }
            func wasCalled() -> Bool {
                nextWasCalled
            }
        }
        let tracker = CallTracker()

        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await tracker.markCalled()
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When
        let request = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        _ = try await interceptor.intercept(request: request, session: .shared, next: mockNext)

        // Then
        let wasCalled = await tracker.wasCalled()
        #expect(wasCalled == true)
    }

    @Test func interceptorPreservesOriginalRequestProperties() async throws {
        // Given
        var originalRequest = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        originalRequest.httpMethod = "POST"
        originalRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        originalRequest.setValue("en-US", forHTTPHeaderField: "Accept-Language")

        let token = Token(value: "token", expiry: Date().addingTimeInterval(3600))
        let tokenProvider: @Sendable () async -> Token? = { token }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        actor RequestCapture {
            var capturedRequest: URLRequest?
            func capture(_ request: URLRequest) {
                capturedRequest = request
            }
            func getCaptured() -> URLRequest? {
                capturedRequest
            }
        }
        let capture = RequestCapture()

        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await capture.capture(request)
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When
        _ = try await interceptor.intercept(request: originalRequest, session: .shared, next: mockNext)

        // Then
        let capturedRequest = await capture.getCaptured()
        #expect(capturedRequest?.httpMethod == "POST")
        #expect(capturedRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(capturedRequest?.value(forHTTPHeaderField: "Accept-Language") == "en-US")
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }

    @Test func interceptorReturnsResponseFromNext() async throws {
        // Given
        let token = Token(value: "token", expiry: Date().addingTimeInterval(3600))
        let tokenProvider: @Sendable () async -> Token? = { token }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        let expectedData = Data("test response".utf8)
        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: expectedData)
        }

        // When
        let request = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        let response = try await interceptor.intercept(request: request, session: .shared, next: mockNext)

        // Then
        #expect(response.data == expectedData)
        #expect(response.statusCode == 200)
    }

    @Test func interceptorWorksWithAsyncTokenProvider() async throws {
        // Given
        let tokenProvider: @Sendable () async -> Token? = {
            try? await Task.sleep(for: .milliseconds(10))
            return Token(value: "async-token", expiry: Date().addingTimeInterval(3600))
        }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        actor RequestCapture {
            var capturedRequest: URLRequest?
            func capture(_ request: URLRequest) {
                capturedRequest = request
            }
            func getCaptured() -> URLRequest? {
                capturedRequest
            }
        }
        let capture = RequestCapture()

        let mockNext: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, _ in
            await capture.capture(request)
            let url = request.url ?? URL(string: "https://test.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return APIResponse(request: request, response: response, data: Data())
        }

        // When
        let request = URLRequest(url: URL(string: "https://api.test.com/endpoint")!)
        _ = try await interceptor.intercept(request: request, session: .shared, next: mockNext)

        // Then
        let capturedRequest = await capture.getCaptured()
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer async-token")
    }

    @Test func interceptorIsSendable() {
        // Given
        let tokenProvider: @Sendable () async -> Token? = { nil }
        let interceptor = BearerAuthInterceptor(tokenProvider: tokenProvider)

        // When
        // Then
        let _: any RequestInterceptor = interceptor
        #expect(Bool(true))
    }
}
