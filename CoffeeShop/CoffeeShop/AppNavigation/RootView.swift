import SwiftUI

public struct AppRootView: View {

    @State private var appState = AppState(root: .splash)

    public init() { }

    public var body: some View {
        Group {
            switch appState.root {
            case .splash:
                SplashViewScreen()
            case .auth:
                AuthNavigationView()
            case .main:
                MainNavigationView()
            }
        }
        .id(appState.root)
        .environment(appState)
        .animation(.easeInOut, value: appState.root)
    }
}
