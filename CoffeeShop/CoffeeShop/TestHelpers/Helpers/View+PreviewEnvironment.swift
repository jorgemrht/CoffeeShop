import SwiftUI

#if DEBUG
public extension View {
    func withPreviewEnvironment(root: AppNavigation.Root = .main) -> some View {
        self
            .environment(AppNavigation(root: root))
            .environment(\.appDependencies, .preview)
    }
}
#endif
