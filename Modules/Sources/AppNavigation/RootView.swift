import SwiftUI
import SharedCore
import FeatureSplash
import FeatureLogin
import FeatureRegister
import Data
import Tracking
import Domain

public struct RootView: View {

    @State private var appState = AppState(root: .splash)
    @State private var networkClient: NetworkClient
    @State private var logRepository: LogRepositoryImpl

    public init(bundle: Bundle) {
        self.networkClient = NetworkClient.default(bundleIdentifier: bundle.bundleIdentifier)
        let appInfo = AppInfo(bundle: bundle)
        self.logRepository = LogRepositoryImpl.default(
            deviceInfo: .init(appVersion: appInfo.appVersion, buildNumber: appInfo.buildNumber, deviceModel: appInfo.deviceModel),
            bundleIdentifier: bundle.bundleIdentifier
        )
    }

    public var body: some View {
        Group {
            switch appState.root {
            case .splash:
                SplashViewScreen()

            case .auth:
                LoginViewScreen()
                    .withStore(LoginStore.self)

            case .home:
                Text("Home")
            }
        }
        .environment(appState)
        .environment(\.networkClient, networkClient)
        .environment(\.logRepository, logRepository)
        .animation(.easeInOut, value: appState.root)
    }
}
