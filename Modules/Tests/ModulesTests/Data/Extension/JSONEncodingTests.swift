import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - JSON Encoding Tests

struct JSONEncodingTests {

    @Test func encoderDefaultConvertsToSnakeCase() throws {
        // Given
        let dto = LoginRequestDTO(email: "test@example.com", password: "secret123")

        // When
        let encoder = JSONEncoder.encoderDefault()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then
        #expect(json != nil)
        #expect(json!.contains("\"email\""))
        #expect(json!.contains("\"password\""))
    }

    @Test func encoderDefaultHandlesMultipleProperties() throws {
        // Given
        struct TestDTO: Codable {
            let firstName: String
            let lastName: String
            let emailAddress: String
        }
        let dto = TestDTO(firstName: "John", lastName: "Doe", emailAddress: "john@example.com")

        // When
        let encoder = JSONEncoder.encoderDefault()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then
        #expect(json != nil)
        #expect(json!.contains("first_name"))
        #expect(json!.contains("last_name"))
        #expect(json!.contains("email_address"))
    }
}
