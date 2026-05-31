import SwiftUI

@main
struct CoffeeShopApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.appDependencies, appDependencies)
        }
    }

    private var appDependencies: AppDependencies {
        #if DEBUG
        .preview
        #else
        .live
        #endif
    }
}
