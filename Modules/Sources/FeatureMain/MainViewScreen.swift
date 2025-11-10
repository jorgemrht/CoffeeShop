import SwiftUI
import SharedCore
import Tracking
import FeatureCoffee
import FeatureCoffeeDetail
import FeatureShops
import FeatureShopDetail
import FeatureSettings
import TestHelpers

public struct MainViewScreen: View {

    @Environment(MainStore.self) private var mainStore
    @Environment(AppState.self) private var appState

    public init() { }

    public var body: some View {

        @Bindable var appState = appState
        @Bindable var mainStore = mainStore

        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.coffeePath) {
                CoffeeViewScreen()
                    .navigationTitle("Coffee")
                    .withStore(CoffeeStore.self)
                    .navigationDestination(for: CoffeeRoute.self) { route in
                        switch route {
                        case .detail(let id):
                            CoffeeDetailViewScreen(coffeeId: id)
                                .withStore(CoffeeDetailStore.self)
                        }
                    }
                    .modifier(SettingsToolbarModifier())
            }
            .tabItem {
                Label("Coffee", systemImage: "cup.and.saucer.fill")
            }
            .tag(TabRoute.coffee)

            NavigationStack(path: $appState.shopsPath) {
                ShopsViewScreen()
                    .navigationTitle("Shops")
                    .withStore(ShopsStore.self)
                    .navigationDestination(for: ShopsRoute.self) { route in
                        switch route {
                        case .detail(let id):
                            ShopDetailViewScreen(shopId: id)
                                .withStore(ShopsStore.self)
                        }
                    }
                    .modifier(SettingsToolbarModifier())
            }
            .tabItem {
                Label("Shops", systemImage: "storefront.fill")
            }
            .tag(TabRoute.shops)
        }
        .sheet(isPresented: $mainStore.showSettings) {
            NavigationStack(path: $appState.settingsPath) {
                SettingsViewScreen()
                    .withStore(SettingsStore.self)
                    .navigationDestination(for: SettingsRoute.self) { route in
                        switch route {
                        case .settings: EmptyView()
                        }
                    }
            }
        }
    }
}

private struct SettingsToolbarModifier: ViewModifier {

    @Environment(MainStore.self) private var mainStore

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mainStore.navigateToSettings()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
    }
}

#Preview {
    MainViewScreen()
        .environment(
            MainStore(
                logRepository: MockLogRepository.mock
            )
        )
        .environment(AppState(root: .main))
        .environment(\.logRepository, MockLogRepository.mock)
        .environment(\.networkClient, PreviewHelper.mockNetworkClient)
}

