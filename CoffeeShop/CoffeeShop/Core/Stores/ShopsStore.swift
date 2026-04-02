import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class ShopsStore {

    private let logRepository: LogRepositoryImpl

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }

    public init(appDependencies: AppDependencies) {
        self.logRepository = appDependencies.logRepository
    }
}
