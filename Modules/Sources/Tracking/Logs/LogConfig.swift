import Foundation
import Macros

/// Configuration for logging backend
public struct LogConfig: Sendable {
    public let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    /// Staging environment
    public static var staging: LogConfig {
        LogConfig(endpoint: #URL("https://staging.api.myapp.com/logs"))
    }

    /// Production environment
    public static var production: LogConfig {
        LogConfig(endpoint: #URL("https://api.myapp.com/logs"))
    }

    /// Current environment based on build configuration
    public static var current: LogConfig {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }
}
