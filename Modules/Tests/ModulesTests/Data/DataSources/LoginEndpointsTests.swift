import Testing
import Foundation
@testable import Data

struct LoginEndpointsTests {

    @Test func loginEndpoint() {
        // Given
        let email = "user@test.com"
        let password = "password123"

        // When
        let endpoint = LoginEndpoints.login(email: email, password: password).endpoint

        // Then
        #expect(endpoint.path == "/auth/login")
        #expect(endpoint.method == .POST)
        #expect(endpoint.body != nil)
    }

    @Test func registerEndpoint() {
        // Given
        let email = "user@test.com"
        let password = "password123"

        // When
        let endpoint = LoginEndpoints.register(email: email, password: password).endpoint

        // Then
        #expect(endpoint.path == "/auth/register")
        #expect(endpoint.method == .POST)
        #expect(endpoint.body != nil)
    }
}
