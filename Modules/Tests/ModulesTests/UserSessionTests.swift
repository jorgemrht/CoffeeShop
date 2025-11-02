import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - UserSession Tests

struct UserSessionTests {

    @Test func userSessionCreatesWithToken() {
        // Given: A token
        let token = "test_token_123"

        // When: Creating UserSession
        let session = UserSession(token: token)

        // Then: Should store token correctly
        #expect(session.token == "test_token_123")
    }

    @Test func userSessionIsSendable() {
        // Given: A UserSession
        let session = UserSession(token: "token")

        // When: Checking Sendable conformance (compile-time)
        // Then: Should compile (UserSession conforms to Sendable)
        let _: any Sendable = session
        #expect(session.token == "token")
    }
}
