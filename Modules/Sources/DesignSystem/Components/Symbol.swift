import SwiftUI

public enum Symbol: Sendable {
    case close
    case coffee
    case chevronRight
    case settings
    case shop

    var systemName: String {
        switch self {
        case .close:
            "xmark"
        case .coffee:
            "cup.and.saucer.fill"
        case .chevronRight:
            "chevron.right"
        case .settings:
            "gearshape.fill"
        case .shop:
            "storefront.fill"
        }
    }

    public var accessibilityLabel: LocalizedStringKey {
        switch self {
        case .close:
            "Close"
        case .coffee:
            "Coffee"
        case .chevronRight:
            "Chevron Right"
        case .settings:
            "Settings"
        case .shop:
            "Shop"
        }
    }
}
