import SwiftUI
import Data
import Domain

@MainActor
public struct DependencyContainer {
    
    private let environment: EnvironmentValues

    public init(environment: EnvironmentValues) {
        self.environment = environment
    }
}

// MARK: - Repository Factories

extension DependencyContainer {
    public func authRepository() -> AuthRepository {
        guard let networkClient = environment.networkClient else {
            fatalError("NetworkClient not found in Environment")
        }
        return AuthRepositoryImpl(networkClient: networkClient)
    }
}

// MARK: - Store Factories

extension DependencyContainer {
    public func loginStore() -> LoginStore {
        LoginStore(authRepository: authRepository())
    }

    public func registerStore() -> RegisterStore {
        RegisterStore(authRepository: authRepository())
    }
}

// MARK: - Test/Preview Support

extension DependencyContainer {
    public static func mock(
        networkClient: NetworkClient? = nil
    ) -> DependencyContainer {
        var mockEnvironment = EnvironmentValues()

        if let networkClient = networkClient {
            mockEnvironment.networkClient = networkClient
        }

        return DependencyContainer(environment: mockEnvironment)
    }
}
