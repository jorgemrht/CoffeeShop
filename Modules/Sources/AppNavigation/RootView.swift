import SwiftUI
import SharedCore
import FeatureSplash
import FeatureLogin
import FeatureRegister
import Data

public struct RootView: View {

    @State private var appState = AppState(root: .splash)
    
    @State private var networkClient = NetworkClient(
        baseURL: Environment.current.baseURL.absoluteString,
        interceptors: []
    )

    public init() {}

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
        .animation(.easeInOut, value: appState.root)
    }
}
