import Foundation
import Data
import Domain
import OSLog

public struct LogRepositoryImpl: Sendable {

    private let deviceInfo: DeviceInfo
    private let config: LogConfig
    private let subsystem: String
    private let logger: Logger
    private let networkClient: NetworkClient

    public init(
        deviceInfo: DeviceInfo,
        config: LogConfig,
        networkClient: NetworkClient,
        subsystem: String
    ) {
        self.deviceInfo = deviceInfo
        self.config = config
        self.networkClient = networkClient
        self.subsystem = subsystem
        self.logger = Logger(subsystem: subsystem, category: "LogRepository")
    }
}

// MARK: - Real-time Logging

extension LogRepositoryImpl {
    public func log(_ level: LogLevel, _ context: LogContext, error: Error?) async {
        let log = Log(
            deviceInfo: deviceInfo,
            level: level.rawValue,
            context: context.rawValue,
            errorDescription: error?.localizedDescription,
            timestamp: Date()
        )
        await sendLog(log)
    }

    private func sendLog(_ log: Log) async {
        do {
            _ = try await sendRequest(path: config.pathLogs, body: log)
            logger.debug("Log sent successfully")
        } catch {
            logger.error("Failed to send log: \(error.localizedDescription)")
        }
    }
}

// MARK: - Diagnostics (OSLog Export)

extension LogRepositoryImpl {

    public func sendLogsToSupport() async throws {
        do {
            let logs = try await exportLogs(since: Date().addingTimeInterval(-3600))

            struct LogsRequest: Codable {
                let deviceInfo: DeviceInfo
                let logs: String
            }

            _ = try await sendRequest(
                path: config.pathDiagnostics,
                body: LogsRequest(deviceInfo: deviceInfo, logs: logs)
            )
            logger.info("Diagnostic logs sent to support successfully")

        } catch {
            logger.error("Failed to send diagnostics: \(error.localizedDescription)")
        }
    }

    private func exportLogs(since date: Date) async throws -> String {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(date: date)

        let entries = try store.getEntries(at: position)
        var logs = ""

        for entry in entries {
            guard let log = entry as? OSLogEntryLog,
                  log.subsystem.hasPrefix(subsystem) else {
                continue
            }

            let timestamp = log.date.formatted(.iso8601)
            logs += "[\(timestamp)] [\(log.level.rawValue)] \(log.composedMessage)\n"
        }

        return logs
    }
}

// MARK: - URL Session

extension LogRepositoryImpl {
    private func sendRequest<T: Encodable>(path: String, body: T) async throws -> APIResponse {
        try await networkClient.request(
            APIEndpoint(
                path: path,
                method: .POST,
                body: body
            )
        )
    }
}

// MARK: - Factory

extension LogRepositoryImpl {
    public static func `default`(
        networkClient: NetworkClient,
        bundle: Bundle = .main
    ) -> LogRepositoryImpl {
        let appInfo = AppInfo(bundle: bundle)
        return `default`(
            deviceInfo: .init(
                appVersion: appInfo.appVersion,
                buildNumber: appInfo.buildNumber,
                deviceModel: appInfo.deviceModel
            ),
            networkClient: networkClient,
            subsystem: NetworkClientConfiguration.live(bundleIdentifier: bundle.bundleIdentifier).subsystem
        )
    }

    public static func `default`(
        deviceInfo: DeviceInfo,
        networkClient: NetworkClient,
        subsystem: String
    ) -> LogRepositoryImpl {
        LogRepositoryImpl(
            deviceInfo: deviceInfo,
            config: .current,
            networkClient: networkClient,
            subsystem: subsystem
        )
    }
}
