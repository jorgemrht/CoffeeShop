import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class SettingsStore: Injectable {

    private let logRepository: LogRepositoryImpl

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }
}

extension SettingsStore {
    public static func resolve(from container: DependencyContainer) -> SettingsStore {
        SettingsStore(
            logRepository: container.logRepository()
        )
    }
}
