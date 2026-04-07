import DesignSystem
import SwiftUI

public struct ShopsViewScreen: View {

    @Environment(ShopsRouter.self) private var shopsRouter
    @State private var shopsStore: ShopsStore

    public init(environment: AppDependencies) {
        _shopsStore = State(initialValue: ShopsStore(environment: environment))
    }

    public var body: some View {
        List {
            Section {
                ForEach(shopsStore.shops, id: \.self) { shopID in
                    Button {
                        shopsRouter.push(.detail(id: shopID))
                    } label: {
                        HStack {
                            SymbolImage(.shop)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shop #\(shopID)")
                                    .font(.headline)

                                Text("Tap to see details")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            SymbolImage(.chevronRight, accessibility: .decorative)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Our Stores")
            }
        }
        .backgroundView()
        .task {
            await shopsStore.loadShops()
        }
        .loadingView(shopsStore.isLoading)
        .errorAlertView(
            shopsStore.errorAlert,
            onDismiss: {
                shopsStore.dismissErrorAlert()
            }
        )
    }
}

#Preview {
    NavigationStack {
        ShopsViewScreen(environment: .preview)
    }
    .environment(ShopsRouter())
    .withPreviewEnvironment()
}
