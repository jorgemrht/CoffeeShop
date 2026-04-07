import DesignSystem
import SwiftUI

public struct MainViewScreen: View {
    @Environment(MainRouter.self) private var mainRouter

    public init() { }

    public var body: some View {
        @Bindable var mainRouter = mainRouter

        TabView(selection: $mainRouter.selectedTab) {
            CoffeeNavigationView()
                .tabItem {
                    Label {
                        Text("Coffee")
                    } icon: {
                        SymbolImage(.coffee, accessibility: .decorative)
                    }
                }
                .tag(MainRouter.Tab.coffee)

            ShopsNavigationView()
                .tabItem {
                    Label {
                        Text("Shops")
                    } icon: {
                        SymbolImage(.shop, accessibility: .decorative)
                    }
                }
                .tag(MainRouter.Tab.shops)
        }
        .backgroundView()
    }
}

#Preview {
    MainViewScreen()
        .environment(MainRouter())
        .withPreviewEnvironment()
}
