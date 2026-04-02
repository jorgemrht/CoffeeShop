import SwiftUI

public struct ShopsNavigationView: View {

    @Environment(AppState.self) private var appState
    @Binding private var showSettings: Bool

    public init(showSettings: Binding<Bool>) {
        _showSettings = showSettings
    }

    public var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.shopsPath) {
            ShopsViewScreen()
                .navigationTitle("Shops")
                .navigationDestination(for: ShopsRoute.self) { route in
                    switch route {
                    case .detail(let id):
                        ShopDetailViewScreen(shopId: id)
                    }
                }
                .modifier(SettingsToolbarModifier(showSettings: $showSettings))
        }
    }
}
