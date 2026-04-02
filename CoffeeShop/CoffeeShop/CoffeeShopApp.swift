import SwiftUI

@main
struct CoffeeShopApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.appDependencies, AppDependencies.current)
        }
    }
}
