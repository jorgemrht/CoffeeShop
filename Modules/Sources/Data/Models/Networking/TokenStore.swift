import Foundation

public actor TokenStore {
    private let keychainDataSource: any KeychainDataSource
    private let tokenDescriptor: KeychainItemDescriptor
    private var currentToken: Token?

    public init(
        keychainDataSource: any KeychainDataSource,
        service: String
    ) {
        self.keychainDataSource = keychainDataSource
        self.tokenDescriptor = KeychainItemDescriptor(
            service: service,
            account: KeychainAccountName.sessionToken,
            accessibility: .afterFirstUnlockThisDeviceOnly
        )
    }

    public func token() async throws -> Token? {
        if let currentToken {
            return currentToken
        }

        guard let data = try keychainDataSource.readData(for: tokenDescriptor) else {
            return nil
        }

        let token = try JSONDecoder().decode(Token.self, from: data)
        currentToken = token
        return token
    }

    public func save(_ token: Token) async throws {
        currentToken = token
        let data = try JSONEncoder().encode(token)
        try keychainDataSource.upsert(data, for: tokenDescriptor)
    }

    public func clear() async throws {
        currentToken = nil
        try keychainDataSource.deleteValue(for: tokenDescriptor)
    }
}
