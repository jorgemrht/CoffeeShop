import DesignSystem
import SwiftUI

public struct LoginViewScreen: View {

    @Environment(AuthRouter.self) private var authRouter
    @State private var loginStore: LoginStore
    private let onAuthenticated: @MainActor () -> Void

    public init(
        environment: AppDependencies,
        onAuthenticated: @escaping @MainActor () -> Void = { }
    ) {
        _loginStore = State(initialValue: LoginStore(environment: environment))
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        VStack(spacing: 24) {

            Spacer()

            VStack(spacing: 16) {
                TextField("Email", text: $loginStore.email)
                SecureField("Password", text: $loginStore.password)
            }
            .padding(.horizontal, 24)

            Button {
                submitLogin()
            } label: {
                Text("Sign In")
            }
            .disabled(loginStore.isLoading)

            Spacer()

            Button {
                authRouter.present(.forgotPassword)
            } label: {
                Text("Forgot your password?")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            
            Button {
                authRouter.present(.signUp)
            } label: {
                HStack(spacing: 24) {
                    Text("Don't have an account?")
                    Text("Sign Up")
                }
                .font(.subheadline)
            }
            .buttonStyle(.plain)
        }
        .backgroundView()
        .loadingView(loginStore.isLoading)
        .errorAlertView(
            loginStore.errorAlert,
            onDismiss: {
                loginStore.dismissErrorAlert()
            }
        )
    }

    private func submitLogin() {
        Task {
            guard await loginStore.login() else {
                return
            }

            onAuthenticated()
        }
    }
}

#Preview {
    NavigationStack {
        LoginViewScreen(environment: .preview)
    }
    .environment(AuthRouter())
    .withPreviewEnvironment()
}
