import Foundation
import Domain

public final class MockAuthRepository: AuthRepository {

    public let shouldSucceed: Bool
    public let delaySeconds: Double
    public let mockToken: String

    public init(
        shouldSucceed: Bool = true,
        delaySeconds: Double = 1.0,
        mockToken: String = "mock_token_123"
    ) {
        self.shouldSucceed = shouldSucceed
        self.delaySeconds = delaySeconds
        self.mockToken = mockToken
    }

    public func login(email: String, password: String) async throws -> UserSession {
        try await Task.sleep(for: .seconds(delaySeconds))

        if shouldSucceed {
            return UserSession(token: mockToken)
        } else {
            throw MockAuthError.invalidCredentials
        }
    }

    public func register(email: String, password: String) async throws -> UserSession {
        try await Task.sleep(for: .seconds(delaySeconds))

        if shouldSucceed {
            return UserSession(token: mockToken)
        } else {
            throw MockAuthError.userAlreadyExists
        }
    }
}

// MARK: - Mock Errors

public enum MockAuthError: Error, LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case networkError

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .userAlreadyExists:
            return "El usuario ya existe"
        case .networkError:
            return "Error de red"
        }
    }
}
