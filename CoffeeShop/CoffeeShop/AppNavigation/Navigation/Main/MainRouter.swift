import Observation

@MainActor
@Observable
public final class MainRouter: SheetNavigationRouter {
    public var selectedTab: Tab = .coffee
    public var presentedSheet: Sheet?

    public init() { }
}

public extension MainRouter {
    nonisolated enum Route: Sendable, Hashable { }

    nonisolated enum Tab: Sendable, Hashable {
        case coffee
        case shops
    }

    nonisolated enum Sheet: String, Identifiable, Sendable {
        case settings

        public var id: String { rawValue }
    }
}
