import Foundation

public actor TokenStore {
    private var currentToken: Token?

    public init() {
    }

    public func token() async throws -> Token? {
        currentToken
    }

    public func save(_ token: Token) async throws {
        currentToken = token
    }

    public func clear() async throws {
        currentToken = nil
    }
}
