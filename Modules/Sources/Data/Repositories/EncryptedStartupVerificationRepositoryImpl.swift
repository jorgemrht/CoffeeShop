import Foundation

public struct EncryptedStartupVerificationRepositoryImpl: Sendable {

    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func verifyEncryptedStartupPayload() async throws -> String {
        let response = try await networkClient.request(
            EncryptedStartupVerificationEndpoints.verifyEncryptedPayload.endpoint
        )

        guard let decryptedJSON = String(data: response.data, encoding: .utf8) else {
            throw APIError.decodingFailed(URLError(.cannotDecodeContentData))
        }

        return decryptedJSON
    }
}
