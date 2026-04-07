import SwiftUI

public struct ToolbarItemContent: ToolbarContent {

    private let action: @MainActor () -> Void
    private let symbol: Symbol

    public init(
        symbol: Symbol,
        action: @escaping @MainActor () -> Void
    ) {
        self.symbol = symbol
        self.action = action
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: action) {
                SymbolImage(symbol)
            }
        }
    }
}
