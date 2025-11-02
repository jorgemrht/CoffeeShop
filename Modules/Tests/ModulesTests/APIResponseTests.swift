import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - APIResponse Tests

struct APIResponseTests {

    @Test func apiResponseCreatesWithRequestResponseData() {
        // Given: URLRequest, HTTPURLResponse, and Data
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = Data("test response".utf8)

        // When: Creating APIResponse
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // Then: Should store all values correctly
        #expect(apiResponse.request.url == url)
        #expect(apiResponse.response.statusCode == 200)
        #expect(apiResponse.data == data)
    }

    @Test func apiResponseStatusCodeReturnsCorrectValue() {
        // Given: An APIResponse with status code 201
        let url = URL(string: "https://api.example.com/create")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: Data())

        // When: Accessing statusCode property
        let statusCode = apiResponse.statusCode

        // Then: Should return correct status code
        #expect(statusCode == 201)
    }

    @Test func apiResponseValidateSucceedsForSuccessfulResponse() throws {
        // Given: An APIResponse with 2xx status code
        let url = URL(string: "https://api.example.com/success")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: Data())

        // When: Calling validate()
        let validated = try apiResponse.validate()

        // Then: Should return self without throwing
        #expect(validated.statusCode == 200)
    }

    @Test func apiResponseValidateThrowsForClientError() {
        // Given: An APIResponse with 4xx status code
        let url = URL(string: "https://api.example.com/notfound")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: Data())

        // When/Then: Calling validate() should throw APIError.serverError
        #expect(throws: APIError.self) {
            try apiResponse.validate()
        }
    }

    @Test func apiResponseValidateThrowsForServerError() {
        // Given: An APIResponse with 5xx status code
        let url = URL(string: "https://api.example.com/error")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: Data())

        // When/Then: Calling validate() should throw
        #expect(throws: APIError.self) {
            try apiResponse.validate()
        }
    }

    @Test(arguments: [200, 201, 204, 299])
    func apiResponseValidateSucceedsForSuccessStatusCode(_ statusCode: Int) throws {
        // Given: A 2xx status code
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: Data())

        // When: Validating
        let validated = try apiResponse.validate()

        // Then: Should validate successfully
        #expect(validated.statusCode == statusCode)
    }

    @Test func apiResponseDecodedSucceedsWithValidJSON() throws {
        // Given: Valid JSON response data
        let json = """
        {
            "token": "abc123"
        }
        """
        let data = Data(json.utf8)
        let url = URL(string: "https://api.example.com/login")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // When: Decoding to LoginResponseDTO
        let dto = try apiResponse.decoded(LoginResponseDTO.self)

        // Then: Should decode successfully
        #expect(dto.token == "abc123")
    }

    @Test func apiResponseDecodedThrowsForInvalidJSON() {
        // Given: Invalid JSON data
        let data = Data("not valid json".utf8)
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // When/Then: Should throw APIError.decodingFailed
        #expect(throws: APIError.self) {
            try apiResponse.decoded(LoginResponseDTO.self)
        }
    }

    @Test func apiResponseDecodedUsesCustomDecoder() throws {
        // Given: JSON with snake_case keys
        let json = """
        {
            "user_id": "user123",
            "access_token": "token456"
        }
        """
        struct TestDTO: Codable {
            let userId: String
            let accessToken: String
        }
        let data = Data(json.utf8)
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // When: Using custom decoder with snake_case strategy
        let customDecoder = JSONDecoder.decoderDefault()
        let dto = try apiResponse.decoded(TestDTO.self, using: customDecoder)

        // Then: Should decode with custom decoder
        #expect(dto.userId == "user123")
        #expect(dto.accessToken == "token456")
    }

    @Test func apiResponseServerErrorParsesErrorDTO() {
        // Given: Response data with ServerErrorDTO
        let json = """
        {
            "identifier": "AUTH_ERROR",
            "message": "Invalid token"
        }
        """
        let data = Data(json.utf8)
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // When: Accessing serverError property
        let serverError = apiResponse.serverError

        // Then: Should parse ServerErrorDTO
        #expect(serverError != nil)
        #expect(serverError?.identifier == "AUTH_ERROR")
        #expect(serverError?.message == "Invalid token")
    }

    @Test func apiResponseServerErrorReturnsNilForInvalidJSON() {
        // Given: Response data that's not a valid ServerErrorDTO
        let data = Data("not json".utf8)
        let url = URL(string: "https://api.example.com/test")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let apiResponse = APIResponse(request: request, response: response, data: data)

        // When: Accessing serverError property
        let serverError = apiResponse.serverError

        // Then: Should return nil
        #expect(serverError == nil)
    }
}
