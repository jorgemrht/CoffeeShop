import SwiftUI

public struct ShopsViewScreen: View {
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
    }
    .withPreviewEnvironment()
}
