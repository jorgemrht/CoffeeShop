import CryptoKit
import Foundation
import Testing
@testable import Data

struct PayloadSecurityInterceptorTests {
    private let token = "test-token"

    @Test func encryptsRequestBeforeCallingNext() async throws {
        let interceptor = PayloadSecurityInterceptor(
            dataSource: TestPayloadSecurityDataSource(token: token)
        )
        let plaintext = Data(#"{"email":"user@test.com"}"#.utf8)
        var request = URLRequest(url: URL(string: "https://api.test.com/users/login")!)
        request.httpMethod = "POST"
        request.httpBody = plaintext
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let response = try await interceptor.intercept(
            request: request,
            session: .shared,
            next: { request, _ in
                #expect(request.httpBody != plaintext)

                let envelope = try JSONDecoder().decode(TestEncryptedRequest.self, from: request.httpBody ?? Data())
                #expect(envelope.payload.isEmpty == false)

                let decrypted = try Self.decrypt(
                    envelope.payload,
                    token: token,
                    aad: "req|POST|/users/login"
                )
                #expect(decrypted == plaintext)

                return Self.response(for: request, data: Data())
            }
        )

        #expect(response.statusCode == 200)
    }

    @Test func verifiesSignatureAndDecryptsResponseAfterNext() async throws {
        let signingKey = P256.Signing.PrivateKey()
        let interceptor = PayloadSecurityInterceptor(
            dataSource: TestPayloadSecurityDataSource(
                token: token,
                publicKeyPEM: signingKey.publicKey.pemRepresentation
            )
        )
        var request = URLRequest(url: URL(string: "https://api.test.com/users/login")!)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"email":"user@test.com"}"#.utf8)

        let plaintextResponse = Data(#"{"token":"session-token"}"#.utf8)
        let response = try await interceptor.intercept(
            request: request,
            session: .shared,
            next: { request, _ in
                let encryptedResponse = try Self.encryptedResponse(
                    plaintextResponse,
                    token: token,
                    signingKey: signingKey,
                    method: "POST",
                    path: "/users/login",
                    statusCode: 200
                )
                return Self.response(
                    for: request,
                    data: encryptedResponse,
                    headers: ["Content-Type": "application/json"]
                )
            }
        )

        #expect(response.data == plaintextResponse)
    }

    @Test func throwsWhenResponseSignatureIsInvalid() async throws {
        let trustedSigningKey = P256.Signing.PrivateKey()
        let untrustedSigningKey = P256.Signing.PrivateKey()
        let interceptor = PayloadSecurityInterceptor(
            dataSource: TestPayloadSecurityDataSource(
                token: token,
                publicKeyPEM: trustedSigningKey.publicKey.pemRepresentation
            )
        )
        var request = URLRequest(url: URL(string: "https://api.test.com/users/login")!)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"email":"user@test.com"}"#.utf8)

        await #expect(throws: PayloadSecurityError.self) {
            _ = try await interceptor.intercept(
                request: request,
                session: .shared,
                next: { request, _ in
                    let encryptedResponse = try Self.encryptedResponse(
                        Data(#"{"token":"session-token"}"#.utf8),
                        token: token,
                        signingKey: untrustedSigningKey,
                        method: "POST",
                        path: "/users/login",
                        statusCode: 200
                    )
                    return Self.response(
                        for: request,
                        data: encryptedResponse,
                        headers: ["Content-Type": "application/json"]
                    )
                }
            )
        }
    }
}

private struct TestPayloadSecurityDataSource: PayloadSecurityDataSource {
    let token: String
    let publicKeyPEM: String

    init(
        token: String,
        publicKeyPEM: String = P256.Signing.PrivateKey().publicKey.pemRepresentation
    ) {
        self.token = token
        self.publicKeyPEM = publicKeyPEM
    }

    func clientSeed() throws -> String {
        token
    }

    func verificationKey() throws -> String {
        publicKeyPEM
    }
}

private struct TestEncryptedRequest: Decodable {
    let payload: String
}

private struct TestEncryptedResponse: Encodable {
    let payload: String
    let signature: String
}

private extension PayloadSecurityInterceptorTests {
    static func response(
        for request: URLRequest,
        data: Data,
        headers: [String: String] = [:]
    ) -> APIResponse {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: headers
        )!
        return APIResponse(request: request, response: response, data: data)
    }

    static func encryptedResponse(
        _ data: Data,
        token: String,
        signingKey: P256.Signing.PrivateKey,
        method: String,
        path: String,
        statusCode: Int
    ) throws -> Data {
        let payload = try encrypt(
            data,
            token: token,
            aad: "res|\(method)|\(path)|\(statusCode)"
        )
        let signedData = Data("sig|\(method)|\(path)|\(statusCode)|\(payload)".utf8)
        let signature = try signingKey.signature(for: signedData).rawRepresentation.base64URLEncodedString()
        return try JSONEncoder().encode(TestEncryptedResponse(payload: payload, signature: signature))
    }

    static func encrypt(_ data: Data, token: String, aad: String) throws -> String {
        let sealedBox = try AES.GCM.seal(
            data,
            using: symmetricKey(token: token),
            authenticating: Data(aad.utf8)
        )
        return sealedBox.combined!.base64URLEncodedString()
    }

    static func decrypt(_ payload: String, token: String, aad: String) throws -> Data {
        try AES.GCM.open(
            AES.GCM.SealedBox(combined: Data(base64URLEncoded: payload)!),
            using: symmetricKey(token: token),
            authenticating: Data(aad.utf8)
        )
    }

    static func symmetricKey(token: String) -> SymmetricKey {
        HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(token.utf8)),
            salt: Data("CoffeeShop.PayloadSecurity".utf8),
            info: Data(),
            outputByteCount: 32
        )
    }
}

private extension Data {
    init?(base64URLEncoded value: String) {
        let padding = String(repeating: "=", count: (4 - value.count % 4) % 4)
        let base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        self.init(base64Encoded: base64)
    }

    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
