import SwiftUI

public struct CoffeeNavigationView: View {

    @Environment(\.appDependencies) private var dependencies
    @State private var coffeeRouter = CoffeeRouter()

    public init() { }

    public var body: some View {
        @Bindable var coffeeRouter = coffeeRouter

        MainTabNavigationContainer(path: $coffeeRouter.path) {
            CoffeeViewScreen(environment: dependencies)
                .navigationTitle("Coffee")
                .navigationDestination(for: CoffeeRouter.Route.self) { route in
                    switch route {
                    case .detail(let id):
                        CoffeeDetailViewScreen(coffeeId: id, environment: dependencies)
                    }
                }
        }
        .environment(coffeeRouter)
    }
}
