import SwiftUI

public extension Image {
    init(_ symbol: Symbol) {
        self.init(systemName: symbol.systemName)
    }

    init(symbol: Symbol) {
        self.init(systemName: symbol.systemName)
    }
}
