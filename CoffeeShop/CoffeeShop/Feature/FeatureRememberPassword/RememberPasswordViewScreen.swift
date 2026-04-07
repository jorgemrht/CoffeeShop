import DesignSystem
import SwiftUI

public struct RememberPasswordViewScreen: View {

    @State private var rememberPasswordStore: RememberPasswordStore

    public init(environment: AppDependencies) {
        _rememberPasswordStore = State(initialValue: RememberPasswordStore(environment: environment))
    }

    public var body: some View {
        VStack(spacing: 24) {
            Text("Recover Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your email to receive recovery instructions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Email", text: $rememberPasswordStore.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()

            Button("Send Recovery Email") {
                submitRecovery()
            }
            .buttonStyle(.borderedProminent)

            if rememberPasswordStore.recoveryRequested {
                Text("Recovery instructions have been prepared for this email.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .backgroundView()
        .loadingView(rememberPasswordStore.isLoading)
        .errorAlertView(
            rememberPasswordStore.errorAlert,
            onDismiss: {
                rememberPasswordStore.dismissErrorAlert()
            }
        )
    }

    private func submitRecovery() {
        Task {
            _ = await rememberPasswordStore.requestRecovery()
        }
    }
}

#Preview {
    NavigationStack {
        RememberPasswordViewScreen(environment: .preview)
    }
    .withPreviewEnvironment(root: .auth)
}
