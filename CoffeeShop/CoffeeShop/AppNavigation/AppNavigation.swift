import Observation

@MainActor
@Observable
public final class AppNavigation {

    public private(set) var root: Root

    public init(root: Root) {
        self.root = root
    }
}

public extension AppNavigation {
    nonisolated enum Root: Sendable, Hashable {
        case splash
        case auth
        case main
    }
}
