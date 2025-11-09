import SwiftUI
import SharedCore
import Tracking

public struct MainViewScreen: View {

    @Environment(MainStore.self) private var mainStore
    @Environment(AppState.self) private var appState

    public init() { }

    public var body: some View {

        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.coffeePath) {
                CoffeeTabView()
                    .navigationDestination(for: CoffeeRoute.self) { route in
                        switch route {
                        case .detail(let id):
                            Text("Coffee Detail \(id)")
                        case .main:
                            EmptyView()
                        }
                    }
            }
            .tabItem {
                Label("Coffee", systemImage: "cup.and.saucer.fill")
            }
            .tag(TabRoute.coffee)

            NavigationStack(path: $appState.shopsPath) {
                ShopsTabView()
                    .navigationDestination(for: ShopsRoute.self) { route in
                        switch route {
                        case .main:
                            EmptyView()
                        }
                    }
            }
            .tabItem {
                Label("Shops", systemImage: "storefront.fill")
            }
            .tag(TabRoute.shops)
        }
        .onChange(of: mainStore.navigation) { _, newValue in
            guard let newValue else { return }

            switch newValue {
            case .settings:
                appState.settingsPath.append(.settings)
            }
        }
    }
}

// MARK: - Coffee Tab View

private struct CoffeeTabView: View {
    @Environment(MainStore.self) private var mainStore

    var body: some View {
        VStack(spacing: 24) {
            Text("Coffee")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Explore our coffee catalog")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Coffee")
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

// MARK: - Shops Tab View

private struct ShopsTabView: View {
    @Environment(MainStore.self) private var mainStore

    var body: some View {
        VStack(spacing: 24) {
            Text("Shops")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Find our stores")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Shops")
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
                logRepository: LogRepositoryImpl.default(
                    deviceInfo: DeviceInfo(
                        appVersion: "1.0",
                        buildNumber: "1",
                        deviceModel: "iPhone"
                    ),
                    bundleIdentifier: "com.coffeeshop.preview"
                )
            )
        )
        .environment(AppState(root: .main))
}
