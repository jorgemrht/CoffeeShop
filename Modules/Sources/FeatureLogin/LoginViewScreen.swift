import SwiftUI
import SharedCore
import FeatureRegister
import TestHelpers

public struct LoginViewScreen: View {
    
    @Environment(LoginStore.self) private var loginStore
    @Environment(AppState.self) private var appState
    
    public init() { }

    public var body: some View {

        @Bindable var loginStore = loginStore

        NavigationStack {
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
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterViewScreen()
                        .withStore(RegisterStore.self)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginViewScreen()
            .environment(
                LoginStore(
                    authRepository: MockAuthRepository(),
                    logRepository: MockLogRepository.mock
                )
            )
    }
}

