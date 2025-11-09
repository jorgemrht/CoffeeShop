import Foundation
import Domain
import OSLog

public struct LogRepositoryImpl: Sendable {

    private let deviceInfo: DeviceInfo
    private let config: LogConfig
    private let bundleIdentifier: String?
    private let logger: Logger
    private let session: URLSession

    public init(
        deviceInfo: DeviceInfo,
        config: LogConfig,
        bundleIdentifier: String? = nil
    ) {
        self.deviceInfo = deviceInfo
        self.config = config
        self.bundleIdentifier = bundleIdentifier
        self.logger = Logger(subsystem: bundleIdentifier ?? "", category: "LogRepository")
        self.session = .shared
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
                  log.subsystem.hasPrefix(bundleIdentifier ?? "") else {
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
    private func sendRequest<T: Encodable>(path: String, body: T) async throws -> HTTPURLResponse {
        let fullURL = config.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return httpResponse
    }
}

// MARK: - Factory

extension LogRepositoryImpl {
    public static func `default`(
        deviceInfo: DeviceInfo,
        bundleIdentifier: String?
    ) -> LogRepositoryImpl {
        LogRepositoryImpl(
            deviceInfo: deviceInfo,
            config: .current,
            bundleIdentifier: bundleIdentifier
        )
    }
}
