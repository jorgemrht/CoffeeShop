import DesignSystem
import SwiftUI

public struct SettingsViewScreen: View {
    @State private var settingsStore: SettingsStore
    private let onLogoutRequested: @MainActor () -> Void

    public init(
        environment: AppDependencies,
        onLogoutRequested: @escaping @MainActor () -> Void = { }
    ) {
        _settingsStore = State(initialValue: SettingsStore(environment: environment))
        self.onLogoutRequested = onLogoutRequested
    }

    public var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("App settings and preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Log Out") {
                onLogoutRequested()
            }
            .buttonStyle(.borderedProminent)
        }
        .backgroundView()
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsViewScreen(environment: .preview)
    }
    .withPreviewEnvironment()
}
