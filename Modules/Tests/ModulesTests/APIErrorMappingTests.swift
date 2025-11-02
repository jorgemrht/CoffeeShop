import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - APIError Mapping Tests

struct APIErrorMappingTests {

    @Test func unauthorizedMapsToAppError() {
        // Given: An unauthorized APIError
        let apiError = APIError.unauthorized

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.unauthorized
        if case .unauthorized = appError {
            // Success
        } else {
            Issue.record("Expected .unauthorized but got different case")
        }
    }

    @Test func networkErrorMapsToAppError() {
        // Given: A network APIError
        let apiError = APIError.networkError

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.networkError
        if case .networkError = appError {
            // Success
        } else {
            Issue.record("Expected .networkError but got different case")
        }
    }

    @Test func timeoutMapsToAppError() {
        // Given: A timeout APIError
        let apiError = APIError.timeout

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.timeout
        if case .timeout = appError {
            // Success
        } else {
            Issue.record("Expected .timeout but got different case")
        }
    }

    @Test func invalidURLMapsToServerError() {
        // Given: An invalid URL error
        let apiError = APIError.invalidURL(url: "invalid://url")

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.serverError
        if case .serverError(let serverError) = appError {
            #expect(serverError != nil)
            #expect(serverError?.message != nil)
            #expect(serverError!.message!.contains("invalid://url"))
        } else {
            Issue.record("Expected .serverError but got different case")
        }
    }

    @Test func encodingFailedMapsToInternalError() {
        // Given: An encoding failed error
        let underlyingError = NSError(domain: "test", code: 1)
        let apiError = APIError.encodingFailed(underlyingError)

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.internalError
        if case .internalError(let error) = appError {
            #expect(error != nil)
        } else {
            Issue.record("Expected .internalError but got different case")
        }
    }

    @Test func decodingFailedMapsToInternalError() {
        // Given: A decoding failed error
        let underlyingError = NSError(domain: "test", code: 2)
        let apiError = APIError.decodingFailed(underlyingError)

        // When: Mapping to domain
        let appError = apiError.toDomain()

        // Then: Should map to AppError.internalError
        if case .internalError(let error) = appError {
            #expect(error != nil)
        } else {
            Issue.record("Expected .internalError but got different case")
        }
    }
}
