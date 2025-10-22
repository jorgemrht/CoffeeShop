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
            guard let url = URL(string: "https://staging.api.myapp.com") else {
                fatalError("Invalid staging URL")
            }
            return url
        case .production:
            guard let url = URL(string: "https://api.myapp.com") else {
                fatalError("Invalid production URL")
            }
            return url
        }
    }
}
