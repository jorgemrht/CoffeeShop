import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class ShopsStore: Injectable {

    private let logRepository: LogRepositoryImpl

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }
}

extension ShopsStore {
    public static func resolve(from container: DependencyContainer) -> ShopsStore {
        ShopsStore(
            logRepository: container.logRepository()
        )
    }
}
