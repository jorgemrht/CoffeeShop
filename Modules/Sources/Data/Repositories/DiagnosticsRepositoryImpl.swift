import Domain
import Tracking
import Foundation
import OSLog

public struct DiagnosticsRepositoryImpl: DiagnosticsRepository {

    private let networkClient: NetworkClient
    private let appInfo: AppInfoProvider
    private let bundleIdentifier: String?

    public init(
        networkClient: NetworkClient,
        appInfo: AppInfoProvider,
        bundleIdentifier: String?
    ) {
        self.networkClient = networkClient
        self.appInfo = appInfo
        self.bundleIdentifier = bundleIdentifier
    }

    public func sendLogsToSupport() async throws {
        do {
            let logs = try await exportRecentLogs()
            let deviceInfo = DeviceInfo(appInfo: appInfo)

            _ = try await networkClient.request(
                DiagnosticsEndpoints.sendLogs(deviceInfo: deviceInfo, logs: logs).endpoint
            )

        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}

extension DiagnosticsRepositoryImpl {
    // MARK: - Private Helpers

    private func exportRecentLogs() async throws -> String {
        try await exportLogs(since: Date().addingTimeInterval(-3600))
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
            let level = formatLevel(log.level)
            logs += "[\(timestamp)] [\(level)] \(log.composedMessage)\n"
        }

        return logs
    }

    private func formatLevel(_ level: OSLogEntryLog.Level) -> String {
        switch level {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .notice: return "NOTICE"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        default: return "UNKNOWN"
        }
    }
}
