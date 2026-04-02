import SwiftUI
import Domain

public struct CoffeeViewScreen: View {

    @Environment(\.appDependencies) private var environment
    @State private var coffeeStore: CoffeeStore?

    public init() { }

    public var body: some View {
        Group {
            if let coffeeStore {
                if coffeeStore.isLoading {
                    ProgressView("Loading coffees...")
                } else if let errorMessage = coffeeStore.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if coffeeStore.coffeeShops.isEmpty {
                    ContentUnavailableView(
                        "No Coffees",
                        systemImage: "cup.and.saucer",
                        description: Text("No coffees available at the moment")
                    )
                } else {
                    List {
                        Section {
                            ForEach(coffeeStore.coffeeShops) { coffee in
                                NavigationLink(value: CoffeeRoute.detail(id: Int(coffee.id) ?? 0)) {
                                    HStack {
                                        Image(systemName: "cup.and.saucer.fill")
                                            .foregroundStyle(.brown)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(coffee.title)
                                                .font(.headline)

                                            Text(coffee.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()
                                    }
                                }
                            }
                        } header: {
                            Text("Available Coffees")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            if coffeeStore == nil {
                coffeeStore = CoffeeStore(appDependencies: environment)
            }

            await coffeeStore?.loadCoffees()
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeViewScreen()
    }
    .withPreviewEnvironment()
}
