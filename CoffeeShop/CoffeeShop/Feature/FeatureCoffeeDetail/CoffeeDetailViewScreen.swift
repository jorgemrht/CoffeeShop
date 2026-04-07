import DesignSystem
import Domain
import SwiftUI

public struct CoffeeDetailViewScreen: View {

    @State private var coffeeStore: CoffeeStore

    let coffeeId: Int

    public init(coffeeId: Int, environment: AppDependencies) {
        self.coffeeId = coffeeId
        _coffeeStore = State(initialValue: CoffeeStore(environment: environment))
    }

    public var body: some View {
        ScrollView {
            if let coffee = coffeeStore.coffeeDetail {
                VStack(spacing: 24) {
                    SymbolImage(.coffee)
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
        }
        .backgroundView()
        .navigationTitle("Coffee Detail")
        .task {
            await coffeeStore.loadCoffeeDetail(id: coffeeId)
        }
        .loadingView(coffeeStore.isLoading)
        .errorAlertView(
            coffeeStore.errorAlert,
            onDismiss: {
                coffeeStore.dismissErrorAlert()
            }
        )
    }
}

#Preview {
    NavigationStack {
        CoffeeDetailViewScreen(coffeeId: 1, environment: .preview)
    }
    .withPreviewEnvironment()
}
