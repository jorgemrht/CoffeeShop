import Foundation
import Testing
@testable import Data

struct EncryptedStartupVerificationEndpointsTests {

    @Test func encryptedStartupVerificationEndpoint() throws {
        // When
        let endpoint = EncryptedStartupVerificationEndpoints.verifyEncryptedPayload.endpoint

        // Then
        #expect(endpoint.path == "/test/encrypted")
        #expect(endpoint.method == .POST)
        #expect(endpoint.body == nil)
        #expect(endpoint.encryption == .requestAndEncryptedKeyValueResponse)
        #expect(endpoint.requiresAuthentication == false)

        let request = try endpoint.makeURLRequest(baseURL: "https://api.example.com")
        #expect(request.httpBody == nil)
    }
}
