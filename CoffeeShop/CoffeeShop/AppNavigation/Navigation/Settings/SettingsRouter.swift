import Observation

@MainActor
@Observable
public final class SettingsRouter: NavigationRouter {
    public var path: [Route] = []

    public init() { }
}

public extension SettingsRouter {
    nonisolated enum Route: Sendable, Hashable { }
}
