import Foundation

// DOC: https://developer.apple.com/documentation/foundation/locale

public protocol AppInfoProvider: Sendable {
    var appVersion: String { get }
    var buildNumber: String { get }
}

public struct DeviceInfo: Sendable, Codable {

    public let deviceModel: String
    public let osVersion: String
    public let appVersion: String
    public let buildNumber: String
    public let locale: String

    public init(appInfo: AppInfoProvider, locale: Locale = .current) {
        self.deviceModel = ProcessInfo.processInfo.hostName
        self.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        self.appVersion = appInfo.appVersion
        self.buildNumber = appInfo.buildNumber
        self.locale = locale.identifier
    }
}
