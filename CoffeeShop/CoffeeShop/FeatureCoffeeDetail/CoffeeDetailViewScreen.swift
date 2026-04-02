import SwiftUI
import Domain

public struct CoffeeDetailViewScreen: View {

    @Environment(\.appDependencies) private var environment
    @State private var coffeeDetailStore: CoffeeDetailStore?

    let coffeeId: Int

    public init(coffeeId: Int) {
        self.coffeeId = coffeeId
    }

    public var body: some View {
        Group {
            if let coffeeDetailStore {
                if coffeeDetailStore.isLoading {
                    ProgressView("Loading coffee details...")
                } else if let errorMessage = coffeeDetailStore.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if let coffee = coffeeDetailStore.coffeeDetail {
                    ScrollView {
                        VStack(spacing: 24) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.brown)

                            Text(coffee.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(coffee.specialty)
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text(coffee.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Spacer()
                        }
                        .padding(24)
                    }
                } else {
                    ContentUnavailableView(
                        "No Details",
                        systemImage: "cup.and.saucer",
                        description: Text("Coffee details not available")
                    )
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Coffee Detail")
        .task {
            if coffeeDetailStore == nil {
                coffeeDetailStore = CoffeeDetailStore(appDependencies: environment)
            }

            await coffeeDetailStore?.loadDetails(id: coffeeId)
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeDetailViewScreen(coffeeId: 1)
    }
    .withPreviewEnvironment()
}
