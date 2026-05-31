import Foundation
import Testing
@testable import Data
@testable import Domain

struct AuthManagerTests {
    @Test func saveSessionStoresCurrentToken() async throws {
        // Given
        let store = TokenStore(service: "AuthManagerTests-\(UUID().uuidString)")
        let authManager = AuthManager(tokenStore: store)
        let expiry = Date().addingTimeInterval(3600)

        // When
        try await authManager.saveSession(
            UserSession(
                token: "access-token",
                refreshToken: "refresh-token",
                expiry: expiry
            )
        )

        // Then
        let token = await authManager.currentToken()
        #expect(token?.value == "access-token")
        #expect(token?.refreshValue == "refresh-token")
        #expect(token?.expiry == expiry)

        try await store.clear()
    }

    @Test func refreshTokenUsesRefreshProviderAndPersistsNewToken() async throws {
        // Given
        let store = TokenStore(service: "AuthManagerTests-\(UUID().uuidString)")
        try await store.save(
            Token(
                value: "old-access",
                refreshValue: "refresh-token",
                expiry: Date().addingTimeInterval(-3600)
            )
        )
        let authManager = AuthManager(
            tokenStore: store,
            refreshProvider: { refreshToken in
                #expect(refreshToken == "refresh-token")
                return Token(
                    value: "new-access",
                    refreshValue: "new-refresh",
                    expiry: Date().addingTimeInterval(3600)
                )
            }
        )

        // When
        let refreshedToken = try await authManager.refreshToken()

        // Then
        let storedToken = await authManager.currentToken()
        #expect(refreshedToken == "new-access")
        #expect(storedToken?.value == "new-access")
        #expect(storedToken?.refreshValue == "new-refresh")

        try await store.clear()
    }
}
