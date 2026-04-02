import SwiftUI

public struct CoffeeNavigationView: View {

    @Environment(AppState.self) private var appState
    @Binding private var showSettings: Bool

    public init(showSettings: Binding<Bool>) {
        _showSettings = showSettings
    }

    public var body: some View {
        @Bindable var appState = appState

        NavigationStack(path: $appState.coffeePath) {
            CoffeeViewScreen()
                .navigationTitle("Coffee")
                .navigationDestination(for: CoffeeRoute.self) { route in
                    switch route {
                    case .detail(let id):
                        CoffeeDetailViewScreen(coffeeId: id)
                    }
                }
                .modifier(SettingsToolbarModifier(showSettings: $showSettings))
        }
    }
}
