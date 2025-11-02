import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - RegisterRequestDTO Tests

struct RegisterRequestDTOTests {

    @Test func registerRequestDTOCreatesWithEmailAndPassword() {
        // Given: Email and password
        let email = "newuser@test.com"
        let password = "securePassword123"

        // When: Creating RegisterRequestDTO
        let dto = RegisterRequestDTO(email: email, password: password)

        // Then: Should store values correctly
        #expect(dto.email == "newuser@test.com")
        #expect(dto.password == "securePassword123")
    }

    @Test func registerRequestDTOEncodesCorrectly() throws {
        // Given: A RegisterRequestDTO
        let dto = RegisterRequestDTO(email: "test@example.com", password: "myPassword")

        // When: Encoding with standard encoder
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: Should contain email and password
        #expect(json != nil)
        #expect(json!.contains("test@example.com"))
        #expect(json!.contains("myPassword"))
    }

    @Test func registerRequestDTOEncodesWithSnakeCaseStrategy() throws {
        // Given: A RegisterRequestDTO
        let dto = RegisterRequestDTO(email: "user@domain.com", password: "pass123")

        // When: Encoding with encoderDefault (snake_case strategy)
        let encoder = JSONEncoder.encoderDefault()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: Should contain email and password fields
        #expect(json != nil)
        #expect(json!.contains("\"email\""))
        #expect(json!.contains("\"password\""))
    }

    @Test func registerRequestDTOHandlesSpecialCharactersInEmail() throws {
        // Given: RegisterRequestDTO with special characters
        let dto = RegisterRequestDTO(email: "test+tag@example.co.uk", password: "P@ssw0rd!")

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: Should properly encode special characters
        #expect(json != nil)
        #expect(json!.contains("test+tag@example.co.uk"))
        #expect(json!.contains("P@ssw0rd!"))
    }
}
