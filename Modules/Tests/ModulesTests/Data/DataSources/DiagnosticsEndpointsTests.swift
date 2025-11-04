import Testing
import Foundation
@testable import Data
@testable import Domain

struct DiagnosticsEndpointsTests {

    @Test func sendLogsEndpoint() {
        // Given
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let logs = "Test logs"

        // When
        let endpoint = DiagnosticsEndpoints.sendLogs(deviceInfo: deviceInfo, logs: logs).endpoint

        // Then
        #expect(endpoint.path == "/logs/reportsFromUser")
        #expect(endpoint.method == .POST)
        #expect(endpoint.body != nil)
    }
}
