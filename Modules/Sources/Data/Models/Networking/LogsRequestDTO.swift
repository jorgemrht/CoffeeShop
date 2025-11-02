import Foundation

public struct LogsRequestDTO: Sendable, Codable {
    public let deviceInfo: DeviceInfo
    public let logs: String?

    public init(deviceInfo: DeviceInfo, logs: String) {
        self.deviceInfo = deviceInfo
        self.logs = logs
    }
}
