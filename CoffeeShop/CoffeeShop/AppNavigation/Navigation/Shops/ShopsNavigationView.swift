import SwiftUI

public struct ShopsNavigationView: View {

    @Environment(\.appDependencies) private var dependencies
    @State private var shopsRouter = ShopsRouter()

    public init() { }

    public var body: some View {
        @Bindable var shopsRouter = shopsRouter

        MainTabNavigationContainer(path: $shopsRouter.path) {
            ShopsViewScreen(environment: dependencies)
                .navigationTitle("Shops")
                .navigationDestination(for: ShopsRouter.Route.self) { route in
                    switch route {
                    case .detail(let id):
                        ShopDetailViewScreen(shopId: id)
                    case .coffeeDetail(let id):
                        CoffeeDetailViewScreen(coffeeId: id, environment: dependencies)
                    }
                }
        }
        .environment(shopsRouter)
    }
}
