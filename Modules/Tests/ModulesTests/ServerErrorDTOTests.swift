import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - ServerErrorDTO Tests

struct ServerErrorDTOTests {

    @Test func serverErrorDTODecodesCorrectly() throws {
        // Given: Valid server error JSON
        let json = """
        {
            "identifier": "AUTH_FAILED",
            "message": "Invalid credentials"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding ServerErrorDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(ServerErrorDTO.self, from: data)

        // Then: Should decode all properties correctly
        #expect(dto.identifier == "AUTH_FAILED")
        #expect(dto.message == "Invalid credentials")
    }

    @Test func serverErrorDTODecodesWithNilValues() throws {
        // Given: Server error JSON with null values
        let json = """
        {
            "identifier": null,
            "message": null
        }
        """
        let data = Data(json.utf8)

        // When: Decoding ServerErrorDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(ServerErrorDTO.self, from: data)

        // Then: Should decode with nil values
        #expect(dto.identifier == nil)
        #expect(dto.message == nil)
    }

    @Test func serverErrorDTOEncodesCorrectly() throws {
        // Given: A ServerErrorDTO instance
        let dto = ServerErrorDTO(identifier: "NETWORK_ERROR", message: "Connection timeout")

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: JSON should contain both fields
        #expect(json != nil)
        #expect(json!.contains("NETWORK_ERROR"))
        #expect(json!.contains("Connection timeout"))
    }

    @Test func serverErrorDTODecodesWithMissingFields() throws {
        // Given: JSON with missing optional fields
        let json = "{}"
        let data = Data(json.utf8)

        // When: Decoding ServerErrorDTO
        let decoder = JSONDecoder()
        let dto = try decoder.decode(ServerErrorDTO.self, from: data)

        // Then: Should decode with nil values
        #expect(dto.identifier == nil)
        #expect(dto.message == nil)
    }
}
