import Testing
import Foundation
@testable import Domain
@testable import Data

struct APIErrorTests {

    enum TestError: Error {
        case unexpectedErrorType
    }

    @Test func apiErrorUnauthorizedToAppError() throws {
        // Given
        let apiError = APIError.unauthorized

        // When
        let appError = apiError.toDomain()

        // Then
        if case .unauthorized = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorNetworkErrorToAppError() throws {
        // Given
        let apiError = APIError.networkError

        // When
        let appError = apiError.toDomain()

        // Then
        if case .networkError = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorTimeoutToAppError() throws {
        // Given
        let apiError = APIError.timeout

        // When
        let appError = apiError.toDomain()

        // Then
        if case .timeout = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorInvalidURLToAppError() throws {
        // Given
        let apiError = APIError.invalidURL(url: "invalid://url")

        // When
        let appError = apiError.toDomain()

        // Then
        if case .serverError(let serverError) = appError {
            #expect(serverError?.message == "Invalid URL: invalid://url")
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorEncodingFailedToAppError() throws {
        // Given
        struct TestErrorType: Error {}
        let apiError = APIError.encodingFailed(TestErrorType())

        // When
        let appError = apiError.toDomain()

        // Then
        if case .internalError = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorDecodingFailedToAppError() throws {
        // Given
        struct TestErrorType: Error {}
        let apiError = APIError.decodingFailed(TestErrorType())

        // When
        let appError = apiError.toDomain()

        // Then
        if case .internalError = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorServerErrorToAppError() throws {
        // Given
        let json = """
        {
            "identifier": "AUTH_FAILED",
            "message": "Invalid credentials"
        }
        """
        let data = Data(json.utf8)
        let response = HTTPURLResponse(url: URL(string: "https://api.test.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: URLRequest(url: URL(string: "https://api.test.com")!), response: response, data: data)
        let apiError = APIError.serverError(apiResponse)

        // When
        let appError = apiError.toDomain()

        // Then
        if case .serverError(let serverError) = appError {
            #expect(serverError?.identifier == "AUTH_FAILED")
        } else {
            throw TestError.unexpectedErrorType
        }
    }

    @Test func apiErrorUnknownErrorToAppError() throws {
        // Given
        struct TestErrorType: Error {}
        let apiError = APIError.unknownError(TestErrorType())

        // When
        let appError = apiError.toDomain()

        // Then
        if case .internalError = appError {
            #expect(Bool(true))
        } else {
            throw TestError.unexpectedErrorType
        }
    }
}
