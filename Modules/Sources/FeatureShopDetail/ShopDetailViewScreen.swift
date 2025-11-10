import SwiftUI
import SharedCore

public struct ShopDetailViewScreen: View {

    @Environment(ShopsStore.self) private var shopsStore
    @Environment(AppState.self) private var appState

    let shopId: Int

    public init(shopId: Int) {
        self.shopId = shopId
    }

    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Shop \(shopId)")
                .font(.title)
                .fontWeight(.bold)

            Text("Details about this shop")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                appState.openCoffeeDetail(id: shopId)
            } label: {
                Label("See Coffee \(shopId)", systemImage: "cup.and.saucer.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Shop Detail")
    }
}

#Preview {
    NavigationStack {
        ShopDetailViewScreen(shopId: 1)
    }
}
