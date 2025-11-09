import Foundation
import Tracking
import Domain

public struct MockLogRepository {

    public init() {}

    public static var mock: LogRepositoryImpl {
        let deviceInfo = DeviceInfo(
            appVersion: "1.0.0",
            buildNumber: "1",
            deviceModel: "iPhone"
        )
        return LogRepositoryImpl(
            deviceInfo: deviceInfo,
            config: .staging,
            bundleIdentifier: "com.coffeeshop.mock"
        )
    }
}
