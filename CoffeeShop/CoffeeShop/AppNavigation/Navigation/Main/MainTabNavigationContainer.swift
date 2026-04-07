import DesignSystem
import SwiftUI

public struct MainTabNavigationContainer<Route: Hashable, Content: View>: View {
    @Environment(MainRouter.self) private var mainRouter
    @Binding private var path: [Route]
    private let content: Content

    public init(
        path: Binding<[Route]>,
        @ViewBuilder content: () -> Content
    ) {
        _path = path
        self.content = content()
    }

    public var body: some View {
        NavigationStack(path: $path) {
            content
                .toolbar {
                    ToolbarItemContent(symbol: .settings, action: {
                        mainRouter.presentedSheet = .settings
                    })
                }
        }
    }
}
