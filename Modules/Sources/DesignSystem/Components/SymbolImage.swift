import SwiftUI

public struct SymbolImage: View {
    public enum Accessibility {
        case labeled
        case decorative
    }

    private let symbol: Symbol
    private let accessibility: Accessibility

    public init(
        _ symbol: Symbol,
        accessibility: Accessibility = .labeled
    ) {
        self.symbol = symbol
        self.accessibility = accessibility
    }

    public var body: some View {
        switch accessibility {
        case .labeled:
            Image(symbol)
                .accessibilityLabel(symbol.accessibilityLabel)
        case .decorative:
            Image(symbol)
                .accessibilityHidden(true)
        }
    }
}
