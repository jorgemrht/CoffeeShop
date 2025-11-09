import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class MainStore: Injectable {

    public enum Navigation {
        case settings
    }

    private let logRepository: LogRepositoryImpl

    public var navigation: Navigation?

    // MARK: - Initialization

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }

    public func navigateToSettings() {
        navigation = .settings
    }
}

extension MainStore {
    public static func resolve(from container: DependencyContainer) -> MainStore {
        MainStore(
            logRepository: container.logRepository()
        )
    }
}
