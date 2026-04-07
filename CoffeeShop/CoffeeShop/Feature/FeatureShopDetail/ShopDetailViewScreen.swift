import DesignSystem
import SwiftUI

public struct ShopDetailViewScreen: View {

    @Environment(ShopsRouter.self) private var shopsRouter
    private let shopId: Int

    public init(shopId: Int) {
        self.shopId = shopId
    }

    public var body: some View {
        VStack(spacing: 24) {
            SymbolImage(.shop)
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Shop \(shopId)")
                .font(.title)
                .fontWeight(.bold)

            Text("Details about this shop")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                shopsRouter.push(.coffeeDetail(id: shopId))
            } label: {
                Label {
                    Text("See Coffee \(shopId)")
                } icon: {
                    SymbolImage(.coffee, accessibility: .decorative)
                }
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .padding(24)
        .backgroundView()
        .navigationTitle("Shop Detail")
    }
}

#Preview {
    NavigationStack {
        ShopDetailViewScreen(shopId: 1)
    }
    .environment(ShopsRouter())
    .withPreviewEnvironment()
}
