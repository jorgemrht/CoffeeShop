import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class MainStore {

    private let logRepository: LogRepositoryImpl

    public var showSettings: Bool = false

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }

    public init(appDependencies: AppDependencies) {
        self.logRepository = appDependencies.logRepository
    }

    public func navigateToSettings() {
        showSettings = true
    }
}
