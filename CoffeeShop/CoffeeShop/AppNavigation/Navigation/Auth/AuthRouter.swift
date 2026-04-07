import Observation

@MainActor
@Observable
public final class AuthRouter: SheetNavigationRouter {
    public var presentedSheet: Sheet?

    public init() { }
}

public extension AuthRouter {
    nonisolated enum Sheet: String, Identifiable, Sendable {
        
        case signUp
        case forgotPassword

        public var id: String { rawValue }
    }
}
