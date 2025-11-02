import Foundation
import Macros

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
            #URL("https://staging.api.myapp.com")
        case .production:
            #URL("https://api.myapp.com")
        }
    }

    public var supportLogsURL: URL {
        switch self {
        case .staging:
            #URL("https://staging.api.myapp.com/support/logs")
        case .production:
            #URL("https://api.myapp.com/support/logs")
        }
    }
}
