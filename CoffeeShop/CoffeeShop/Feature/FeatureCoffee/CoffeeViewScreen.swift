import DesignSystem
import Domain
import SwiftUI

public struct CoffeeViewScreen: View {

    @Environment(CoffeeRouter.self) private var coffeeRouter
    @State private var coffeeStore: CoffeeStore

    public init(environment: AppDependencies) {
        _coffeeStore = State(initialValue: CoffeeStore(environment: environment))
    }

    public var body: some View {
        List {
            Section {
                ForEach(coffeeStore.coffeeShops) { coffee in
                    Button {
                        coffeeRouter.push(.detail(id: coffee.id))
                    } label: {
                        coffeeRow(for: coffee)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Available Coffees")
            }
        }
        .backgroundView()
        .task {
            await coffeeStore.loadCoffees()
        }
        .loadingView(coffeeStore.isLoading)
        .errorAlertView(
            coffeeStore.errorAlert,
            onDismiss: {
                coffeeStore.dismissErrorAlert()
            }
        )
    }

    private func coffeeRow(for coffee: CoffeeShops) -> some View {
        HStack {
            SymbolImage(.coffee)
                .foregroundStyle(.brown)

            VStack(alignment: .leading, spacing: 4) {
                Text(coffee.title)
                    .font(.headline)

                Text(coffee.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            SymbolImage(.chevronRight, accessibility: .decorative)
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }

}

#Preview {
    NavigationStack {
        CoffeeViewScreen(environment: .preview)
    }
    .environment(CoffeeRouter())
    .withPreviewEnvironment()
}
