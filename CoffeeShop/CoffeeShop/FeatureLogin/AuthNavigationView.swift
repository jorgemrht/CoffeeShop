import SwiftUI

public struct AuthNavigationView: View {

    @Environment(AppState.self) private var appState

    public init() { }

    public var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.authPath) {
            LoginViewScreen()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .register:
                        RegisterViewScreen()
                    }
                }
        }
    }
}
