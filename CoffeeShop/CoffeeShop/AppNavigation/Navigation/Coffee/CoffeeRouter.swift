import Observation

@MainActor
@Observable
public final class CoffeeRouter: NavigationRouter {
    public var path: [Route] = []

    public init() { }
}

public extension CoffeeRouter {
    nonisolated enum Route: Sendable, Hashable {
        case detail(id: Int)
    }
}
