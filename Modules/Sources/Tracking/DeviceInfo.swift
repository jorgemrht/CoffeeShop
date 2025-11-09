import Foundation

// DOC: https://developer.apple.com/documentation/foundation/locale
// DOC: https://developer.apple.com/documentation/foundation/processinfo

public struct DeviceInfo: Sendable, Codable {

    public let deviceModel: String
    public let osVersion: String
    public let appVersion: String
    public let buildNumber: String
    public let locale: String

    public init(appVersion: String, buildNumber: String, deviceModel: String, locale: Locale = .current) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.deviceModel = deviceModel
        self.locale = locale.identifier
        self.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    }
}
