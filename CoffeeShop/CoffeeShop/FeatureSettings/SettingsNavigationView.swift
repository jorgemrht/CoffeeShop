import SwiftUI

public struct SettingsNavigationView: View {

    @Environment(AppState.self) private var appState

    public init() { }

    public var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.settingsPath) {
            SettingsViewScreen()
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .settings:
                        EmptyView()
                    }
                }
        }
    }
}
