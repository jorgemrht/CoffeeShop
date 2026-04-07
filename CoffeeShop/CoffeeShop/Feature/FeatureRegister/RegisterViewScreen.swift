import DesignSystem
import SwiftUI

public struct RegisterViewScreen: View {

    @State private var registerStore: RegisterStore
    private let onAuthenticated: @MainActor () -> Void

    public init(
        environment: AppDependencies,
        onAuthenticated: @escaping @MainActor () -> Void = { }
    ) {
        _registerStore = State(initialValue: RegisterStore(environment: environment))
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sign up to get started")
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

                SecureField("Password", text: $registerStore.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $registerStore.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 24)

            Button {
                submitRegister()
            } label: {
                if registerStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(registerStore.isLoading ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)
            .disabled(registerStore.isLoading)
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()
        }
        .backgroundView()
        .loadingView(registerStore.isLoading)
        .errorAlertView(
            registerStore.errorAlert,
            onDismiss: {
                registerStore.dismissErrorAlert()
            }
        )
    }

    private func submitRegister() {
        Task {
            guard await registerStore.register() else {
                return
            }

            onAuthenticated()
        }
    }
}

#Preview {
    NavigationStack {
        RegisterViewScreen(environment: .preview)
    }
    .withPreviewEnvironment()
}
