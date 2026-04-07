import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class CoffeeStore: StoreProtocol, StoreErrorProtocol {

    private let coffeeRepository: CoffeeRepository
    private let logRepository: LogRepositoryImpl

    public var coffeeShops: [CoffeeShops] = []
    public var coffeeDetail: CoffeeDetail?
    public var isLoading: Bool = false
    public var errorAlert: ErrorAlertPresentation?

    public init(
        coffeeRepository: CoffeeRepository,
        logRepository: LogRepositoryImpl
    ) {
        self.coffeeRepository = coffeeRepository
        self.logRepository = logRepository
    }

    public init(environment: AppDependencies) {
        self.coffeeRepository = environment.makeCoffeeRepository()
        self.logRepository = environment.logRepository
    }

    public func loadCoffees() async {
        do {
            try await withLoading {
                coffeeShops = try await coffeeRepository.getCoffees()
            }
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Unable to Load Coffees",
                message: "We could not load the coffee list right now.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .network, error: error)
        }
    }

    public func loadCoffeeDetail(id: Int) async {
        do {
            try await withLoading {
                coffeeDetail = try await coffeeRepository.getCoffeeDetail(id: id)
            }
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Unable to Load Coffee Detail",
                message: "We could not load the coffee detail right now.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .network, error: error)
        }
    }
}
