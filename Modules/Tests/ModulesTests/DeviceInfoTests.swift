import Testing
import Foundation
@testable import Domain
@testable import Data

// MARK: - DeviceInfo Tests

struct DeviceInfoTests {

    @Test func deviceInfoCreatesWithAppInfoProvider() {
        // Given: A mock AppInfoProvider
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "42")

        // When: Creating DeviceInfo with the provider
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)

        // Then: DeviceInfo should have correct values
        #expect(deviceInfo.appVersion == "1.0.0")
        #expect(deviceInfo.buildNumber == "42")
        #expect(!deviceInfo.deviceModel.isEmpty)
        #expect(!deviceInfo.osVersion.isEmpty)
        #expect(!deviceInfo.locale.isEmpty)
    }

    @Test func deviceInfoIsEncodable() throws {
        // Given: A DeviceInfo instance
        let mockAppInfo = MockAppInfoProvider(appVersion: "2.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(deviceInfo)

        // Then: Should encode without errors
        #expect(data.count > 0)
    }

    @Test func deviceInfoIsDecodable() throws {
        // Given: Valid JSON data
        let json = """
        {
            "deviceModel": "MacBook Pro",
            "osVersion": "14.0",
            "appVersion": "1.5.0",
            "buildNumber": "123",
            "locale": "en_US"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding from JSON
        let decoder = JSONDecoder()
        let deviceInfo = try decoder.decode(DeviceInfo.self, from: data)

        // Then: Should decode correctly
        #expect(deviceInfo.deviceModel == "MacBook Pro")
        #expect(deviceInfo.osVersion == "14.0")
        #expect(deviceInfo.appVersion == "1.5.0")
        #expect(deviceInfo.buildNumber == "123")
        #expect(deviceInfo.locale == "en_US")
    }
}
