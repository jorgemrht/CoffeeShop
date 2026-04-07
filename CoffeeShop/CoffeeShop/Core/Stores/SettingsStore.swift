import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class SettingsStore: StoreProtocol, StoreErrorProtocol {

    private let logRepository: LogRepositoryImpl
    public var isLoading: Bool = false
    public var errorAlert: ErrorAlertPresentation?

    public init(logRepository: LogRepositoryImpl) {
        self.logRepository = logRepository
    }

    public init(environment: AppDependencies) {
        self.logRepository = environment.logRepository
    }
}
