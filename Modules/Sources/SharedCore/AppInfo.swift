import Foundation
import Domain

#if canImport(UIKit)
import UIKit
#endif

@MainActor
public struct AppInfo {

    public let appVersion: String
    public let buildNumber: String
    public let deviceModel: String

    public init(bundle: Bundle) {
        self.appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        #if os(iOS) || os(tvOS)
        self.deviceModel = UIDevice.current.model
        #elseif os(watchOS)
        self.deviceModel = "Apple Watch"
        #elseif os(macOS)
        self.deviceModel = "Mac"
        #else
        self.deviceModel = "Unknown"
        #endif
    }
}
