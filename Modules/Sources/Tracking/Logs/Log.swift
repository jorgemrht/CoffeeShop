import Foundation
import Domain

public struct Log: Sendable, Codable {
    public let deviceInfo: DeviceInfo
    public let level: String
    public let context: String
    public let errorDescription: String?
    public let timestamp: Date

    public init(
        deviceInfo: DeviceInfo,
        level: String,
        context: String,
        errorDescription: String?,
        timestamp: Date
    ) {
        self.deviceInfo = deviceInfo
        self.level = level
        self.context = context
        self.errorDescription = errorDescription
        self.timestamp = timestamp
    }
}

public enum LogLevel: String, Sendable, Codable {
    case debug
    case info
    case warning
    case error
    case fault
}

public enum LogContext: String, Sendable, Codable {
    case authentication
    case network
    case database
    case ui
    case business
    case system
}
