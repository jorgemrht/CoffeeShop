import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - LogsRequestDTO Tests

struct LogsRequestDTOTests {

    @Test func logsRequestDTOCreatesWithDeviceInfoAndLogs() {
        // Given: DeviceInfo and logs string
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let logs = "Sample log entry"

        // When: Creating LogsRequestDTO
        let dto = LogsRequestDTO(deviceInfo: deviceInfo, logs: logs)

        // Then: Should store values correctly
        #expect(dto.deviceInfo.appVersion == "1.0.0")
        #expect(dto.logs == "Sample log entry")
    }

    @Test func logsRequestDTOEncodesCorrectly() throws {
        // Given: A LogsRequestDTO instance
        let mockAppInfo = MockAppInfoProvider(appVersion: "2.0.0", buildNumber: "200")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let dto = LogsRequestDTO(deviceInfo: deviceInfo, logs: "Test logs")

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)

        // Then: Should encode without errors
        #expect(data.count > 0)
    }

    @Test func logsRequestDTODecodesCorrectly() throws {
        // Given: Valid JSON data
        let json = """
        {
            "deviceInfo": {
                "deviceModel": "MacBook Pro",
                "osVersion": "14.0",
                "appVersion": "1.5.0",
                "buildNumber": "150",
                "locale": "en_US"
            },
            "logs": "Error log entry"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding from JSON
        let decoder = JSONDecoder()
        let dto = try decoder.decode(LogsRequestDTO.self, from: data)

        // Then: Should decode correctly
        #expect(dto.deviceInfo.appVersion == "1.5.0")
        #expect(dto.deviceInfo.buildNumber == "150")
        #expect(dto.logs == "Error log entry")
    }

    @Test func logsRequestDTOEncodesWithSnakeCaseStrategy() throws {
        // Given: A LogsRequestDTO
        let mockAppInfo = MockAppInfoProvider(appVersion: "3.0.0", buildNumber: "300")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let dto = LogsRequestDTO(deviceInfo: deviceInfo, logs: "System error")

        // When: Encoding with encoderDefault (snake_case)
        let encoder = JSONEncoder.encoderDefault()
        let data = try encoder.encode(dto)
        let json = String(data: data, encoding: .utf8)

        // Then: Should contain snake_case keys
        #expect(json != nil)
        #expect(json!.contains("device_info"))
        #expect(json!.contains("logs"))
    }

    @Test func logsRequestDTOHandlesMultilineLogs() throws {
        // Given: LogsRequestDTO with multiline logs
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let multilineLogs = """
        [2024-01-01] ERROR: Connection failed
        [2024-01-01] INFO: Retrying...
        [2024-01-01] ERROR: Timeout
        """
        let dto = LogsRequestDTO(deviceInfo: deviceInfo, logs: multilineLogs)

        // When: Encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(LogsRequestDTO.self, from: data)

        // Then: Should preserve multiline content
        #expect(decodedDTO.logs?.contains("ERROR: Connection failed") == true)
        #expect(decodedDTO.logs?.contains("INFO: Retrying...") == true)
        #expect(decodedDTO.logs?.contains("ERROR: Timeout") == true)
    }
}
