import Foundation

public enum Environment {
    case staging, production

    public static var current: Environment {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }

    public var baseURL: URL {
        switch self {
        case .staging:
            return URL(string: "https://staging.api.myapp.com")!
        case .production:
            return URL(string: "https://api.myapp.com")!
        }
    }
}
