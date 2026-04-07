import SwiftUI
import DesignSystem

public struct AuthNavigationView: View {

    @Environment(\.appDependencies) private var dependencies
    @State private var authRouter = AuthRouter()
    private let onAuthenticated: @MainActor () -> Void

    public init(onAuthenticated: @escaping @MainActor () -> Void) {
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        @Bindable var authRouter = authRouter

        LoginViewScreen(
            environment: dependencies,
            onAuthenticated: onAuthenticated
        )
        .sheet(item: $authRouter.presentedSheet) { sheet in
            switch sheet {
            case .signUp:
                NavigationStack {
                    RegisterViewScreen(
                        environment: dependencies,
                        onAuthenticated: onAuthenticated
                    )
                    .toolbar {
                        ToolbarItemContent(symbol: .close, action: {
                            authRouter.dismiss()
                        })
                    }
                }
            case .forgotPassword:
                NavigationStack {
                    RememberPasswordViewScreen(environment: dependencies)
                    .toolbar {
                        ToolbarItemContent(symbol: .close, action: {
                            authRouter.dismiss()
                        })
                    }
                }
            }
        }
        .environment(authRouter)
    }
}
