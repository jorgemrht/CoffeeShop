import Foundation

public struct LoggingConfiguration: Sendable {

    public let logLevel: LoggerInterceptor.LogLevel
    public let includeHeaders: Bool
    public let includeBody: Bool
    public let maxBodySizeKB: Int
    public let sensitiveHeaders: Set<String>

    public static let development = LoggingConfiguration(
        logLevel: .debug,
        includeHeaders: true,
        includeBody: true,
        maxBodySizeKB: 128,
        sensitiveHeaders: ["authorization", "token", "api-key", "x-api-key", "cookie", "set-cookie"]
    )

    public static let production = LoggingConfiguration(
        logLevel: .info,
        includeHeaders: false,
        includeBody: false,
        maxBodySizeKB: 64,
        sensitiveHeaders: ["authorization", "token", "api-key", "x-api-key", "cookie", "set-cookie"]
    )

    public static var current: LoggingConfiguration {
        #if DEBUG
        .development
        #else
        .production
        #endif
    }

    public init(
        logLevel: LoggerInterceptor.LogLevel,
        includeHeaders: Bool,
        includeBody: Bool,
        maxBodySizeKB: Int,
        sensitiveHeaders: Set<String>
    ) {
        self.logLevel = logLevel
        self.includeHeaders = includeHeaders
        self.includeBody = includeBody
        self.maxBodySizeKB = maxBodySizeKB
        self.sensitiveHeaders = sensitiveHeaders
    }

    public func createInterceptor(
        subsystem: String?,
        category: String
    ) -> LoggerInterceptor {
        LoggerInterceptor(
            subsystem: subsystem,
            category: category,
            logLevel: logLevel,
            includeHeaders: includeHeaders,
            includeBody: includeBody,
            sensitiveHeaders: sensitiveHeaders,
            maxBodySizeKB: maxBodySizeKB
        )
    }
}
