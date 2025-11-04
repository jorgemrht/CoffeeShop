
public protocol AuthRepository: Sendable {
    func login(email: String, password: String) async throws -> UserSession
    func register(email: String, password: String) async throws -> UserSession
}
