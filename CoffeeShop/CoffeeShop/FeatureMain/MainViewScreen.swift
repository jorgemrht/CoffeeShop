import SwiftUI

public struct MainViewScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.appDependencies) private var environment
    @State private var mainStore: MainStore?

    public init() { }

    public var body: some View {
        Group {
            if let mainStore {
                @Bindable var appState = appState
                @Bindable var mainStore = mainStore

                TabView(selection: $appState.selectedTab) {
                    CoffeeNavigationView(showSettings: $mainStore.showSettings)
                        .tabItem {
                            Label("Coffee", systemImage: "cup.and.saucer.fill")
                        }
                        .tag(TabRoute.coffee)

                    ShopsNavigationView(showSettings: $mainStore.showSettings)
                        .tabItem {
                            Label("Shops", systemImage: "storefront.fill")
                        }
                        .tag(TabRoute.shops)
                }
                .sheet(isPresented: $mainStore.showSettings) {
                    SettingsNavigationView()
                }
            } else {
                ProgressView()
            }
        }
        .task {
            if mainStore == nil {
                mainStore = MainStore(appDependencies: environment)
            }
        }
    }
}

struct SettingsToolbarModifier: ViewModifier {

    @Binding var showSettings: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
    }
}

#Preview {
    MainViewScreen()
        .withPreviewEnvironment()
}
