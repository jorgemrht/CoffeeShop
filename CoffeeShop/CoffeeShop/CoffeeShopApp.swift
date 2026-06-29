import SwiftUI

@main
struct CoffeeShopApp: App {
    private let appDependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.appDependencies, appDependencies)
        }
    }
}
