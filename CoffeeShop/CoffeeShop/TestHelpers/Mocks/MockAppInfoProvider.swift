import Foundation
import Domain

public struct MockAppInfoProvider {
    public let appVersion: String
    public let buildNumber: String
    public let deviceModel: String

    public init(
        appVersion: String = "1.0.0",
        buildNumber: String = "1",
        deviceModel: String = "iPhone"
    ) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.deviceModel = deviceModel
    }
}
