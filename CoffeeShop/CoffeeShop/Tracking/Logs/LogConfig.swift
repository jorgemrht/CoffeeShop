import Foundation
import Macros

public struct LogConfig: Sendable {
    public let baseURL: URL
    public let pathLogs: String
    public let pathDiagnostics: String

    public init(baseURL: URL, pathLogs: String, pathDiagnostics: String) {
        self.baseURL = baseURL
        self.pathLogs = pathLogs
        self.pathDiagnostics = pathDiagnostics
    }

    public static var staging: LogConfig {
        LogConfig(
            baseURL: #URL("https://staging.api.myapp.com"),
            pathLogs: "/logs",
            pathDiagnostics: "/logs/reportsFromUser"
        )
    }

    public static var production: LogConfig {
        LogConfig(
            baseURL: #URL("https://api.myapp.com"),
            pathLogs: "/logs",
            pathDiagnostics: "/logs/reportsFromUser"
        )
    }

    public static var current: LogConfig {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }
}
