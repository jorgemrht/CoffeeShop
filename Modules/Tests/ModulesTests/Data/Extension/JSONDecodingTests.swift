import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - JSON Decoding Tests

struct JSONDecodingTests {

    @Test func decoderDefaultConvertsFromSnakeCase() throws {
        // Given
        let json = """
        {
            "token": "abc123xyz"
        }
        """
        let data = Data(json.utf8)

        // When
        let decoder = JSONDecoder.decoderDefault()
        let dto = try decoder.decode(LoginResponseDTO.self, from: data)

        // Then
        #expect(dto.token == "abc123xyz")
    }

    @Test func decoderDefaultHandlesComplexSnakeCase() throws {
        // Given
        struct ComplexDTO: Codable {
            let userId: String
            let accessToken: String
            let refreshToken: String
        }

        let json = """
        {
            "user_id": "user123",
            "access_token": "access_abc",
            "refresh_token": "refresh_xyz"
        }
        """
        let data = Data(json.utf8)

        // When
        let decoder = JSONDecoder.decoderDefault()
        let dto = try decoder.decode(ComplexDTO.self, from: data)

        // Then
        #expect(dto.userId == "user123")
        #expect(dto.accessToken == "access_abc")
        #expect(dto.refreshToken == "refresh_xyz")
    }
}
