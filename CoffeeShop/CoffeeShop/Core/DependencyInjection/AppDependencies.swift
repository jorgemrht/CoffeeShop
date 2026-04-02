import Data
import Domain

public struct AppDependencies {

    public let networkClient: NetworkClient
    public let logRepository: LogRepositoryImpl
    private let authRepositoryFactory: (() -> AuthRepository)?
    private let coffeeRepositoryFactory: (() -> CoffeeRepository)?

    public init(
        networkClient: NetworkClient,
        logRepository: LogRepositoryImpl
    ) {
        self.networkClient = networkClient
        self.logRepository = logRepository
        self.authRepositoryFactory = nil
        self.coffeeRepositoryFactory = nil
    }

    private init(
        networkClient: NetworkClient,
        logRepository: LogRepositoryImpl,
        authRepositoryFactory: @escaping () -> AuthRepository,
        coffeeRepositoryFactory: @escaping () -> CoffeeRepository
    ) {
        self.networkClient = networkClient
        self.logRepository = logRepository
        self.authRepositoryFactory = authRepositoryFactory
        self.coffeeRepositoryFactory = coffeeRepositoryFactory
    }

    public func makeAuthRepository() -> AuthRepository {
        authRepositoryFactory?() ?? AuthRepositoryImpl(networkClient: networkClient)
    }

    public func makeCoffeeRepository() -> CoffeeRepository {
        coffeeRepositoryFactory?() ?? CoffeeRepositoryImpl(networkClient: networkClient)
    }

    @MainActor
    public static var current: AppDependencies {
        #if DEBUG
        .preview
        #else
        .live
        #endif
    }

    private static var live: AppDependencies {
        let networkClient = NetworkClient.default()
        let logRepository = LogRepositoryImpl.default()

        return AppDependencies(
            networkClient: networkClient,
            logRepository: logRepository
        )
    }

    private static var preview: AppDependencies {
        AppDependencies(
            networkClient: PreviewHelper.mockNetworkClient,
            logRepository: MockLogRepository.mock,
            authRepositoryFactory: { MockAuthRepository() },
            coffeeRepositoryFactory: { MockCoffeeRepository() }
        )
    }
}

#if DEBUG
public extension AppDependencies {
    static var mock: AppDependencies { .current }
}
#endif
