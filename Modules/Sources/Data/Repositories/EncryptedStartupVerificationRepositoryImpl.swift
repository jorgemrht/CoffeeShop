import Foundation

public struct EncryptedStartupVerificationRepositoryImpl: Sendable {

    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
}
