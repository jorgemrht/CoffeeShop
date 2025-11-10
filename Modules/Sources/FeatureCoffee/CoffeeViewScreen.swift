import SwiftUI
import SharedCore
import Tracking
import TestHelpers

public struct CoffeeViewScreen: View {

    @Environment(CoffeeStore.self) private var coffeeStore

    public init() { }

    public var body: some View {
        Group {
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
        }
        .task {
            await coffeeStore.loadCoffees()
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeViewScreen()
            .environment(
                CoffeeStore(
                    coffeeRepository: MockCoffeeRepository(),
                    logRepository: MockLogRepository.mock
                )
            )
    }
}
