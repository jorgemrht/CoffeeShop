import SwiftUI

public struct LoginViewScreen: View {

    @Environment(AppState.self) private var appState
    @Environment(\.appDependencies) private var environment
    @State private var loginStore: LoginStore?

    public init() { }

    public var body: some View {
        Group {
            if let loginStore {
                @Bindable var loginStore = loginStore

                VStack(spacing: 24) {

                    Spacer()

                    VStack(spacing: 16) {
                        TextField("Email", text: $loginStore.email)
                        SecureField("Password", text: $loginStore.password)
                    }
                    .padding(.horizontal, 24)

                    Button {
                        Task {
                            await loginStore.login()
                        }
                    } label: {
                        Text("Sign In")
                    }

                    Spacer()

                    NavigationLink(value: AuthRoute.register) {
                        HStack(spacing: 24) {
                            Text("Don't have an account?")
                            Text("Sign Up")
                        }
                        .font(.subheadline)
                    }
                }
                .onChange(of: loginStore.navigation) { _, newValue in
                    guard let newValue else { return }
                    switch newValue {
                    case .main:
                        appState.transition(to: .main)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            if loginStore == nil {
                loginStore = LoginStore(appDependencies: environment)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginViewScreen()
    }
    .withPreviewEnvironment()
}
