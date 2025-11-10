import SwiftUI
import SharedCore
import Tracking
import TestHelpers

public struct ShopsViewScreen: View {

    @Environment(ShopsStore.self) private var shopsStore
    @Environment(AppState.self) private var appState

    public init() { }

    public var body: some View {
        List {
            Section {
                ForEach(1...5, id: \.self) { index in
                    NavigationLink(value: ShopsRoute.detail(id: index)) {
                        HStack {
                            Image(systemName: "storefront.fill")
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shop #\(index)")
                                    .font(.headline)

                                Text("Tap to see details")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }
                }
            } header: {
                Text("Our Stores")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShopsViewScreen()
            .environment(
                ShopsStore(
                    logRepository: MockLogRepository.mock
                )
            )
    }
}
