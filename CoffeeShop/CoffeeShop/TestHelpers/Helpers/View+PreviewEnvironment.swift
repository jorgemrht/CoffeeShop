import SwiftUI

#if DEBUG
public extension View {
    func withPreviewEnvironment(root: AppRoot = .main) -> some View {
        self
            .environment(AppState(root: root))
            .environment(\.appDependencies, .mock)
    }
}
#endif
