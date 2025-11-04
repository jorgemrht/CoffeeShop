import SwiftUI
import SharedCore
import TestHelpers

public struct RegisterViewScreen: View {

    @Environment(RegisterStore.self) private var registerStore

    public init() { }

    public var body: some View {
        @Bindable var registerStore = registerStore

        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Crear Cuenta")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Regístrate para comenzar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 16) {
                TextField("Email", text: $registerStore.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Contraseña", text: $registerStore.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirmar Contraseña", text: $registerStore.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 24)

            Button {
                Task {
                    await registerStore.register()
                }
            } label: {
                if registerStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Registrarse")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(registerStore.isRegisterEnabled ? Color.blue : Color.gray)
            .foregroundStyle(.white)
            .cornerRadius(12)
            .disabled(!registerStore.isRegisterEnabled || registerStore.isLoading)
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()
        }
        .navigationTitle("")
    }
}

#Preview {
    NavigationStack {
        RegisterViewScreen()
            .environment(
                RegisterStore(
                    authRepository: MockAuthRepository()
                )
            )
    }
}
