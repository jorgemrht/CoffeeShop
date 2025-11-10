import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class CoffeeStore: Injectable {

    private let coffeeRepository: CoffeeRepository
    private let logRepository: LogRepositoryImpl

    public var coffeeShops: [CoffeeShops] = []
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init(
        coffeeRepository: CoffeeRepository,
        logRepository: LogRepositoryImpl
    ) {
        self.coffeeRepository = coffeeRepository
        self.logRepository = logRepository
    }

    public func loadCoffees() async {
        isLoading = true
        errorMessage = nil

        do {
            coffeeShops = try await coffeeRepository.getCoffees()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

extension CoffeeStore {
    public static func resolve(from container: DependencyContainer) -> CoffeeStore {
        CoffeeStore(
            coffeeRepository: container.coffeeRepository(),
            logRepository: container.logRepository()
        )
    }
}
