import Foundation
import Domain

public enum DiagnosticsEndpoints {

    case sendLogs(deviceInfo: DeviceInfo, logs: String)

    public var endpoint: APIEndpoint {
        switch self {
        case let .sendLogs(deviceInfo, logs):
            APIEndpoint(
                path: "/logs/reportsFromUser",
                method: .POST,
                queryItems: nil,
                body: LogsRequestDTO(deviceInfo: deviceInfo, logs: logs)
            )
        }
    }
}
