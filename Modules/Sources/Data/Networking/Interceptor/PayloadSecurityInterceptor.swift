import CryptoKit
import Foundation

public struct PayloadSecurityInterceptor: RequestInterceptor {
    private let keysCache: PayloadSecurityKeysCache

    init(dataSource: any PayloadSecurityDataSource) {
        self.keysCache = PayloadSecurityKeysCache(dataSource: dataSource)
    }

    public init(
        keychainDataSource: any KeychainDataSource,
        keychainService: String
    ) {
        self.init(
            dataSource: PayloadSecurityDataSourceImpl(
                keychainDataSource: keychainDataSource,
                keychainService: keychainService
            )
        )
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping @Sendable (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        let secureRequest = try await secure(request)
        let response = try await next(secureRequest, session)
        let responseData = try await open(response.data, response: response.response, request: secureRequest)
        return APIResponse(request: response.request, response: response.response, data: responseData)
    }
}

private extension PayloadSecurityInterceptor {
    func secure(_ request: URLRequest) async throws -> URLRequest {
        guard let body = request.httpBody, !body.isEmpty else {
            return request
        }

        let keys = try await keysCache.keys()
        let method = request.httpMethod ?? HTTPMethod.GET.rawValue
        let path = request.url?.path ?? "/"
        let aad = Data("req|\(method)|\(path)".utf8)
        let sealedBox = try AES.GCM.seal(body, using: keys.symmetricKey, authenticating: aad)

        guard let combined = sealedBox.combined else {
            throw PayloadSecurityError.missingEncryptedPayload
        }

        let encryptedBody = EncryptedRequestPayload(payload: combined.base64URLEncodedString())
        var secureRequest = request
        secureRequest.httpBody = try JSONEncoder().encode(encryptedBody)
        secureRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return secureRequest
    }

    func open(
        _ data: Data,
        response: HTTPURLResponse,
        request: URLRequest
    ) async throws -> Data {
        guard !data.isEmpty else {
            return data
        }

        guard response.value(forHTTPHeaderField: "Content-Type")?.lowercased().contains("application/json") == true else {
            return data
        }

        guard let envelope = try? JSONDecoder().decode(EncryptedResponsePayload.self, from: data) else {
            throw PayloadSecurityError.missingEncryptedEnvelope
        }

        let keys = try await keysCache.keys()
        let method = request.httpMethod ?? HTTPMethod.GET.rawValue
        let path = request.url?.path ?? "/"

        try verifySignature(
            envelope,
            method: method,
            path: path,
            statusCode: response.statusCode,
            publicKey: keys.serverPublicKey
        )

        guard let combined = Data(base64URLEncoded: envelope.payload) else {
            throw PayloadSecurityError.invalidPayloadEncoding
        }

        let aad = Data("res|\(method)|\(path)|\(response.statusCode)".utf8)
        do {
            return try AES.GCM.open(
                AES.GCM.SealedBox(combined: combined),
                using: keys.symmetricKey,
                authenticating: aad
            )
        } catch {
            throw PayloadSecurityError.decryptionFailed(error)
        }
    }

    func verifySignature(
        _ envelope: EncryptedResponsePayload,
        method: String,
        path: String,
        statusCode: Int,
        publicKey: P256.Signing.PublicKey
    ) throws {
        guard let signatureData = Data(base64URLEncoded: envelope.signature) else {
            throw PayloadSecurityError.invalidSignatureEncoding
        }

        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureData)
        let signedData = Data("sig|\(method)|\(path)|\(statusCode)|\(envelope.payload)".utf8)
        guard publicKey.isValidSignature(signature, for: signedData) else {
            throw PayloadSecurityError.invalidSignature
        }
    }
}

private actor PayloadSecurityKeysCache {
    private let dataSource: any PayloadSecurityDataSource
    private var cachedKeys: PayloadSecurityKeys?

    init(dataSource: any PayloadSecurityDataSource) {
        self.dataSource = dataSource
    }

    func keys() throws -> PayloadSecurityKeys {
        if let cachedKeys {
            return cachedKeys
        }

        let keys = try PayloadSecurityKeys(dataSource: dataSource)
        cachedKeys = keys
        return keys
    }
}

private struct PayloadSecurityKeys: @unchecked Sendable {
    let symmetricKey: SymmetricKey
    let serverPublicKey: P256.Signing.PublicKey

    init(dataSource: any PayloadSecurityDataSource) throws {
        let appIdentityToken = try dataSource.clientSeed()
        let publicKey = try dataSource.verificationKey()

        self.symmetricKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(appIdentityToken.utf8)),
            salt: Data("CoffeeShop.PayloadSecurity".utf8),
            info: Data(),
            outputByteCount: 32
        )
        self.serverPublicKey = try P256.Signing.PublicKey(pemRepresentation: Self.normalizePEM(publicKey))
    }

    private static func normalizePEM(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
    }
}

enum PayloadSecurityError: Error {
    case missingEncryptedEnvelope
    case missingEncryptedPayload
    case invalidPayloadEncoding
    case invalidSignatureEncoding
    case invalidSignature
    case decryptionFailed(Error)
}

private struct EncryptedRequestPayload: Encodable {
    let payload: String
}

private struct EncryptedResponsePayload: Decodable {
    let payload: String
    let signature: String
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
