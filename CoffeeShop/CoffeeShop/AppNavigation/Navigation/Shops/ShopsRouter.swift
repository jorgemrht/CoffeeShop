import Observation
import Foundation

@MainActor
@Observable
public final class ShopsRouter: NavigationRouter {
    public var path: [Route] = []

    public init() { }
}

public extension ShopsRouter {
    nonisolated enum Route: Sendable, Hashable {
        case detail(id: UUID)
        case coffeeDetail(id: UUID)
    }
}
