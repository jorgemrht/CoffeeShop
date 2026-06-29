import DesignSystem
import Domain
import SwiftUI

public struct CoffeeDetailViewScreen: View {

    @State private var coffeeStore: CoffeeStore

    let coffeeId: UUID

    public init(coffeeId: UUID, environment: AppDependencies) {
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

                    Text(coffee.description)
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

#if DEBUG
#Preview {
    NavigationStack {
        CoffeeDetailViewScreen(coffeeId: UUID(), environment: .preview)
    }
    .withPreviewEnvironment()
}
#endif
