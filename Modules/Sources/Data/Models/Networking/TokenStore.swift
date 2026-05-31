import Foundation

public actor TokenStore {
    private let keychain: KeychainTokenStore

    public init(
        service: String,
        account: String = "auth-token"
    ) {
        self.keychain = KeychainTokenStore(service: service, account: account)
    }

    public func token() async throws -> Token? {
        try await keychain.token()
    }

    public func save(_ token: Token) async throws {
        try await keychain.save(token)
    }

    public func clear() async throws {
        try await keychain.clear()
    }
}
