import SwiftUI

public struct SettingsViewScreen: View {
    @Environment(\.dismiss) private var dismiss

    public init() { }

    public var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("App settings and preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsViewScreen()
    }
    .withPreviewEnvironment()
}
