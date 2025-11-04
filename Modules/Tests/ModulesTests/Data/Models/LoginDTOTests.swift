import Testing
import Foundation
@testable import Domain
@testable import Data

struct LoginDTOTests {

    @Test func loginResponseDTOToUserSession() throws {
        // Given
        let dto = LoginResponseDTO(token: "session_token_abc")

        // When
        let userSession = dto.toDomain()

        // Then
        #expect(userSession.token == "session_token_abc")
    }
}
