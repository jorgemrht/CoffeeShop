import Testing
import Foundation
@testable import Domain
@testable import Data

struct LoginDTOTests {

    @Test func loginResponseDTOToUserSession() throws {
        // Given
        let dto = LoginResponseDTO(
            token: "session_token_abc",
            refreshToken: "refresh_token_xyz",
            expiresIn: 3600
        )

        // When
        let userSession = dto.toDomain()

        // Then
        #expect(userSession.token == "session_token_abc")
        #expect(userSession.refreshToken == "refresh_token_xyz")
        #expect(userSession.expiry != nil)
    }
}
