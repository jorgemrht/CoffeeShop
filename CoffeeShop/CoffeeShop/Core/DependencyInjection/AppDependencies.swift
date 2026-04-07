import Data
import SwiftUI
import Domain

public struct AppDependencies {

    public let networkClient: NetworkClient
    public let logRepository: LogRepositoryImpl
    private let authRepositoryFactory: (() -> AuthRepository)?
    private let coffeeRepositoryFactory: (() -> CoffeeRepository)?
    private let shopRepositoryFactory: (() -> ShopRepository)?

    public init(
        networkClient: NetworkClient,
        logRepository: LogRepositoryImpl
    ) {
        self.networkClient = networkClient
        self.logRepository = logRepository
        self.authRepositoryFactory = nil
        self.coffeeRepositoryFactory = nil
        self.shopRepositoryFactory = nil
    }
}

public extension EnvironmentValues {
    @Entry var appDependencies = AppDependencies.live
}

// Live

extension AppDependencies {
    
    public static var live: AppDependencies {
        let networkClient = NetworkClient.default()
        let logRepository = LogRepositoryImpl.default()

        return AppDependencies(
            networkClient: networkClient,
            logRepository: logRepository
        )
    }
    
    public func makeAuthRepository() -> AuthRepository {
        authRepositoryFactory?() ?? AuthRepositoryImpl(networkClient: networkClient)
    }

    public func makeCoffeeRepository() -> CoffeeRepository {
        coffeeRepositoryFactory?() ?? CoffeeRepositoryImpl(networkClient: networkClient)
    }

    public func makeShopRepository() -> ShopRepository {
        shopRepositoryFactory?() ?? ShopRepositoryImpl(networkClient: networkClient)
    }
}

// Mocks

extension AppDependencies {
    
    private init(
        networkClient: NetworkClient,
        logRepository: LogRepositoryImpl,
        authRepositoryFactory: @escaping () -> AuthRepository,
        coffeeRepositoryFactory: @escaping () -> CoffeeRepository,
        shopRepositoryFactory: @escaping () -> ShopRepository
    ) {
        self.networkClient = networkClient
        self.logRepository = logRepository
        self.authRepositoryFactory = authRepositoryFactory
        self.coffeeRepositoryFactory = coffeeRepositoryFactory
        self.shopRepositoryFactory = shopRepositoryFactory
    }

    
    public static var preview: AppDependencies {
        mockDependencies()
    }
    
    public static var test: AppDependencies {
        mockDependencies()
    }
    
    private static func mockDependencies() -> AppDependencies {
        AppDependencies(
            networkClient: PreviewHelper.mockNetworkClient,
            logRepository: MockLogRepository.mock,
            authRepositoryFactory: { MockAuthRepository() },
            coffeeRepositoryFactory: { MockCoffeeRepository() },
            shopRepositoryFactory: { MockShopRepository() }
        )
    }
}
