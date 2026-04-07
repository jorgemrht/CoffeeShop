import SwiftUI
import DesignSystem

public struct SettingsNavigationView: View {
    
    @Environment(\.appDependencies) private var dependencies
    @State private var settingsRouter = SettingsRouter()
    private let onClose: @MainActor () -> Void
    private let onLogoutRequested: @MainActor () -> Void

    public init(
        onClose: @escaping @MainActor () -> Void = { },
        onLogoutRequested: @escaping @MainActor () -> Void = { }
    ) {
        self.onClose = onClose
        self.onLogoutRequested = onLogoutRequested
    }

    public var body: some View {
        @Bindable var settingsRouter = settingsRouter

        NavigationStack(path: $settingsRouter.path) {
            SettingsViewScreen(
                environment: dependencies,
                onLogoutRequested: onLogoutRequested
            )
            .toolbar {
                ToolbarItemContent(symbol: .close, action: {
                    onClose()
                })
            }
        }
        .environment(settingsRouter)
    }
}
