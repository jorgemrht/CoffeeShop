import SwiftUI
import SharedCore
import FeatureRegister
import TestHelpers

public struct LoginViewScreen: View {
    
    @Environment(LoginStore.self) private var loginStore
    @Environment(\.appState) private var appState: AppState?
    
    public init() { }

    public var body: some View {
        
        @Bindable var loginStore = loginStore

        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()

                VStack(spacing: 16) {
                    TextField("Email", text: $loginStore.email)
                    SecureField("Contraseña", text: $loginStore.password)
                }
                .padding(.horizontal, 24)

                Button {
                    Task {
                        await loginStore.login()
                    }
                } label: {
                    Text("Iniciar Sesión")
                }

                Spacer()

                NavigationLink(value: AuthRoute.register) {
                    HStack(spacing: 24) {
                        Text("¿No tienes cuenta?")
                        Text("Regístrate")
                    }
                    .font(.subheadline)
                }
            }
            .onChange(of: loginStore.navigation) { _, newValue in
                guard let newValue else { return }
                
                switch newValue {
                case .main:
                    appState?.transition(to: .home)
                }
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterViewScreen()
                        .environment(
                            RegisterStore(authRepository: loginStore.authRepository)
                        )
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
                    authRepository: MockAuthRepository()
                )
            )
    }
}

