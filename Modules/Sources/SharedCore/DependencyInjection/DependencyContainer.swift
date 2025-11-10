import SwiftUI
import Data
import Domain
import Tracking

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

    public func coffeeRepository() -> CoffeeRepository {
        guard let networkClient = environment.networkClient else {
            fatalError("NetworkClient not found in Environment")
        }
        return CoffeeRepositoryImpl(networkClient: networkClient)
    }

    public func logRepository() -> LogRepositoryImpl {
        guard let logRepository = environment.logRepository else {
            fatalError("LogRepository not found in Environment")
        }
        return logRepository
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
