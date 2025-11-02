import Testing
import Foundation
@testable import Domain
@testable import Data
@testable import Tracking

// MARK: - Log Tests

struct LogTests {

    @Test func logCreatesWithAllProperties() {
        // Given: Log parameters
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let level = "error"
        let context = "network"
        let errorDescription = "Connection timeout"
        let timestamp = Date()

        // When: Creating Log
        let log = Log(
            deviceInfo: deviceInfo,
            level: level,
            context: context,
            errorDescription: errorDescription,
            timestamp: timestamp
        )

        // Then: Should store all values correctly
        #expect(log.deviceInfo.appVersion == "1.0.0")
        #expect(log.level == "error")
        #expect(log.context == "network")
        #expect(log.errorDescription == "Connection timeout")
        #expect(log.timestamp == timestamp)
    }

    @Test func logCreatesWithNilErrorDescription() {
        // Given: Log with nil error description
        let mockAppInfo = MockAppInfoProvider(appVersion: "2.0.0", buildNumber: "200")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)

        // When: Creating Log without error
        let log = Log(
            deviceInfo: deviceInfo,
            level: "info",
            context: "ui",
            errorDescription: nil,
            timestamp: Date()
        )

        // Then: Error description should be nil
        #expect(log.errorDescription == nil)
        #expect(log.level == "info")
    }

    @Test func logIsEncodable() throws {
        // Given: A Log instance
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.5.0", buildNumber: "150")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let log = Log(
            deviceInfo: deviceInfo,
            level: "warning",
            context: "authentication",
            errorDescription: "Token expired",
            timestamp: Date()
        )

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(log)

        // Then: Should encode successfully
        #expect(data.count > 0)
    }

    @Test func logIsDecodable() throws {
        // Given: Valid Log JSON
        let json = """
        {
            "deviceInfo": {
                "deviceModel": "iPhone 15",
                "osVersion": "18.0",
                "appVersion": "1.0.0",
                "buildNumber": "100",
                "locale": "en_US"
            },
            "level": "error",
            "context": "database",
            "errorDescription": "Failed to save data",
            "timestamp": "2024-01-01T12:00:00Z"
        }
        """
        let data = Data(json.utf8)

        // When: Decoding Log
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let log = try decoder.decode(Log.self, from: data)

        // Then: Should decode correctly
        #expect(log.level == "error")
        #expect(log.context == "database")
        #expect(log.errorDescription == "Failed to save data")
        #expect(log.deviceInfo.appVersion == "1.0.0")
    }

    @Test func logIsSendable() {
        // Given: A Log instance
        let mockAppInfo = MockAppInfoProvider(appVersion: "1.0.0", buildNumber: "100")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let log = Log(
            deviceInfo: deviceInfo,
            level: "debug",
            context: "system",
            errorDescription: nil,
            timestamp: Date()
        )

        // When: Checking Sendable conformance (compile-time)
        // Then: Should compile (Log conforms to Sendable)
        let _: any Sendable = log
        #expect(log.level == "debug")
    }

    @Test func logEncodesAndDecodesRoundTrip() throws {
        // Given: A Log instance
        let mockAppInfo = MockAppInfoProvider(appVersion: "3.0.0", buildNumber: "300")
        let deviceInfo = DeviceInfo(appInfo: mockAppInfo)
        let originalLog = Log(
            deviceInfo: deviceInfo,
            level: "fault",
            context: "business",
            errorDescription: "Critical error",
            timestamp: Date(timeIntervalSince1970: 1704110400) // Fixed timestamp
        )

        // When: Encoding and then decoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalLog)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedLog = try decoder.decode(Log.self, from: data)

        // Then: Should maintain all values
        #expect(decodedLog.level == originalLog.level)
        #expect(decodedLog.context == originalLog.context)
        #expect(decodedLog.errorDescription == originalLog.errorDescription)
        #expect(abs(decodedLog.timestamp.timeIntervalSince1970 - originalLog.timestamp.timeIntervalSince1970) < 1)
    }
}

// MARK: - LogLevel Tests

struct LogLevelTests {

    @Test func logLevelHasAllCases() {
        // Given/When/Then: All log levels should have correct raw values
        #expect(LogLevel.debug.rawValue == "debug")
        #expect(LogLevel.info.rawValue == "info")
        #expect(LogLevel.warning.rawValue == "warning")
        #expect(LogLevel.error.rawValue == "error")
        #expect(LogLevel.fault.rawValue == "fault")
    }

    @Test func logLevelIsEncodable() throws {
        // Given: A LogLevel
        let level = LogLevel.error

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(level)
        let json = String(data: data, encoding: .utf8)

        // Then: Should encode as string
        #expect(json == "\"error\"")
    }

    @Test func logLevelIsDecodable() throws {
        // Given: JSON with log level
        let json = "\"warning\""
        let data = Data(json.utf8)

        // When: Decoding LogLevel
        let decoder = JSONDecoder()
        let level = try decoder.decode(LogLevel.self, from: data)

        // Then: Should decode correctly
        #expect(level == .warning)
    }

    @Test func logLevelIsSendable() {
        // Given: A LogLevel
        let level = LogLevel.info

        // When: Checking Sendable conformance
        // Then: Should compile
        let _: any Sendable = level
        #expect(level.rawValue == "info")
    }

    @Test func logLevelCanBeUsedInAsyncContext() async {
        // Given: A LogLevel
        let level = LogLevel.debug

        // When: Using in async context
        let rawValue = await Task { level.rawValue }.value

        // Then: Should work across concurrency boundaries
        #expect(rawValue == "debug")
    }
}

// MARK: - LogContext Tests

struct LogContextTests {

    @Test func logContextHasAllCases() {
        // Given/When/Then: All log contexts should have correct raw values
        #expect(LogContext.authentication.rawValue == "authentication")
        #expect(LogContext.network.rawValue == "network")
        #expect(LogContext.database.rawValue == "database")
        #expect(LogContext.ui.rawValue == "ui")
        #expect(LogContext.business.rawValue == "business")
        #expect(LogContext.system.rawValue == "system")
    }

    @Test func logContextIsEncodable() throws {
        // Given: A LogContext
        let context = LogContext.network

        // When: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(context)
        let json = String(data: data, encoding: .utf8)

        // Then: Should encode as string
        #expect(json == "\"network\"")
    }

    @Test func logContextIsDecodable() throws {
        // Given: JSON with log context
        let json = "\"authentication\""
        let data = Data(json.utf8)

        // When: Decoding LogContext
        let decoder = JSONDecoder()
        let context = try decoder.decode(LogContext.self, from: data)

        // Then: Should decode correctly
        #expect(context == .authentication)
    }

    @Test func logContextIsSendable() {
        // Given: A LogContext
        let context = LogContext.database

        // When: Checking Sendable conformance
        // Then: Should compile
        let _: any Sendable = context
        #expect(context.rawValue == "database")
    }

    @Test func logContextCanBeUsedInStructuredLogging() {
        // Given: Different contexts for different scenarios
        let authContext = LogContext.authentication
        let networkContext = LogContext.network
        let uiContext = LogContext.ui

        // When/Then: Each should represent its domain
        #expect(authContext != networkContext)
        #expect(networkContext != uiContext)
        #expect(authContext.rawValue == "authentication")
        #expect(networkContext.rawValue == "network")
        #expect(uiContext.rawValue == "ui")
    }

    @Test func logContextCoversAllApplicationDomains() {
        // Given: All application domains
        let allContexts: [LogContext] = [
            .authentication,  // User login/logout
            .network,         // API calls
            .database,        // Data persistence
            .ui,              // User interface
            .business,        // Business logic
            .system           // System-level
        ]

        // When/Then: Should have 6 contexts covering all domains
        #expect(allContexts.count == 6)

        // All should be unique
        let uniqueContexts = Set(allContexts.map { $0.rawValue })
        #expect(uniqueContexts.count == 6)
    }
}
