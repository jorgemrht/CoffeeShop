import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class CoffeeStore {

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

    public init(appDependencies: AppDependencies) {
        self.coffeeRepository = appDependencies.makeCoffeeRepository()
        self.logRepository = appDependencies.logRepository
    }

    public func loadCoffees() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            coffeeShops = try await coffeeRepository.getCoffees()
        } catch {
            errorMessage = error.localizedDescription
            await logRepository.log(.error, .network, error: error)
        }
    }
}
