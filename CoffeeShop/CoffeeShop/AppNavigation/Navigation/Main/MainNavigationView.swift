import SwiftUI
import DesignSystem

public struct MainNavigationView: View {
    
    @State private var mainRouter = MainRouter()
    private let onLogoutRequested: @MainActor () -> Void

    public init(onLogoutRequested: @escaping @MainActor () -> Void) {
        self.onLogoutRequested = onLogoutRequested
    }

    public var body: some View {
        @Bindable var mainRouter = mainRouter

        MainViewScreen()
            .environment(mainRouter)
            .sheet(item: $mainRouter.presentedSheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsNavigationView(
                        onClose: {
                            mainRouter.dismiss()
                        },
                        onLogoutRequested: onLogoutRequested
                    )
                }
            }
    }
}
