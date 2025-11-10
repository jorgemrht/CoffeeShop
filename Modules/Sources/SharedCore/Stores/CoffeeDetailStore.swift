import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class CoffeeDetailStore: Injectable {

    private let coffeeRepository: CoffeeRepository
    private let logRepository: LogRepositoryImpl

    public var coffeeDetail: CoffeeDetail?
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init(
        coffeeRepository: CoffeeRepository,
        logRepository: LogRepositoryImpl
    ) {
        self.coffeeRepository = coffeeRepository
        self.logRepository = logRepository
    }

    public func loadDetails(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            coffeeDetail = try await coffeeRepository.getCoffeeDetail(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

extension CoffeeDetailStore {
    public static func resolve(from container: DependencyContainer) -> CoffeeDetailStore {
        CoffeeDetailStore(
            coffeeRepository: container.coffeeRepository(),
            logRepository: container.logRepository()
        )
    }
}
