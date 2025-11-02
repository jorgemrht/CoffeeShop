import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - DTO Tests

struct LoginDTOTests {

    @Test func loginRequestDTOEncodesCorrectly() throws {
        // Given: A LoginRequestDTO
        let dto = LoginRequestDTO(email: "user@test.com", password: "pass123")

        // When: Encoding with standard encoder
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: Should contain email and password
        #expect(json != nil)
        #expect(json!.contains("user@test.com"))
        #expect(json!.contains("pass123"))
    }

    @Test func loginResponseDTODecodesCorrectly() throws {
        // Given: Valid login response JSON
        let json = """
        {
            "token": "valid_token_123"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding LoginResponseDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(LoginResponseDTO.self, from: data)

        // Then: Should decode token correctly
        #expect(dto.token == "valid_token_123")
    }

    @Test func loginResponseDTOMapsToUserSession() throws {
        // Given: A LoginResponseDTO
        let dto = LoginResponseDTO(token: "session_token_abc")

        // When: Mapping to Domain
        let userSession = dto.toDomain()

        // Then: UserSession should have the token
        #expect(userSession.token == "session_token_abc")
    }
}
