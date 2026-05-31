import DesignSystem
import SwiftUI

public struct MainViewScreen: View {
    @Environment(MainRouter.self) private var mainRouter

    public init() { }

    public var body: some View {
        @Bindable var mainRouter = mainRouter

        TabView(selection: $mainRouter.selectedTab) {
            Tab(
                "Coffee",
                systemImage: Symbol.coffee.systemName,
                value: MainRouter.Tab.coffee
            ) {
                CoffeeNavigationView()
            }

            Tab(
                "Shops",
                systemImage: Symbol.shop.systemName,
                value: MainRouter.Tab.shops
            ) {
                ShopsNavigationView()
            }
        }
        .backgroundView()
    }
}

#if DEBUG
#Preview {
    MainViewScreen()
        .environment(MainRouter())
        .withPreviewEnvironment()
}
#endif
