import Foundation

public struct LogConfig: Sendable {
    public let pathLogs: String
    public let pathDiagnostics: String

    public init(pathLogs: String, pathDiagnostics: String) {
        self.pathLogs = pathLogs
        self.pathDiagnostics = pathDiagnostics
    }

    public static var staging: LogConfig {
        LogConfig(
            pathLogs: "/logs",
            pathDiagnostics: "/logs/reportsFromUser"
        )
    }

    public static var production: LogConfig {
        LogConfig(
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
