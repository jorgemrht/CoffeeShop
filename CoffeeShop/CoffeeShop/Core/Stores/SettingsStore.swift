import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class SettingsStore {

    private let logRepository: LogRepositoryImpl

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }

    public init(appDependencies: AppDependencies) {
        self.logRepository = appDependencies.logRepository
    }
}
