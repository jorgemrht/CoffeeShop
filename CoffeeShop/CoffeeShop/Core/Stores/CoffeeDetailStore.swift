import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class CoffeeDetailStore {

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

    public init(appDependencies: AppDependencies) {
        self.coffeeRepository = appDependencies.makeCoffeeRepository()
        self.logRepository = appDependencies.logRepository
    }

    public func loadDetails(id: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            coffeeDetail = try await coffeeRepository.getCoffeeDetail(id: id)
        } catch {
            errorMessage = error.localizedDescription
            await logRepository.log(.error, .network, error: error)
        }
    }
}
