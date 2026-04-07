import SwiftUI

public struct AppRootView: View {

    @State private var appNavigation = AppNavigation(root: .splash)

    public init() { }

    public var body: some View {
        rootContent
            .id(appNavigation.root)
            .animation(.easeInOut, value: appNavigation.root)
    }
}

extension AppRootView {
    @ViewBuilder
    private var rootContent: some View {
        switch appNavigation.root {
        case .splash:
            SplashViewScreen { destination in
                switch destination {
                case .auth:
                    setRoot(.auth)
                case .main:
                    setRoot(.main)
                }
            }
        case .auth:
            AuthNavigationView {
                setRoot(.main)
            }
        case .main:
            MainNavigationView {
                setRoot(.auth)
            }
        }
    }

    private func setRoot(_ root: AppNavigation.Root) {
        guard appNavigation.root != root else {
            return
        }

        appNavigation = AppNavigation(root: root)
    }
}

#if DEBUG
#Preview { AppRootView() }
#endif
