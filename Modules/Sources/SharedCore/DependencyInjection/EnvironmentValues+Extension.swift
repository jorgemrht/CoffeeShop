import SwiftUI
import Data
import Domain
import Tracking

public extension EnvironmentValues {
    @Entry var appState: AppState?
    @Entry var networkClient: NetworkClient?
    @Entry var logRepository: LogRepositoryImpl?
}
