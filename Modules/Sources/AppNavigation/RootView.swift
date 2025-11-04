import SwiftUI
import SharedCore
import FeatureLogin
import FeatureRegister

public struct RootView: View {

    @Environment(AppState.self) private var appState

    public init() {}

    public var body: some View {
        Group {
            switch appState.root {
            case .splash:
                Text("Splash")
            case .auth:
                LoginViewScreen()
            case .home:
                Text("Login")
            }
        }
    }

}
